export class FilaManager {
  constructor(ctx, env) {
    this.ctx = ctx;
    this.env = env;
    this.fila = new Map();
  }

  async fetch(request) {
    if (request.headers.get("Upgrade") === "websocket") {
      const pair = new WebSocketPair();
      const [client, server] = Object.values(pair);
      this.ctx.acceptWebSocket(server);
      return new Response(null, { status: 101, webSocket: client });
    }
    return new Response("Fila Ventory", { status: 200 });
  }

  async webSocketMessage(ws, msg) {
    const data = JSON.parse(msg);
    if (data.tipo === "entrar_fila") {
      this.fila.set(ws, { nome: data.nome, heroi: data.heroi, ts: Date.now() });
      ws.send(JSON.stringify({ tipo: "fila_ok", posicao: this.fila.size }));
      this._verificar();
    }
    if (data.tipo === "cancelar_fila") {
      this.fila.delete(ws);
    }
  }

  _verificar() {
    const jogadores = [...this.fila.entries()];
    if (jogadores.length < 1) return;
    const agora = Date.now();
    const timeout = agora - jogadores[0][1].ts > 60000;
    if (jogadores.length >= 2 || timeout) {
      const match_id = crypto.randomUUID().split("-")[0];
      jogadores.forEach(([ws, j], i) => {
        try {
          ws.send(JSON.stringify({
            tipo: "partida_encontrada",
            match_id,
            time: i % 2 === 0 ? "azul" : "vermelho",
            com_bots: timeout && jogadores.length < 2
          }));
        } catch (_) {}
        this.fila.delete(ws);
      });
    }
  }

  async webSocketClose(ws) { this.fila.delete(ws); }
}

export class SalaPartida {
  constructor(ctx, env) {
    this.ctx = ctx;
    this.env = env;
    this.jogadores = new Map();
  }

  async fetch(request) {
    if (request.headers.get("Upgrade") === "websocket") {
      const pair = new WebSocketPair();
      const [client, server] = Object.values(pair);
      this.ctx.acceptWebSocket(server);
      this.jogadores.set(server, {
        id: crypto.randomUUID(), x: 0, y: 0,
        nome: "", heroi: "", time: "",
        kills: 0, deaths: 0, assists: 0
      });
      return new Response(null, { status: 101, webSocket: client });
    }
    return new Response("Sala Ventory", { status: 200 });
  }

  async webSocketMessage(ws, msg) {
    const data = JSON.parse(msg);
    const j = this.jogadores.get(ws);
    if (!j) return;
    if (data.tipo === "entrar") { j.nome = data.nome; j.heroi = data.heroi; j.time = data.time; }
    if (data.tipo === "mover") { j.x = data.x; j.y = data.y; }
    if (data.tipo === "evento" && data.evento === "kill") {
      j.kills++;
      for (const [, v] of this.jogadores) { if (v.nome === data.vitima) { v.deaths++; break; } }
    }
    if (data.tipo === "fim_partida") await this._salvar(data.vencedor, data.duracao);
    const estado = [...this.jogadores.values()].map(p => ({
      id: p.id, x: p.x, y: p.y, nome: p.nome,
      time: p.time, heroi: p.heroi,
      kills: p.kills, deaths: p.deaths
    }));
    for (const [s] of this.jogadores) {
      try { s.send(JSON.stringify({ tipo: "estado", jogadores: estado })); } catch (_) {}
    }
  }

  async _salvar(vencedor, duracao) {
    const pid = crypto.randomUUID();
    await this.env.D1.prepare("INSERT INTO partidas (id,vencedor,duracao) VALUES (?,?,?)").bind(pid, vencedor, duracao).run();
    for (const [, j] of this.jogadores) {
      const v = j.time === vencedor ? 1 : 0;
      await this.env.D1.prepare(
        "UPDATE jogadores SET kills_total=kills_total+?,deaths_total=deaths_total+?,assists_total=assists_total+?,partidas=partidas+1,vitorias=vitorias+? WHERE nome=?"
      ).bind(j.kills, j.deaths, j.assists, v, j.nome).run();
      await this.env.D1.prepare(
        "INSERT INTO partida_jogadores (partida_id,jogador_nome,time,heroi,kills,deaths,assists) VALUES (?,?,?,?,?,?,?)"
      ).bind(pid, j.nome, j.time, j.heroi, j.kills, j.deaths, j.assists).run();
    }
  }

