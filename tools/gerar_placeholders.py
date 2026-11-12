# -*- coding: utf-8 -*-
"""
Gera os GRÁFICOS PROVISÓRIOS (placeholders) do jogo "Névoa e Aço".

Você NÃO precisa rodar este script: as imagens já estão no projeto.
Ele existe só para recriar os placeholders se você apagar algum.

Para rodar (no terminal, dentro da pasta do projeto):
    pip install --user pillow
    python3 tools/gerar_placeholders.py

Quando você desenhar sua pixel art, basta SALVAR POR CIMA do PNG com o mesmo
nome e o mesmo tamanho. O Godot recarrega sozinho.
"""
from pathlib import Path
from PIL import Image

RAIZ = Path(__file__).resolve().parent.parent
T = 16  # tamanho de um "tile"/quadro em pixels

# ---------------------------------------------------------------- paleta ----
TRANSP = (0, 0, 0, 0)
PRETO = (20, 16, 24, 255)
PELE = (240, 196, 160, 255)
RUIVO = (196, 64, 32, 255)
RUIVO_ESC = (140, 40, 24, 255)
AZUL_FAIXA = (64, 140, 230, 255)
AZUL_MARINHO = (28, 40, 88, 255)
AZUL_MARINHO_CL = (44, 60, 120, 255)
AMARELO = (255, 220, 90, 255)
PRATA = (190, 196, 210, 255)
PRATA_ESC = (120, 126, 144, 255)
PRATA_CL = (232, 236, 244, 255)
OLHO_AZUL = (110, 220, 255, 255)
MARROM = (120, 80, 48, 255)
MARROM_ESC = (80, 52, 32, 255)
VERDE = (72, 140, 60, 255)


def nova(w, h):
    return Image.new("RGBA", (w, h), TRANSP)


def ret(img, x, y, w, h, cor, ox=0, oy=0):
    """Pinta um retângulo cheio (x, y relativos ao quadro com origem ox, oy)."""
    for i in range(w):
        for j in range(h):
            img.putpixel((ox + x + i, oy + y + j), cor)


def px(img, x, y, cor, ox=0, oy=0):
    img.putpixel((ox + x, oy + y), cor)


# ------------------------------------------------------------- personagens --
# Convenção das folhas de sprites (spritesheets) de personagens:
#   - cada quadro tem 16x16 pixels
#   - LINHAS = direção:  0 = baixo, 1 = cima, 2 = esquerda, 3 = direita
#   - COLUNAS = quadros de animação de caminhada (0 e 1)
#   => imagem final de 32 x 64 pixels

def pernas(img, ox, oy, quadro, cor):
    # Alterna as pernas para dar ideia de passo.
    if quadro == 0:
        ret(img, 5, 13, 2, 3, cor, ox, oy)
        ret(img, 9, 13, 2, 2, cor, ox, oy)
    else:
        ret(img, 5, 13, 2, 2, cor, ox, oy)
        ret(img, 9, 13, 2, 3, cor, ox, oy)


