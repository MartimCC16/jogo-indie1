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
# Paleta VIVA e quente (cores saturadas, estilo "fazendinha aconchegante").
TRANSP = (0, 0, 0, 0)
PRETO = (46, 26, 40, 255)
PELE = (255, 212, 166, 255)
PELE_ESC = (232, 162, 120, 255)
RUIVO = (236, 100, 40, 255)
RUIVO_ESC = (178, 58, 30, 255)
RUIVO_CL = (255, 156, 72, 255)
AZUL_FAIXA = (56, 152, 255, 255)
AZUL_MARINHO = (40, 58, 136, 255)
AZUL_MARINHO_CL = (70, 98, 190, 255)
CAMISA = (248, 238, 214, 255)
AMARELO = (255, 214, 72, 255)
AMARELO_CL = (255, 248, 170, 255)
PRATA = (200, 210, 228, 255)
PRATA_ESC = (126, 136, 168, 255)
PRATA_CL = (244, 248, 255, 255)
OLHO_AZUL = (90, 230, 255, 255)
MARROM = (150, 88, 44, 255)
MARROM_ESC = (100, 56, 32, 255)
VERDE = (80, 170, 64, 255)
VERDE_ESC = (46, 120, 52, 255)


def nova(w, h):
    return Image.new("RGBA", (w, h), TRANSP)


def ret(img, x, y, w, h, cor, ox=0, oy=0):
    """Pinta um retângulo cheio (x, y relativos ao quadro com origem ox, oy)."""
    for i in range(w):
        for j in range(h):
            img.putpixel((ox + x + i, oy + y + j), cor)


def px(img, x, y, cor, ox=0, oy=0):
    img.putpixel((ox + x, oy + y), cor)


def contorno(img, fator=0.38, area=None):
    """Desenha um contorno escuro e COLORIDO em volta do desenho.
    A cor do contorno é a cor vizinha escurecida (fica mais vivo que preto)."""
    x0, y0, x1, y1 = area or (0, 0, img.width, img.height)
    copia = img.copy()
    for y in range(y0, y1):
        for x in range(x0, x1):
            if copia.getpixel((x, y))[3] != 0:
                continue
            for dx, dy in ((0, 1), (1, 0), (-1, 0), (0, -1)):
                nx, ny = x + dx, y + dy
                if x0 <= nx < x1 and y0 <= ny < y1:
                    r, g, b, a = copia.getpixel((nx, ny))
                    if a == 255:
                        img.putpixel((x, y), (int(r * fator), int(g * fator), int(b * fator), 255))
                        break


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
    # capa azul-marinho (corpo), com luz à esquerda
    ret(img, 4, 8, 8, 6, AZUL_MARINHO, ox, oy)
    ret(img, 4, 8, 2, 5, AZUL_MARINHO_CL, ox, oy)
    if direcao != 1:
        ret(img, 7, 8, 2, 4, CAMISA, ox, oy)       # camisa aparecendo
    # cabeça
    ret(img, 5, 2, 6, 6, PELE, ox, oy)
    ret(img, 10, 3, 1, 5, PELE_ESC, ox, oy)
    # cabelo ruivo curto
    ret(img, 4, 1, 8, 3, RUIVO, ox, oy)
    ret(img, 5, 1, 4, 1, RUIVO_CL, ox, oy)
    ret(img, 4, 4, 1, 3, RUIVO_ESC, ox, oy)
    ret(img, 11, 4, 1, 3, RUIVO_ESC, ox, oy)
    # faixa azul na testa
    ret(img, 4, 3, 8, 1, AZUL_FAIXA, ox, oy)
    if direcao == 0:  # baixo
        ret(img, 6, 5, 1, 2, PRETO, ox, oy)
        ret(img, 9, 5, 1, 2, PRETO, ox, oy)
        px(img, 6, 7, (255, 160, 150, 255), ox, oy)  # bochechas
        px(img, 9, 7, (255, 160, 150, 255), ox, oy)
        ret(img, 12, 10, 2, 3, AMARELO, ox, oy)       # lanterna
        px(img, 12, 10, AMARELO_CL, ox, oy)
    elif direcao == 1:  # cima
        ret(img, 5, 4, 6, 3, RUIVO, ox, oy)
        ret(img, 6, 4, 3, 1, RUIVO_CL, ox, oy)
        ret(img, 4, 3, 8, 1, AZUL_FAIXA, ox, oy)
    elif direcao == 2:  # esquerda
        ret(img, 6, 5, 1, 2, PRETO, ox, oy)
        ret(img, 9, 4, 3, 3, RUIVO, ox, oy)
        ret(img, 2, 10, 2, 3, AMARELO, ox, oy)
        px(img, 2, 10, AMARELO_CL, ox, oy)
    else:  # direita
        ret(img, 9, 5, 1, 2, PRETO, ox, oy)
        ret(img, 4, 4, 3, 3, RUIVO, ox, oy)
        ret(img, 12, 10, 2, 3, AMARELO, ox, oy)
        px(img, 13, 10, AMARELO_CL, ox, oy)


