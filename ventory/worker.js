export class Sala {
  constructor(ctx, env) {
    this.ctx = ctx;
    this.env = env;
    this.jogadores = new Map();
    this.ctx.getWebSockets = this.ctx.getWebSockets?.bind(this.ctx);
  }

  async fetch(request) {
    if (request.headers.get("Upgrade") === "websocket") {
      const pair = new WebSocketPair();
      const [client, server] = Object.values(pair);
      this.ctx.acceptWebSocket(server);
      const id = crypto.randomUUID();
      this.jogadores.set(server, { id, x: 0, y: 0, nome: "" });
      return new Response(null, { status: 101, webSocket: client });
    }
    return new Response("Sala Ventory", { status: 200 });
  }

  async webSocketMessage(ws, msg) {
    const data = JSON.parse(msg);
    const jogador = this.jogadores.get(ws);
    if (!jogador) return;
    if (data.tipo === "mover") {
      jogador.x = data.x;
      jogador.y = data.y;
    }
    if (data.tipo === "entrar") {
      jogador.nome = data.nome;
    }
    const estado = [];
    for (const [, j] of this.jogadores) {
      estado.push({ id: j.id, x: j.x, y: j.y, nome: j.nome });
    }
    for (const [s] of this.jogadores) {
      try { s.send(JSON.stringify({ tipo: "estado", jogadores: estado })); } catch (_) {}
    }
  }

  async webSocketClose(ws) {
    this.jogadores.delete(ws);
  }
}

async function hash(senha) {
  const enc = new TextEncoder();
  const buf = await crypto.subtle.digest("SHA-256", enc.encode(senha + "ventory_salt_2025"));
  return Array.from(new Uint8Array(buf)).map(b => b.toString(16).padStart(2, "0")).join("");
}

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*"
    }
  });
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const method = request.method;

    if (method === "OPTIONS") {
      return new Response(null, {
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
          "Access-Control-Allow-Headers": "Content-Type,Authorization"
        }
      });
    }

    if (url.pathname === "/ping") {
      return json({ status: "Ventory online 🎮" });
    }

    if (url.pathname === "/register" && method === "POST") {
      const { nome, senha } = await request.json();
      if (!nome || !senha) return json({ erro: "Nome e senha obrigatórios" }, 400);
      const existe = await env.D1.prepare("SELECT id FROM jogadores WHERE nome = ?").bind(nome).first();
      if (existe) return json({ erro: "Nome já existe" }, 409);
      const senhaHash = await hash(senha);
      const token = crypto.randomUUID();
      await env.D1.prepare("INSERT INTO jogadores (id, nome, senha_hash, token) VALUES (?, ?, ?, ?)")
        .bind(crypto.randomUUID(), nome, senhaHash, token).run();
      return json({ sucesso: true, token, nome });
    }

    if (url.pathname === "/login" && method === "POST") {
      const { nome, senha } = await request.json();
      if (!nome || !senha) return json({ erro: "Nome e senha obrigatórios" }, 400);
      const senhaHash = await hash(senha);
      const jogador = await env.D1.prepare("SELECT id, nome, token FROM jogadores WHERE nome = ? AND senha_hash = ?")
        .bind(nome, senhaHash).first();
      if (!jogador) return json({ erro: "Credenciais inválidas" }, 401);
      const novoToken = crypto.randomUUID();
      await env.D1.prepare("UPDATE jogadores SET token = ? WHERE id = ?").bind(novoToken, jogador.id).run();
      return json({ sucesso: true, token: novoToken, nome: jogador.nome });
    }

    if (url.pathname === "/sala") {
      const authHeader = request.headers.get("Authorization");
      if (!authHeader) return json({ erro: "Token necessário" }, 401);
      const token = authHeader.replace("Bearer ", "");
      const jogador = await env.D1.prepare("SELECT nome FROM jogadores WHERE token = ?").bind(token).first();
      if (!jogador) return json({ erro: "Token inválido" }, 401);
      const salaId = env.SALA.idFromName("sala-principal");
      const sala = env.SALA.get(salaId);
      return sala.fetch(request);
    }

    return json({ erro: "Rota não encontrada" }, 404);
  }
};