def desenha_lia(img, ox, oy, direcao, quadro):
    pernas(img, ox, oy, quadro, MARROM_ESC)
    # capa azul-marinho (corpo)
    ret(img, 4, 8, 8, 6, AZUL_MARINHO, ox, oy)
    ret(img, 5, 8, 6, 1, AZUL_MARINHO_CL, ox, oy)
    # cabeça
    ret(img, 5, 2, 6, 6, PELE, ox, oy)
    # cabelo ruivo curto
    ret(img, 4, 1, 8, 3, RUIVO, ox, oy)
    ret(img, 4, 4, 1, 3, RUIVO, ox, oy)
    ret(img, 11, 4, 1, 3, RUIVO, ox, oy)
    # faixa azul na testa
    ret(img, 4, 3, 8, 1, AZUL_FAIXA, ox, oy)
    if direcao == 0:  # baixo: olhos e lanterna na frente
        px(img, 6, 5, PRETO, ox, oy)
        px(img, 9, 5, PRETO, ox, oy)
        ret(img, 11, 10, 2, 2, AMARELO, ox, oy)
    elif direcao == 1:  # cima: só cabelo e capa
        ret(img, 5, 4, 6, 3, RUIVO_ESC, ox, oy)
        ret(img, 4, 3, 8, 1, AZUL_FAIXA, ox, oy)
    elif direcao == 2:  # esquerda
        px(img, 6, 5, PRETO, ox, oy)
        ret(img, 9, 4, 3, 3, RUIVO, ox, oy)
        ret(img, 2, 10, 2, 2, AMARELO, ox, oy)
    else:  # direita
        px(img, 9, 5, PRETO, ox, oy)
        ret(img, 4, 4, 3, 3, RUIVO, ox, oy)
        ret(img, 12, 10, 2, 2, AMARELO, ox, oy)


def desenha_eco(img, ox, oy, direcao, quadro):
    pernas(img, ox, oy, quadro, PRATA_ESC)
    # corpo de armadura (maior que a Lia)
    ret(img, 3, 7, 10, 7, PRATA, ox, oy)
    ret(img, 3, 7, 10, 1, PRATA_CL, ox, oy)
    # elmo
    ret(img, 4, 0, 8, 7, PRATA, ox, oy)
    ret(img, 4, 0, 8, 1, PRATA_CL, ox, oy)
    if direcao == 1:  # de costas
        ret(img, 7, 1, 2, 5, PRATA_ESC, ox, oy)
        return
    # viseira escura (o elmo é vazio!) com olhos azuis brilhando
    ret(img, 5, 3, 6, 2, PRETO, ox, oy)
    if direcao == 0:
        px(img, 6, 3, OLHO_AZUL, ox, oy)
        px(img, 9, 3, OLHO_AZUL, ox, oy)
        # escudo enorme na frente
        ret(img, 9, 8, 5, 6, AZUL_MARINHO, ox, oy)
        ret(img, 11, 9, 1, 4, PRATA_CL, ox, oy)
    elif direcao == 2:
        px(img, 5, 3, OLHO_AZUL, ox, oy)
        ret(img, 1, 7, 4, 7, AZUL_MARINHO, ox, oy)
    else:
        px(img, 10, 3, OLHO_AZUL, ox, oy)
        ret(img, 11, 7, 4, 7, AZUL_MARINHO, ox, oy)


def desenha_aldeao(img, ox, oy, direcao, quadro):
    pernas(img, ox, oy, quadro, MARROM_ESC)
    ret(img, 4, 8, 8, 6, VERDE, ox, oy)
    ret(img, 5, 2, 6, 6, PELE, ox, oy)
    ret(img, 4, 1, 8, 2, MARROM, ox, oy)  # chapéu
    ret(img, 3, 2, 10, 1, MARROM_ESC, ox, oy)
    if direcao == 0:
        px(img, 6, 5, PRETO, ox, oy)
        px(img, 9, 5, PRETO, ox, oy)
    elif direcao == 2:
        px(img, 6, 5, PRETO, ox, oy)
    elif direcao == 3:
        px(img, 9, 5, PRETO, ox, oy)


def folha_personagem(funcao_desenho, nome_arquivo):
    img = nova(T * 2, T * 4)
    for direcao in range(4):
        for quadro in range(2):
            funcao_desenho(img, quadro * T, direcao * T, direcao, quadro)
    img.save(RAIZ / "assets/sprites/personagens" / nome_arquivo)


