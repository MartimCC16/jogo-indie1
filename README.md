# Névoa e Aço

RPG de fantasia medieval em pixel art feito em **Godot 4** com **GDScript**.

> O Reino de Vésper está coberto pela Névoa do Esquecimento. Lia, uma escudeira,
> e Sir Eco, uma armadura viva e vazia, partem para reacender as cinco Torres de Luz
> e enfrentar Malvoran, o Rei Caído.

## Planejamento

- `docs/cenarios_das_fases.md` — as regiões/fases do jogo, chefes, mecânicas e lista de arte.
- `docs/paletas_das_fases.png` — paleta de cores de cada região.

## Como abrir o projeto

1. Abra o Godot (Flatpak) → **Importar** → escolha o arquivo `project.godot` desta pasta.
2. Aperte **F5** (ou o botão ▶ no canto superior direito) para rodar.

## Onde fica cada coisa

| Pasta | O que guarda |
|---|---|
| `scenes/` | Cenas do Godot (`.tscn`): mapas, personagens, telas. |
| `scenes/mundo/` | Mapas jogáveis (Vila Âncora, praia, futuras regiões). |
| `scenes/personagens/` | Jogador, NPCs, a armadura do Sir Eco. |
| `scenes/ui/` | Interface: caixa de diálogo, menus, barras de vida. |
| `scenes/combate/` | A tela de batalha por turnos. |
| `scenes/teste/` | Cenas só para testar coisas (podem ser apagadas). |
| `scripts/` | Código GDScript (`.gd`), com as mesmas subpastas das cenas. |
| `scripts/autoload/` | Scripts "globais" que existem o jogo todo (ex.: estado do jogo). |
| `assets/sprites/` | Imagens dos personagens e inimigos. |
| `assets/tiles/` | Tilesets (os "azulejos" que formam os mapas). |
| `assets/fontes/`, `assets/sons/` | Fontes e áudio (vazias por enquanto). |
| `dialogues/` | Diálogos em JSON — dá para editar sem mexer em código. |
| `data/` | Dados do jogo em JSON: status de personagens, inimigos, magias. |
| `tools/` | Scripts auxiliares fora do jogo (ex.: gerador de placeholders). |

## Estilo visual

Paleta **viva e quente** (grama verde-limão, telhados vermelhos, madeira alaranjada,
água azul brilhante) com **contorno colorido** (cor vizinha escurecida, em vez de preto).
A interface usa caixas **creme com borda de madeira** (`assets/ui/tema.tres`).
Dica: sua arte vai combinar se você usar sombras puxando para o azul/roxo e luzes
puxando para o amarelo, e evitar o preto puro.

## Gráficos provisórios (para você trocar depois)

Todas as imagens são **placeholders** gerados por `tools/gerar_placeholders.py`.
Para colocar sua arte, **salve por cima do PNG com o mesmo nome e o mesmo tamanho**.

### Folhas de personagem (`lia.png`, `sir_eco.png`, `aldeao.png`) — 32×64 px
Cada quadro tem **16×16**. Colunas = quadros da caminhada (2). Linhas = direção:

| Linha | Direção |
|---|---|
| 0 | baixo |
| 1 | cima |
| 2 | esquerda |
| 3 | direita |

### `tileset_vila.png` — 128×48 px (8×3 tiles de 16×16)
- Linha 0: grama, grama com flor, caminho, areia, água, espuma, rocha, árvore
- Linha 1: parede, telhado, porta, janela, cerca, piso de madeira, bloqueio invisível, (livre)
- Linha 2: 3 variações de grama, variação de areia, variação de água (o mapa sorteia entre elas)

Rocha, cerca e arvorezinha têm **fundo transparente** (o chão de baixo aparece).

### `assets/sprites/cenario/arvore_grande.png` — 192×80 px
4 quadros de 48×80 (3×5 tiles): **primavera, verão, outono, inverno**. A base do tronco
fica no centro de baixo de cada quadro (x = 24, y = 76). Gerada por `tools/gerar_arvores.py`.
Cena: `scenes/mundo/arvore.tscn` — escolha a **Estacao** no Inspetor. Só o tronco tem colisão.

### `armadura_caida.png` — 32×16 px (Sir Eco deitado na areia, antes do evento)

### `fiapo_nevoa.png` — 16×16 px (inimigo de teste)

### `lobo_nevoa.png` — 32×32 px (chefe, um quadro só por enquanto)

Inimigos são desenhados **olhando para a esquerda**; a batalha espelha o sprite.

## Mapas em texto (`data/mapas/*.txt`)

Os mapas são desenhados com letras — cada letra é um tile de 16×16.
A legenda está no topo de `data/mapas/vila_ancora.txt` e em `scripts/mundo/mapa_de_texto.gd`
(constante `LEGENDA`). Depois de editar o texto, abra a cena do mapa, selecione o nó
**Mapa** e clique em **Gerar mapa a partir do texto** no Inspetor; depois salve com Ctrl+S.

Colisão: definida no `assets/tiles/tileset_vila.tres` (água, rocha, árvore, cerca e casas bloqueiam).

> Ao exportar o jogo no futuro, adicione `*.txt, *.json` em
> **Exportar → Recursos → Filtros para exportar arquivos que não são recursos**.

## Diálogos em JSON (`dialogues/`)