def desenha_eco(img, ox, oy, direcao, quadro):
    pernas(img, ox, oy, quadro, PRATA_ESC)
    # corpo de armadura (maior que a Lia)
    ret(img, 3, 8, 10, 6, PRATA, ox, oy)
    ret(img, 3, 8, 10, 1, PRATA_CL, ox, oy)
    ret(img, 11, 9, 2, 5, PRATA_ESC, ox, oy)
    ret(img, 7, 9, 2, 3, AZUL_FAIXA, ox, oy)  # emblema azul no peito
    # elmo
    ret(img, 4, 1, 8, 7, PRATA, ox, oy)
    ret(img, 4, 1, 8, 1, PRATA_CL, ox, oy)
    ret(img, 5, 2, 1, 4, PRATA_CL, ox, oy)
    ret(img, 11, 2, 1, 5, PRATA_ESC, ox, oy)
    ret(img, 7, 0, 2, 1, (220, 60, 60, 255), ox, oy)  # penacho vermelho
    if direcao == 1:  # de costas
        ret(img, 7, 2, 2, 5, PRATA_ESC, ox, oy)
        return
    # viseira escura (o elmo é vazio!) com olhos azuis brilhando
    ret(img, 5, 4, 6, 2, PRETO, ox, oy)
    if direcao == 0:
        px(img, 6, 4, OLHO_AZUL, ox, oy)
        px(img, 9, 4, OLHO_AZUL, ox, oy)
        ret(img, 9, 9, 5, 5, AZUL_MARINHO, ox, oy)   # escudo enorme
        ret(img, 9, 9, 5, 1, AZUL_MARINHO_CL, ox, oy)
        ret(img, 11, 10, 1, 3, AMARELO, ox, oy)
    elif direcao == 2:
        px(img, 5, 4, OLHO_AZUL, ox, oy)
        ret(img, 1, 8, 4, 6, AZUL_MARINHO, ox, oy)
        ret(img, 2, 10, 1, 2, AMARELO, ox, oy)
    else:
        px(img, 10, 4, OLHO_AZUL, ox, oy)
        ret(img, 11, 8, 4, 6, AZUL_MARINHO, ox, oy)
        ret(img, 13, 10, 1, 2, AMARELO, ox, oy)


def desenha_aldeao(img, ox, oy, direcao, quadro):
    pernas(img, ox, oy, quadro, MARROM_ESC)
    ret(img, 4, 8, 8, 6, VERDE, ox, oy)
    ret(img, 4, 8, 2, 5, (120, 200, 90, 255), ox, oy)
    ret(img, 4, 11, 8, 1, MARROM, ox, oy)            # cinto
    ret(img, 5, 3, 6, 5, PELE, ox, oy)
    ret(img, 10, 4, 1, 4, PELE_ESC, ox, oy)
    ret(img, 5, 7, 6, 1, (236, 236, 236, 255), ox, oy)  # barba branca
    ret(img, 4, 1, 8, 2, (232, 190, 90, 255), ox, oy)   # chapéu de palha
    ret(img, 3, 3, 10, 1, (196, 150, 64, 255), ox, oy)
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
            area = (quadro * T, direcao * T, quadro * T + T, direcao * T + T)
            contorno(img, area=area)
    img.save(RAIZ / "assets/sprites/personagens" / nome_arquivo)