  async webSocketClose(ws) { this.jogadores.delete(ws); }
}

async function hash(senha) {
  const buf = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(senha + "ventory_salt_2025"));
  return Array.from(new Uint8Array(buf)).map(b => b.toString(16).padStart(2, "0")).join("");
}
function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status, headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
  });
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const method = request.method;

    if (method === "OPTIONS") return new Response(null, { headers: { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Methods": "GET,POST,OPTIONS", "Access-Control-Allow-Headers": "Content-Type,Authorization" } });
    if (url.pathname === "/ping") return json({ status: "Ventory online 🎮" });

    if (url.pathname === "/register" && method === "POST") {
      const { nome, senha } = await request.json();
      if (!nome || !senha) return json({ erro: "Nome e senha obrigatórios" }, 400);
      const existe = await env.D1.prepare("SELECT id FROM jogadores WHERE nome=?").bind(nome).first();
      if (existe) return json({ erro: "Nome já existe" }, 409);
      const token = crypto.randomUUID();
      await env.D1.prepare("INSERT INTO jogadores (id,nome,senha_hash,token) VALUES (?,?,?,?)").bind(crypto.randomUUID(), nome, await hash(senha), token).run();
      return json({ sucesso: true, token, nome });
    }

    if (url.pathname === "/login" && method === "POST") {
      const { nome, senha } = await request.json();
      if (!nome || !senha) return json({ erro: "Nome e senha obrigatórios" }, 400);
      const jogador = await env.D1.prepare("SELECT id,nome,token FROM jogadores WHERE nome=? AND senha_hash=?").bind(nome, await hash(senha)).first();
      if (!jogador) return json({ erro: "Credenciais inválidas" }, 401);
      const novoToken = crypto.randomUUID();
      await env.D1.prepare("UPDATE jogadores SET token=? WHERE id=?").bind(novoToken, jogador.id).run();
      return json({ sucesso: true, token: novoToken, nome: jogador.nome });
    }

    if (url.pathname === "/perfil") {
      const token = request.headers.get("Authorization")?.replace("Bearer ", "");
      if (!token) return json({ erro: "Token necessário" }, 401);
      const j = await env.D1.prepare("SELECT nome,kills_total,deaths_total,assists_total,partidas,vitorias FROM jogadores WHERE token=?").bind(token).first();
      if (!j) return json({ erro: "Token inválido" }, 401);
      return json({ sucesso: true, ...j });
    }

    if (url.pathname === "/fila") {
      const token = request.headers.get("Authorization")?.replace("Bearer ", "");
      if (!token) return json({ erro: "Token necessário" }, 401);
      const jogador = await env.D1.prepare("SELECT nome FROM jogadores WHERE token=?").bind(token).first();
      if (!jogador) return json({ erro: "Token inválido" }, 401);
      const filaId = env.FILA.idFromName("fila-global");
      return env.FILA.get(filaId).fetch(request);
    }

    if (url.pathname === "/sala") {
      const token = request.headers.get("Authorization")?.replace("Bearer ", "");
      if (!token) return json({ erro: "Token necessário" }, 401);
      const jogador = await env.D1.prepare("SELECT nome FROM jogadores WHERE token=?").bind(token).first();
      if (!jogador) return json({ erro: "Token inválido" }, 401);
      const matchId = url.searchParams.get("match") || "sala-principal";
      const salaId = env.SALA.idFromName(matchId);
      return env.SALA.get(salaId).fetch(request);
    }

    return json({ erro: "Rota não encontrada" }, 404);
  }
};