# ----------------------------------------------------------------- inimigo --
def gerar_lobo():
    # Lobo da Névoa: 32x32, um quadro só por enquanto.
    img = nova(32, 32)
    CINZA = (110, 104, 140, 255)
    CINZA_ESC = (70, 64, 100, 255)
    NEVOA = (190, 186, 220, 160)
    ret(img, 6, 12, 20, 10, CINZA)          # corpo
    ret(img, 2, 8, 10, 9, CINZA)            # cabeça
    ret(img, 2, 5, 3, 4, CINZA_ESC)         # orelha
    ret(img, 8, 5, 3, 4, CINZA_ESC)         # orelha
    ret(img, 0, 13, 3, 3, CINZA_ESC)        # focinho
    px(img, 5, 11, (255, 80, 80, 255))      # olho vermelho
    px(img, 9, 11, (255, 80, 80, 255))
    for x in (8, 12, 20, 24):               # patas
        ret(img, x, 22, 2, 6, CINZA_ESC)
    ret(img, 26, 10, 5, 3, CINZA)           # rabo
    for (x, y) in ((4, 26), (12, 28), (20, 27), (27, 25), (1, 22), (29, 18)):
        ret(img, x, y, 3, 2, NEVOA)         # fiapos de névoa
    img.save(RAIZ / "assets/sprites/inimigos/lobo_nevoa.png")


def gerar_armadura_caida():
    # Sir Eco caído na areia, deitado de lado: 32x16, um quadro só.
    img = nova(32, 16)
    ret(img, 2, 5, 9, 8, PRATA)             # elmo (à esquerda)
    ret(img, 2, 5, 9, 1, PRATA_CL)
    ret(img, 4, 7, 2, 5, PRETO)             # viseira vazia
    px(img, 4, 8, OLHO_AZUL)                # olhos ainda com um brilho fraco
    px(img, 4, 10, OLHO_AZUL)
    ret(img, 11, 4, 12, 9, PRATA)           # peitoral
    ret(img, 11, 4, 12, 1, PRATA_CL)
    ret(img, 23, 6, 8, 3, PRATA_ESC)        # pernas
    ret(img, 23, 10, 8, 3, PRATA_ESC)
    ret(img, 12, 12, 9, 4, AZUL_MARINHO)    # escudo enorme por baixo
    ret(img, 15, 13, 3, 2, PRATA_CL)
    img.save(RAIZ / "assets/sprites/personagens/armadura_caida.png")


def gerar_fiapo():
    # Fiapo de Névoa: inimigo fraco de teste, 16x16, olhando para a esquerda.
    img = nova(16, 16)
    NEVOA = (200, 196, 230, 255)
    NEVOA_ESC = (140, 134, 180, 255)
    ret(img, 4, 2, 8, 9, NEVOA)
    ret(img, 3, 4, 10, 6, NEVOA)
    ret(img, 3, 10, 3, 3, NEVOA_ESC)
    ret(img, 7, 11, 3, 4, NEVOA_ESC)
    ret(img, 11, 10, 2, 3, NEVOA_ESC)
    ret(img, 5, 5, 2, 2, PRETO)             # olhos
    ret(img, 9, 5, 2, 2, PRETO)
    px(img, 5, 5, OLHO_AZUL)
    px(img, 9, 5, OLHO_AZUL)
    img.save(RAIZ / "assets/sprites/inimigos/fiapo_nevoa.png")