# ----------------------------------------------------------------- inimigo --
def gerar_lobo():
    # Lobo da Névoa: 32x32, um quadro só por enquanto.
    img = nova(32, 32)
    CINZA = (132, 122, 206, 255)
    CINZA_ESC = (84, 72, 156, 255)
    NEVOA = (190, 186, 220, 160)
    ret(img, 6, 12, 20, 10, CINZA)          # corpo
    ret(img, 2, 8, 10, 9, CINZA)            # cabeça
    ret(img, 2, 5, 3, 4, CINZA_ESC)         # orelha
    ret(img, 8, 5, 3, 4, CINZA_ESC)         # orelha
    ret(img, 0, 13, 3, 3, CINZA_ESC)        # focinho
    px(img, 5, 11, (255, 150, 40, 255))     # olho cor de brasa
    px(img, 9, 11, (255, 150, 40, 255))
    for x in (8, 12, 20, 24):               # patas
        ret(img, x, 22, 2, 6, CINZA_ESC)
    ret(img, 26, 10, 5, 3, CINZA)           # rabo
    for (x, y) in ((4, 26), (12, 28), (20, 27), (27, 25), (1, 22), (29, 18)):
        ret(img, x, y, 3, 2, NEVOA)         # fiapos de névoa
    contorno(img)
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
    contorno(img)
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
    contorno(img)
    img.save(RAIZ / "assets/sprites/inimigos/fiapo_nevoa.png")


# ----------------------------------------------------------------- tileset --
# tileset_vila.png: 8 colunas x 3 linhas de tiles 16x16 (128 x 48 pixels)
#  Linha 0: 0 grama | 1 grama c/ flor | 2 caminho | 3 areia | 4 água | 5 espuma | 6 rocha | 7 arvorezinha
#  Linha 1: 0 parede | 1 telhado | 2 porta | 3 janela | 4 cerca | 5 piso madeira | 6 bloqueio (vazio) | 7 (livre)
#  Linha 2: 0-2 variações de grama | 3 variação de areia | 4 variação de água | 5-7 (livres)
import random as _random

G_BASE = (108, 196, 52)
G_ESC = (70, 156, 44)
G_ESC2 = (48, 124, 46)
G_CL = (150, 222, 72)
G_BRILHO = (200, 240, 110)
TERRA = (222, 156, 84)
TERRA_ESC = (178, 112, 58)
TERRA_CL = (244, 194, 120)
AREIA = (250, 224, 140)
AREIA_ESC = (226, 188, 106)
AREIA_CL = (255, 244, 190)
AGUA = (44, 146, 236)
AGUA_ESC = (28, 108, 200)
AGUA_CL = (100, 196, 255)
AGUA_BRILHO = (226, 248, 255)


def _base(img, col, lin, cor):
    ret(img, 0, 0, T, T, cor, col * T, lin * T)


def _salpicar(img, col, lin, rnd, cores, quantidade, margem=1):
    for _ in range(quantidade):
        x = rnd.randint(margem, T - 1 - margem)
        y = rnd.randint(margem, T - 1 - margem)
        px(img, x, y, rnd.choice(cores) + (255,), col * T, lin * T)


def _tufos_grama(img, col, lin, rnd, quantidade):
    """Folhinhas de grama em forma de 'v' (escuro embaixo, claro na ponta)."""
    ox, oy = col * T, lin * T
    for _ in range(quantidade):
        x = rnd.randint(1, T - 3)
        y = rnd.randint(2, T - 2)
        px(img, x, y, G_ESC + (255,), ox, oy)
        px(img, x + 2, y, G_ESC + (255,), ox, oy)
        px(img, x + 1, y, G_ESC2 + (255,), ox, oy)
        px(img, x, y - 1, G_CL + (255,), ox, oy)
        px(img, x + 2, y - 1, G_CL + (255,), ox, oy)
        if rnd.random() < 0.3:
            px(img, x + 2, y - 2, G_BRILHO + (255,), ox, oy)


