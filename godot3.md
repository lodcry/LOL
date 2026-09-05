## O que esse script te dá

É um conjunto de scripts GDScript + cenas para um **jogo MOBA no Godot 4** chamado **Ventory** (estilo League of Legends). Aqui o que cada parte cria:

---

### Telas UI
| Arquivo | O que é |
|---|---|
| `perfil_ui.gd` | Tela de perfil do jogador com stats, botão Jogar e cards de features |
| `selecao_heroi_ui.gd` | Seleção de herói com **preview 3D girando**, abas de runas e feitiços |
| `fila_ui.gd` | Tela de matchmaking com timer e lista de jogadores na fila |
| `loja_ui.gd` | Loja in-game com grid de itens e integração com inventário |

### Sistemas de jogo
| Arquivo | O que é |
|---|---|
| `heroi.gd` | HP, mana, XP, level up, morte e respawn |
| `torre.gd` | Torre com agro automático em range |
| `projetil.gd` | Projétil com homing no alvo |
| `skill_base.gd` | Classe base para habilidades com cooldown e custo de mana |
| `bot_controller.gd` | IA de bot com estados (idle, movendo, atacando) |
| `inventario.gd` | 6 slots de item, sistema de ouro, compra/venda |

---

### Conteúdo embutido
- **10 heróis** (Lee Sin, Jinx, Lux, Darius...) com dados completos
- **6 runas** e **8 feitiços** de invocador
- Cenas `.tscn` prontas para perfil, seleção e fila

---

### O que **não** funciona ainda
- `scenes/partida.tscn` — referenciada mas não criada
- `data/itens.json` — a loja carrega desse arquivo mas ele não existe no script
- A linha `sed` de autoloads pode **duplicar entradas** no `project.godot` se rodar mais de uma vez

Quer que eu identifique o que falta pra rodar sem erro?


## Análise completa — o que tem e o que falta

### ❌ **Nada disso existe no código**

---

### Minions
- ❌ Nenhum script de minion
- ❌ Sem spawn wave com timer
- ❌ Sem rota de minion por lane
- ❌ Sem ouro por last hit

---

### Tempo / Fim de Jogo
- ❌ Sem timer de partida (00:00 crescendo)
- ❌ Sem condição de vitória
- ❌ Sem tela de fim de jogo
- ❌ **Nexus não existe** — nem como Node, nem como objeto destrutível

---

### Objetivos do Mapa
- ❌ **Dragon** — nenhum script
- ❌ **Baron** — nenhum script
- ❌ **Red Buff** — sem efeito de queimar/slow
- ❌ **Blue Buff** — sem regen de mana/CDR
- ❌ Sem spawn timer de objetivos

---

### Status / Efeitos
- ❌ Sem sistema de DoT (queimar, veneno)
- ❌ Sem regen de HP/mana por tick
- ❌ Sem buff/debuff stack

---

### Resumo brutal

O código atual tem **lobby e UI bonita**, mas o jogo em si praticamente **não existe ainda**. É uma casca.

---

Quer que eu monte a ordem de prioridade do que implementar primeiro?


## Problema identificado no `fila_ui.gd`

### Por que trava

```gdscript
func _on_jogador_fila(...) -> void:
    # Só avança se alguém entrar via WebSocket
    if jogadores_na_fila.size() >= 1:
        get_tree().change_scene_to_file("res://scenes/partida.tscn")
```

**Depende 100% do WebSocket funcionar** — se ninguém conectar, fica parado pra sempre. Sem timeout, sem fallback.

---

### O que falta implementar

**1. Tela de seleção de modo ANTES da fila**
```
[ ⚔️ Jogar vs IA ]    [ 🌐 Ranked Online ]
```

**2. Vs IA** — pula fila, vai direto com bots

**3. Ranked Online** — entra na fila com:
- Timer de 1 minuto
- Se não completar o time → preenche com bots e começa
- Botão **Pausar Busca** que salva seu estado
- Botão **Retomar** que volta de onde parou sem perder posição

**4. Indicador de progresso real**

```
[██████░░░░] 6/10 jogadores   00:47
```

---

### Ordem de correção

1. Criar cena `modo_jogo.tscn` com os dois botões
2. Corrigir `fila_ui.gd` com timeout de 60s + fallback de bots
3. Implementar pause/resume da fila

---

Quer que eu escreva o código corrigido começando pelo quê — seleção de modo ou o timeout da fila?


