# Névoa e Aço

RPG de fantasia medieval em pixel art feito em **Godot 4** com **GDScript**.

> O Reino de Vésper está coberto pela Névoa do Esquecimento. Lia, uma escudeira,
> e Sir Eco, uma armadura viva e vazia, partem para reacender as cinco Torres de Luz
> e enfrentar Malvoran, o Rei Caído.

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

### `tileset_vila.png` — 128×32 px (8×2 tiles de 16×16)
- Linha 0: grama, grama com flor, caminho, areia, água, espuma, rocha, árvore
- Linha 1: parede, telhado, porta, janela, cerca, piso de madeira, (livre), (livre)

### `lobo_nevoa.png` — 32×32 px (chefe, um quadro só por enquanto)

## Controles

| Ação | Teclas |
|---|---|
| Mover | Setas ou WASD |
| Ação / confirmar / timing | Z, Espaço ou Enter |
| Cancelar | X ou Esc |

Para mudar: **Projeto → Configurações do Projeto → aba Mapa de Entrada**.

## Progresso

- [x] Etapa 1 — estrutura, configuração pixel art, placeholders
- [ ] Etapa 2 — Vila Âncora (tilemap)
- [ ] Etapa 3 — Lia andando, colisão e câmera
- [ ] Etapa 4 — Diálogo com JSON + NPC
- [ ] Etapa 5 — Evento da praia (Sir Eco desperta)
- [ ] Etapa 6 — Combate por turnos com timing
- [ ] Etapa 7 — Chefe: Lobo da Névoa