def _grama(img, col, lin, semente, flores=False):
    rnd = _random.Random(semente)
    _base(img, col, lin, G_BASE + (255,))
    _salpicar(img, col, lin, rnd, [G_CL, G_ESC], 10, 0)
    _tufos_grama(img, col, lin, rnd, 4)
    if flores:
        ox, oy = col * T, lin * T
        for (x, y, cor) in ((4, 4, (255, 96, 140)), (11, 9, (255, 240, 90)), (6, 12, (130, 170, 255))):
            for dx, dy in ((0, -1), (-1, 0), (1, 0), (0, 1)):
                px(img, x + dx, y + dy, cor + (255,), ox, oy)
            px(img, x, y, (255, 255, 230, 255), ox, oy)


def _areia(img, col, lin, semente):
    rnd = _random.Random(semente)
    _base(img, col, lin, AREIA + (255,))
    _salpicar(img, col, lin, rnd, [AREIA_ESC, AREIA_ESC, AREIA_CL], 14, 0)


def _agua(img, col, lin, semente):
    rnd = _random.Random(semente)
    ox, oy = col * T, lin * T
    _base(img, col, lin, AGUA + (255,))
    for _ in range(3):  # ondinhas
        x, y = rnd.randint(1, 10), rnd.randint(2, 13)
        ret(img, x, y, 4, 1, AGUA_CL + (255,), ox, oy)
        ret(img, x + 1, y + 1, 3, 1, AGUA_ESC + (255,), ox, oy)
    for _ in range(2):  # brilhos
        px(img, rnd.randint(1, 14), rnd.randint(1, 14), AGUA_BRILHO + (255,), ox, oy)


