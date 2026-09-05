CREATE TABLE IF NOT EXISTS jogadores (
  id TEXT PRIMARY KEY,
  nome TEXT UNIQUE NOT NULL,
  senha_hash TEXT NOT NULL,
  token TEXT,
  kills_total INTEGER DEFAULT 0,
  deaths_total INTEGER DEFAULT 0,
  assists_total INTEGER DEFAULT 0,
  partidas INTEGER DEFAULT 0,
  vitorias INTEGER DEFAULT 0,
  criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS partidas (
  id TEXT PRIMARY KEY,
  vencedor TEXT,
  duracao INTEGER,
  criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS partida_jogadores (
  partida_id TEXT,
  jogador_nome TEXT,
  time TEXT,
  heroi TEXT,
  kills INTEGER DEFAULT 0,
  deaths INTEGER DEFAULT 0,
  assists INTEGER DEFAULT 0,
  PRIMARY KEY (partida_id, jogador_nome)
);
