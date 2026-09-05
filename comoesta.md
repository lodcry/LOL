## O que você vai ter agora

**Login** — tela landscape bonita, campos grandes responsivos ao toque, animação de entrada, conecta no Cloudflare de verdade, cria conta e entra.

**Mapa** — mundo 4800x4800 estilo MOBA, grama, rio no meio, 3 rotas, torres azul e vermelho nas posições certas, selva escura, camps com emoji de dragão e lobo.

**Player** — círculo azul com seu nome flutuando, se move com joystick touch, câmera suave seguindo você.

**Joystick** — canto inferior esquerdo, desenhado via código, responsivo ao toque, 120fps.

**Minimapa** — canto inferior direito, mostra o mapa inteiro e os jogadores em tempo real.

**Console** — overlay no topo, captura tudo, filtra por LOG ERRO WARN.

**Multiplayer** — dois jogadores conectando na mesma sala via WebSocket, se vendo no minimapa.

---

## Como está modular

Cada coisa é um arquivo separado independente:

```
mapa.gd          — só o mapa, mexe sem afetar nada
joystick_touch.gd — só o joystick
minimapa.gd      — só o minimapa
player_controller.gd — só o player
partida_manager.gd — só organiza tudo
login_ui.gd      — só o login
ventory_network.gd — só a rede
sala_websocket.gd — só o WebSocket
boot_manager.gd  — só configurações globais
ventory_console.gd — só o log
```

Quer mudar o mapa? Mexe só em `mapa.gd`. Quer mudar o joystick? Só em `joystick_touch.gd`. Nada quebra o resto.

---

## Os próximos módulos em ordem

**Fase 2 — combate básico**
`heroi.gd` — atributos, HP, mana, nível
`torre.gd` — HP, ataca player próximo, destrói
`projetil.gd` — ataque básico com alcance

**Fase 3 — skills**
`skill_base.gd` — classe base de skill
`skill_q.gd`, `skill_w.gd`, `skill_e.gd`, `skill_r.gd` — cada skill separada por herói

**Fase 4 — heróis reais**
`herois/lee_sin.gd`, `herois/jinx.gd` etc — cada herói um arquivo, carrega do `herois.json`

**Fase 5 — itens e economia**
`loja.gd` — interface de compra
`inventario.gd` — 6 slots, carrega do `itens.json`

**Fase 6 — bots**
`bot_controller.gd` — IA simples que segue rota e ataca

---

## Como você cria coisas novas

Quer adicionar um herói novo? Edita só o `herois.json` — nome, skills, atributos, lore. O jogo carrega automaticamente.

Quer mudar dano de uma torre? Edita o `torre.gd` — um número.

Quer adicionar um item novo? Edita o `itens.json` — nome, custo, atributos.

Tudo JSON ou um arquivo GDScript isolado. Nunca mexe em vários arquivos pra uma mudança.
