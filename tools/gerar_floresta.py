# -*- coding: utf-8 -*-
"""
Gera o TILESET da FLORESTA CINZENTA (placeholder original).

    python3 tools/gerar_floresta.py

Resultado: assets/tiles/tileset_floresta.png (128 x 48, 8 x 3 tiles de 16x16)
Usa o MESMO "molde" do tileset da vila (cada posição tem a mesma função),
então o mapa de texto usa as mesmas letras. Ver docs/cenarios_das_fases.md.

  Linha 0: 0 musgo (chão) | 1 musgo c/ cogumelinhos | 2 trilha de folhas | 3 terra úmida
           4 riacho | 5 margem do riacho | 6 rocha com musgo | 7 samambaia
  Linha 1: 0 muro de pedra antiga | 1 topo do muro com hera | 2 portal de pedra
           3 pedra com runa brilhante | 4 raízes atravessadas | 5 ponte de tábuas
           6 bloqueio (vazio) | 7 (livre)
  Linha 2: 0-2 variações de musgo | 3 variação de terra | 4 variação de riacho
"""
import random
from gerar_placeholders import nova, ret, px, contorno, T, RAIZ

a = lambda c: tuple(c) + (255,)

# ----------------------------------------------------------------- paleta ---
MUSGO = (46, 150, 84)
MUSGO_ESC = (31, 112, 70)
MUSGO_ESC2 = (22, 84, 60)
MUSGO_CL = (92, 196, 110)
MUSGO_BRILHO = (160, 232, 150)
FOLHA_CHAO = (170, 116, 70)
FOLHA_CHAO_ESC = (126, 82, 52)
FOLHAS_CAIDAS = [(240, 140, 50), (255, 196, 80), (214, 76, 50)]
TERRA = (120, 88, 66)
TERRA_ESC = (88, 62, 50)
TERRA_CL = (156, 120, 88)
RIO = (52, 178, 172)
RIO_ESC = (34, 132, 146)
RIO_CL = (120, 222, 208)
RIO_BRILHO = (220, 255, 246)
PEDRA = (140, 150, 170)
PEDRA_ESC = (92, 98, 124)
PEDRA_CL = (190, 198, 214)
RUNA = (110, 240, 255)
MADEIRA = (196, 134, 78)
MADEIRA_ESC = (132, 84, 50)
MADEIRA_CL = (232, 180, 112)


def base(img, c, l, cor):
    ret(img, 0, 0, T, T, a(cor), c * T, l * T)


def salpicar(img, c, l, rnd, cores, n, margem=0):
    for _ in range(n):
        px(img, rnd.randint(margem, T - 1 - margem), rnd.randint(margem, T - 1 - margem),
           a(rnd.choice(cores)), c * T, l * T)


def musgo(img, c, l, semente, cogumelinhos=False):
    rnd = random.Random(semente)
    ox, oy = c * T, l * T
    base(img, c, l, MUSGO)
    salpicar(img, c, l, rnd, [MUSGO_CL, MUSGO_ESC], 12)
    # trevinhos de 3 folhas
    for _ in range(3):
        x, y = rnd.randint(1, 13), rnd.randint(2, 13)
        px(img, x, y, a(MUSGO_ESC2), ox, oy)
        px(img, x + 1, y, a(MUSGO_ESC2), ox, oy)
        px(img, x, y - 1, a(MUSGO_CL), ox, oy)
        px(img, x + 1, y - 1, a(MUSGO_BRILHO), ox, oy)
        px(img, x + 2, y, a(MUSGO_CL), ox, oy)
    if cogumelinhos:
        for (x, y, cor) in ((4, 6, (255, 138, 61)), (11, 11, (255, 111, 174)), (7, 13, (255, 138, 61))):
            px(img, x, y + 1, a((250, 236, 210)), ox, oy)
            ret(img, x - 1, y, 3, 1, a(cor), ox, oy)
            px(img, x, y - 1, a(cor), ox, oy)
            px(img, x - 1, y, a((255, 245, 230)), ox, oy)


def terra(img, c, l, semente):
    rnd = random.Random(semente)
    base(img, c, l, TERRA)
    salpicar(img, c, l, rnd, [TERRA_ESC, TERRA_CL, TERRA_ESC], 16)