# ----------------------------------------------------------------- tileset --
# tileset_vila.png: 8 colunas x 2 linhas de tiles 16x16 (128 x 32 pixels)
#  Linha 0: 0 grama | 1 grama c/ flor | 2 caminho | 3 areia | 4 água | 5 espuma | 6 rocha | 7 árvore
#  Linha 1: 0 parede | 1 telhado | 2 porta | 3 janela | 4 cerca | 5 piso madeira | 6 (livre) | 7 (livre)
def gerar_tileset():
    img = nova(T * 8, T * 2)

    def tile(col, lin, base, detalhes=()):
        ox, oy = col * T, lin * T
        ret(img, 0, 0, T, T, base, ox, oy)
        for (x, y, w, h, cor) in detalhes:
            ret(img, x, y, w, h, cor, ox, oy)

    G = (88, 160, 72, 255)
    G2 = (70, 136, 58, 255)
    tile(0, 0, G, [(3, 4, 1, 2, G2), (11, 9, 1, 2, G2), (6, 12, 1, 2, G2)])
    tile(1, 0, G, [(3, 4, 1, 2, G2), (10, 6, 2, 2, (240, 90, 120, 255)),
                   (4, 11, 2, 2, (250, 240, 120, 255))])
    tile(2, 0, (176, 140, 92, 255), [(4, 5, 2, 1, (150, 116, 74, 255)),
                                     (10, 11, 2, 1, (150, 116, 74, 255))])
    tile(3, 0, (236, 214, 150, 255), [(5, 3, 1, 1, (210, 186, 124, 255)),
                                      (12, 10, 1, 1, (210, 186, 124, 255))])
    tile(4, 0, (52, 112, 200, 255), [(3, 5, 4, 1, (90, 150, 230, 255)),
                                     (9, 11, 4, 1, (90, 150, 230, 255))])
    tile(5, 0, (80, 140, 220, 255), [(0, 0, 16, 2, (230, 240, 255, 255)),
                                     (4, 6, 3, 1, (160, 200, 250, 255))])
    tile(6, 0, G, [(2, 3, 12, 11, (120, 120, 130, 255)),
                   (3, 4, 6, 2, (160, 160, 170, 255))])
    tile(7, 0, G, [(6, 10, 4, 6, MARROM), (1, 0, 14, 11, (40, 110, 50, 255)),
                   (3, 2, 4, 3, (70, 150, 70, 255))])

    tile(0, 1, (200, 180, 150, 255), [(0, 7, 16, 1, (170, 150, 120, 255)),
                                      (0, 15, 16, 1, (170, 150, 120, 255))])
    tile(1, 1, (170, 60, 50, 255), [(0, 3, 16, 1, (130, 40, 36, 255)),
                                    (0, 8, 16, 1, (130, 40, 36, 255)),
                                    (0, 13, 16, 1, (130, 40, 36, 255))])
    tile(2, 1, (200, 180, 150, 255), [(4, 3, 8, 13, MARROM),
                                      (10, 9, 1, 1, AMARELO)])
    tile(3, 1, (200, 180, 150, 255), [(4, 4, 8, 7, (90, 140, 200, 255)),
                                      (7, 4, 2, 7, MARROM_ESC),
                                      (4, 7, 8, 1, MARROM_ESC)])
    tile(4, 1, G, [(0, 5, 16, 2, MARROM), (0, 10, 16, 2, MARROM),
                   (2, 3, 2, 11, MARROM_ESC), (12, 3, 2, 11, MARROM_ESC)])
    tile(5, 1, (160, 110, 70, 255), [(0, 5, 16, 1, (130, 86, 52, 255)),
                                     (0, 11, 16, 1, (130, 86, 52, 255))])
    img.save(RAIZ / "assets/tiles/tileset_vila.png")


def gerar_icone():
    img = nova(32, 32)
    ret(img, 0, 0, 32, 32, AZUL_MARINHO)
    ret(img, 12, 6, 8, 2, PRATA)            # alça da lanterna
    ret(img, 10, 8, 12, 16, PRATA_ESC)      # lanterna
    ret(img, 12, 10, 8, 12, AMARELO)        # luz
    ret(img, 14, 12, 4, 8, (255, 250, 210, 255))
    ret(img, 9, 24, 14, 2, PRATA)
    img.save(RAIZ / "icon.png")


if __name__ == "__main__":
    folha_personagem(desenha_lia, "lia.png")
    folha_personagem(desenha_eco, "sir_eco.png")
    folha_personagem(desenha_aldeao, "aldeao.png")
    gerar_armadura_caida()
    gerar_lobo()
    gerar_fiapo()
    gerar_tileset()
    gerar_icone()
    print("Placeholders gerados!")