- `dialogues/personagens.json` — nome exibido e cor de cada personagem.
- `dialogues/vila_ancora.json` — as conversas da vila. Formato:

```json
{
  "tome_inicio": [
    { "quem": "tome", "texto": "Ah, Lia! Acordada tão cedo?" },
    { "quem": "lia",  "texto": "Bom dia, Tomé." }
  ]
}
```

- `"tome_inicio"` é o **ID** da conversa (é ele que o NPC usa no Inspetor).
- `"quem"` é uma chave de `personagens.json`. Use `"narrador"` para texto sem nome.
- Cada `"texto"` deve ter até ~110 letras para caber na caixa.
- Cuidado com as vírgulas: entre falas sim, depois da última não. Se errar,
  o Godot mostra no painel **Depurador** a linha do erro.

Para usar em código: `await Dialogo.iniciar("res://dialogues/vila_ancora.json", "tome_inicio")`

## Eventos (cenas com roteiro)

O evento da praia está em `scripts/mundo/evento_despertar_eco.gd`. A função
`_executar_cena()` é um **roteiro** que se lê de cima para baixo; cada `await` quer
dizer "espere isto terminar". As falas dele estão em `dialogues/praia.json`.

Flags usadas até agora: `conversou_tome`, `eco_despertou`, `luta_lobo_iniciada`, `lobo_derrotado`.

**Roteiro do prólogo:** falar com o Tomé → examinar a armadura na praia → Sir Eco
desperta → o Lobo da Névoa aparece → batalha de chefe com tutorial
(`dialogues/tutorial.json`) → volta à vila → conversa final (`pos_lobo`) → tela
"Fim do Prólogo" → exploração livre.

NPCs mudam de fala conforme a história pelo campo **Dialogos Por Flag** no Inspetor
(ex.: `{"eco_despertou": "tome_eco", "lobo_derrotado": "tome_pos_lobo"}`).

**Fúria dos chefes:** em `data/inimigos.json`, o bloco `"furia"` faz o chefe ficar
mais forte quando a vida cai abaixo do limite.

## Combate (`scenes/combate/batalha.tscn`)

| Arquivo | O que tem |
|---|---|
| `data/herois.json` | Vida, mana, ataque, defesa, magia, velocidade e magias de cada herói. |
| `data/inimigos.json` | Status, fraquezas, resistências e ataques de cada inimigo. |
| `data/magias.json` | Fogo, Gelo, Raio, Luz: custo, poder, tipo (dano/cura), elemento, cor. |
| `scripts/combate/batalha.gd` | O roteiro da batalha (turnos, menus, efeitos). |
| `scripts/combate/formulas.gd` | As contas de dano e cura (balanceamento). |
| `scripts/combate/barra_timing.gd` | A barra de timing do ataque. |
| `scripts/combate/menu_batalha.gd` | O menu de opções. |
| `scripts/combate/combatente.gd` | Os dados de um lutador durante a luta. |

**Timing no ataque:** aperte AÇÃO com o cursor na faixa dourada clara
(Perfeito ×1,5), na faixa escura ao redor (Bom ×1,0) ou fora (Fraco ×0,6).

**Timing na defesa:** quando o inimigo avança, aparece um **!** — aperte AÇÃO
nesse momento para bloquear (dano ×0,25). Apertar antes do **!** não vale.

**Defender:** toma metade do dano até o próximo turno e recupera 2 PM.
Sir Eco (`protege_aliados`) atrai os ataques para si quando defende.

Para iniciar uma batalha a partir de um mapa:
`EstadoJogo.iniciar_batalha(["lobo_nevoa"], "res://scenes/mundo/vila_ancora.tscn")`

## Autoloads (scripts globais)

| Nome | Arquivo | Para quê |
|---|---|---|
| `EstadoJogo` | `scripts/autoload/estado_jogo.gd` | Flags da história (o que já aconteceu). |
| `Dialogo` | `scenes/ui/caixa_dialogo.tscn` | A caixa de diálogo. |

Ficam em **Projeto → Configurações do Projeto → Globais** (aba Autoload).

## Visual da interface

`assets/ui/tema.tres` é o **tema** do jogo inteiro: tamanho da fonte, cor do texto e
estilo das caixas. Dê dois cliques nele no Godot para editar. Para usar uma fonte
pixel art, coloque o arquivo `.ttf` em `assets/fontes/` e escolha-o em
**Default Font** no tema.

## Controles

| Ação | Teclas |
|---|---|
| Mover | Setas ou WASD |
| Ação / confirmar / timing | Z, Espaço ou Enter |
| Cancelar | X ou Esc |

Para mudar: **Projeto → Configurações do Projeto → aba Mapa de Entrada**.

## Progresso

- [x] Etapa 1 — estrutura, configuração pixel art, placeholders
- [x] Etapa 2 — Vila Âncora (tilemap gerado a partir de texto)
- [x] Etapa 3 — Lia andando, colisão e câmera
- [x] Etapa 4 — Diálogo com JSON + NPC
- [x] Etapa 5 — Evento da praia (Sir Eco desperta e passa a seguir a Lia)
- [x] Etapa 6 — Combate por turnos com timing
- [x] Etapa 7 — Chefe: Lobo da Névoa (com tutorial) e final do prólogo