def riacho(img, c, l, semente):
    rnd = random.Random(semente)
    ox, oy = c * T, l * T
    base(img, c, l, RIO)
    for _ in range(3):
        x, y = rnd.randint(0, 10), rnd.randint(2, 13)
        ret(img, x, y, 5, 1, a(RIO_CL), ox, oy)
        ret(img, x + 1, y + 1, 4, 1, a(RIO_ESC), ox, oy)
    for _ in range(2):
        px(img, rnd.randint(1, 14), rnd.randint(1, 14), a(RIO_BRILHO), ox, oy)


def gerar():
    img = nova(T * 8, T * 3)
    # ---------------- linha 0 ----------------
    musgo(img, 0, 0, 1)
    musgo(img, 1, 0, 2, cogumelinhos=True)
    # trilha de terra coberta de folhas caídas
    rnd = random.Random(3)
    base(img, 2, 0, FOLHA_CHAO)
    salpicar(img, 2, 0, rnd, [FOLHA_CHAO_ESC], 10)
    for _ in range(7):
        x, y = rnd.randint(1, 13), rnd.randint(1, 14)
        cor = a(rnd.choice(FOLHAS_CAIDAS))
        ret(img, x, y, 2, 1, cor, 2 * T, 0)
        px(img, x + 1, y - 1, cor, 2 * T, 0)
    terra(img, 3, 0, 4)
    riacho(img, 4, 0, 5)
    # margem: musgo em cima, espuma clara, água embaixo
    riacho(img, 5, 0, 6)
    ox = 5 * T
    ret(img, 0, 0, T, 4, a(MUSGO), ox, 0)
    for x in range(T):
        h = 4 + (1 if (x // 3) % 2 else 0)
        px(img, x, h - 1, a(MUSGO_ESC2), ox, 0)
        px(img, x, h, a(RIO_BRILHO), ox, 0)
        px(img, x, h + 1, a(RIO_CL), ox, 0)
    # rocha com musgo em cima (fundo transparente)
    ox = 6 * T
    ret(img, 2, 13, 12, 2, (20, 40, 30, 80), ox, 0)
    ret(img, 3, 5, 10, 8, a(PEDRA), ox, 0)
    ret(img, 4, 4, 8, 1, a(PEDRA), ox, 0)
    ret(img, 4, 6, 4, 3, a(PEDRA_CL), ox, 0)
    ret(img, 9, 9, 4, 4, a(PEDRA_ESC), ox, 0)
    ret(img, 3, 4, 9, 2, a(MUSGO_CL), ox, 0)
    ret(img, 5, 3, 5, 1, a(MUSGO_BRILHO), ox, 0)
    ret(img, 2, 6, 1, 3, a(MUSGO_ESC), ox, 0)
    # samambaia (fundo transparente)
    ox = 7 * T
    for (x0, y0, dx) in ((8, 14, -1), (8, 14, 1), (8, 14, 0)):
        for k in range(10):
            x = x0 + dx * (k // 2)
            y = y0 - k
            px(img, x, y, a(MUSGO_ESC), ox, 0)
            if k % 2 == 0 and k > 1:
                px(img, x - 1, y, a(MUSGO_CL), ox, 0)
                px(img, x + 1, y, a(MUSGO_CL), ox, 0)
                px(img, x - 2, y + 1, a(MUSGO), ox, 0)
                px(img, x + 2, y + 1, a(MUSGO), ox, 0)
    contorno(img, area=(6 * T, 0, 8 * T, T))

    # ---------------- linha 1 (ruínas antigas) ----------------
    oy = T
    # muro de pedra
    ret(img, 0, 0, T, T, a(PEDRA), 0, oy)
    for y in (0, 5, 10, 15):
        ret(img, 0, y, T, 1, a(PEDRA_ESC), 0, oy)
    for (x, y) in ((6, 1), (13, 1), (3, 6), (10, 6), (7, 11), (14, 11)):
        ret(img, x, y, 1, 4, a(PEDRA_ESC), 0, oy)
        px(img, x + 1, y, a(PEDRA_CL), 0, oy)
    ret(img, 1, 12, 3, 3, a(MUSGO_ESC), 0, oy)
    # topo do muro com hera
    ox = T
    ret(img, 0, 0, T, T, a(PEDRA_CL), ox, oy)
    ret(img, 0, 12, T, 4, a(PEDRA), ox, oy)
    ret(img, 0, 15, T, 1, a(PEDRA_ESC), ox, oy)
    rnd = random.Random(9)
    for _ in range(26):
        x, y = rnd.randint(0, 15), rnd.randint(0, 13)
        px(img, x, y, a(rnd.choice([MUSGO, MUSGO_CL, MUSGO_ESC])), ox, oy)
    for x in (2, 9, 13):
        for y in range(10, 16):
            px(img, x, y, a(MUSGO_ESC), ox, oy)
    # portal de pedra (passagem escura)
    ox = 2 * T
    ret(img, 0, 0, T, T, a(PEDRA), ox, oy)
    ret(img, 3, 3, 10, 13, a((24, 20, 40)), ox, oy)
    ret(img, 4, 2, 8, 1, a((24, 20, 40)), ox, oy)
    ret(img, 2, 3, 1, 13, a(PEDRA_CL), ox, oy)
    ret(img, 13, 3, 1, 13, a(PEDRA_ESC), ox, oy)
    px(img, 7, 1, a(RUNA), ox, oy)
    px(img, 8, 1, a(RUNA), ox, oy)
    # pedra com runa brilhante: um menir em pé (fundo transparente)
    ox = 3 * T
    ret(img, 3, 14, 10, 2, (20, 40, 30, 80), ox, oy)     # sombrinha
    ret(img, 5, 2, 6, 13, a(PEDRA), ox, oy)
    ret(img, 6, 1, 4, 1, a(PEDRA), ox, oy)
    ret(img, 5, 2, 2, 12, a(PEDRA_CL), ox, oy)
    ret(img, 10, 3, 1, 12, a(PEDRA_ESC), ox, oy)
    ret(img, 4, 12, 8, 3, a(PEDRA), ox, oy)
    ret(img, 4, 13, 3, 2, a(MUSGO_CL), ox, oy)          # musgo na base
    for (x, y) in ((8, 4), (8, 5), (8, 6), (8, 7), (8, 8), (8, 9), (7, 6), (9, 8), (7, 9)):
        px(img, x, y, a(RUNA), ox, oy)
    px(img, 8, 3, a((230, 255, 255)), ox, oy)
    contorno(img, area=(3 * T, oy, 4 * T, oy + T))
    # raízes atravessadas (fundo transparente)
    ox = 4 * T
    for (y, g) in ((6, 3), (11, 2)):
        for x in range(T):
            yy = y + (1 if (x // 4) % 2 else 0)
            for k in range(g):
                cor = MADEIRA_CL if k == 0 else (MADEIRA_ESC if k == g - 1 else MADEIRA)
                px(img, x, yy + k, a(cor), ox, oy)
    ret(img, 5, 4, 1, 10, a(MADEIRA_ESC), ox, oy)
    contorno(img, area=(4 * T, oy, 5 * T, oy + T))
    # ponte de tábuas (dá para andar por cima do riacho)
    ox = 5 * T
    ret(img, 0, 0, T, T, a(RIO), ox, oy)
    ret(img, 0, 0, T, T, a(MADEIRA), ox, oy)   # tábuas de ponta a ponta: pontes
    for y in (0, 4, 8, 12):                     # de 2+ tiles ficam contínuas
        ret(img, 0, y, T, 1, a(MADEIRA_CL), ox, oy)
        ret(img, 0, y + 3, T, 1, a(MADEIRA_ESC), ox, oy)
    for (x, y) in ((3, 1), (12, 5), (6, 9), (10, 13)):
        px(img, x, y, a(MADEIRA_ESC), ox, oy)  # pregos
    # (6,1) bloqueio: vazio de propósito

    # ---------------- linha 2: variações ----------------
    musgo(img, 0, 2, 11)
    musgo(img, 1, 2, 12)
    musgo(img, 2, 2, 13)
    terra(img, 3, 2, 14)
    riacho(img, 4, 2, 15)

    img.save(RAIZ / "assets/tiles/tileset_floresta.png")
    print("Tileset da floresta gerado.")


if __name__ == "__main__":
    gerar()