def gerar_tileset():
    img = nova(T * 8, T * 3)
    a = lambda c: c + (255,)

    # --- linha 0 ---
    _grama(img, 0, 0, 1)
    _grama(img, 1, 0, 2, flores=True)
    # caminho de terra com pedrinhas
    rnd = _random.Random(3)
    _base(img, 2, 0, a(TERRA))
    _salpicar(img, 2, 0, rnd, [TERRA_ESC, TERRA_CL], 12, 0)
    for (x, y) in ((4, 5), (11, 11)):
        ret(img, x, y, 2, 2, a((190, 180, 170)), 2 * T, 0)
        px(img, x, y, a((236, 230, 220)), 2 * T, 0)
        ret(img, x, y + 2, 2, 1, a(TERRA_ESC), 2 * T, 0)
    _areia(img, 3, 0, 4)
    _agua(img, 4, 0, 5)
    # espuma: água com a onda branca encostando na areia (em cima)
    _agua(img, 5, 0, 6)
    ret(img, 0, 0, T, 3, a(AREIA), 5 * T, 0)
    for x in range(T):
        altura = 3 + (1 if (x // 3) % 2 else 0)
        px(img, x, altura, a((255, 255, 255)), 5 * T, 0)
        px(img, x, altura + 1, a((190, 232, 255)), 5 * T, 0)
    # rocha (fundo transparente: o chão de baixo aparece)
    ox = 6 * T
    ret(img, 2, 13, 12, 2, (30, 40, 30, 70), ox, 0)  # sombrinha
    ret(img, 3, 5, 10, 8, a((150, 156, 178)), ox, 0)
    ret(img, 4, 4, 8, 1, a((150, 156, 178)), ox, 0)
    ret(img, 4, 5, 5, 3, a((208, 212, 228)), ox, 0)
    ret(img, 9, 9, 4, 4, a((112, 116, 142)), ox, 0)
    ret(img, 3, 13, 10, 1, a((62, 64, 86)), ox, 0)
    for y in range(4, 13):
        px(img, 2, y + 1, a((62, 64, 86)), ox, 0)
        px(img, 13, y + 1, a((62, 64, 86)), ox, 0)
    ret(img, 4, 3, 8, 1, a((62, 64, 86)), ox, 0)
    # arvorezinha (1 tile, fundo transparente)
    ox = 7 * T
    ret(img, 7, 10, 2, 5, a(MARROM[:3]), ox, 0)
    for (x, y, r) in ((8, 6, 5), (5, 8, 3), (11, 8, 3)):
        for yy in range(-r, r + 1):
            for xx in range(-r, r + 1):
                if xx * xx + yy * yy <= r * r:
                    px(img, x + xx, y + yy, a((60, 170, 60) if yy < 0 else (40, 128, 52)), ox, 0)
    px(img, 6, 3, a((150, 230, 100)), ox, 0)
    px(img, 7, 3, a((150, 230, 100)), ox, 0)

    # --- linha 1 (casa) ---
    oy = T
    MAD = (206, 136, 72)
    MAD_ESC = (150, 90, 46)
    MAD_CL = (236, 176, 104)
    # parede de tábuas
    ret(img, 0, 0, T, T, a(MAD), 0, oy)
    for y in (0, 5, 10, 15):
        ret(img, 0, y, T, 1, a(MAD_ESC), 0, oy)
        ret(img, 0, y + 1, T, 1, a(MAD_CL), 0, oy)
    for (x, y) in ((5, 2), (12, 7), (3, 12)):
        ret(img, x, y, 1, 3, a(MAD_ESC), 0, oy)
    # telhado vermelho com telhas
    TEL = (222, 70, 52)
    TEL_ESC = (160, 38, 44)
    TEL_CL = (250, 124, 80)
    ox = T
    ret(img, 0, 0, T, T, a(TEL), ox, oy)
    for linha, y in enumerate((0, 5, 10)):
        ret(img, 0, y, T, 1, a(TEL_CL), ox, oy)
        ret(img, 0, y + 4, T, 1, a(TEL_ESC), ox, oy)
        desloca = 0 if linha % 2 == 0 else 4
        for x in range(desloca, T, 8):
            ret(img, x, y + 1, 1, 3, a(TEL_ESC), ox, oy)
    # porta
    ox = 2 * T
    ret(img, 0, 0, T, T, a(MAD), ox, oy)
    ret(img, 3, 2, 10, 14, a(MAD_ESC), ox, oy)
    ret(img, 4, 3, 8, 13, a((122, 66, 36)), ox, oy)
    ret(img, 7, 3, 1, 13, a((96, 50, 30)), ox, oy)
    ret(img, 4, 3, 8, 1, a((150, 84, 44)), ox, oy)
    ret(img, 10, 9, 1, 2, a(AMARELO[:3]), ox, oy)
    # janela com vidro brilhando e floreira
    ox = 3 * T
    ret(img, 0, 0, T, T, a(MAD), ox, oy)
    ret(img, 2, 2, 12, 10, a(MAD_ESC), ox, oy)
    ret(img, 3, 3, 10, 8, a((120, 206, 255)), ox, oy)
    ret(img, 7, 3, 2, 8, a(MAD_CL), ox, oy)
    ret(img, 3, 6, 10, 1, a(MAD_CL), ox, oy)
    px(img, 4, 4, a((240, 252, 255)), ox, oy)
    px(img, 5, 4, a((240, 252, 255)), ox, oy)
    px(img, 4, 5, a((240, 252, 255)), ox, oy)
    ret(img, 2, 12, 12, 3, a((150, 84, 44)), ox, oy)
    for x in (3, 6, 9, 12):
        px(img, x, 11, a((255, 96, 140)), ox, oy)
        px(img, x + 1, 11, a((80, 180, 70)), ox, oy)
    # cerca de madeira (fundo transparente)
    ox = 4 * T
    CER = (240, 196, 128)
    CER_ESC = (170, 112, 62)
    for y in (5, 10):
        ret(img, 0, y, T, 2, a(CER), ox, oy)
        ret(img, 0, y + 2, T, 1, a(CER_ESC), ox, oy)
    for x in (2, 11):
        ret(img, x, 2, 3, 12, a(CER), ox, oy)
        ret(img, x + 2, 2, 1, 12, a(CER_ESC), ox, oy)
        ret(img, x, 14, 3, 1, a(CER_ESC), ox, oy)
    # piso de madeira
    ox = 5 * T
    ret(img, 0, 0, T, T, a((200, 140, 84)), ox, oy)
    for y in (3, 7, 11, 15):
        ret(img, 0, y, T, 1, a((156, 98, 56)), ox, oy)
    # (6,1) bloqueio: fica transparente de propósito

    # --- linha 2: variações (o mapa sorteia entre elas para não repetir) ---
    _grama(img, 0, 2, 11)
    _grama(img, 1, 2, 12)
    _grama(img, 2, 2, 13)
    _areia(img, 3, 2, 14)
    _agua(img, 4, 2, 15)

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
