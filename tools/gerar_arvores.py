# -*- coding: utf-8 -*-
"""
Gera a folha de sprites das ÁRVORES GRANDES (placeholder original).

    python3 tools/gerar_arvores.py

Resultado: assets/sprites/cenario/arvore_grande.png
  - 4 quadros lado a lado, cada um com 48 x 80 pixels (3 x 5 tiles)
  - quadro 0 = primavera | 1 = verão | 2 = outono | 3 = inverno
  - a base do tronco fica no pixel y = 76 de cada quadro, no centro (x = 24)
Para usar sua arte: salve por cima com o MESMO tamanho (192 x 80) e a mesma ordem.
"""
import math
import random
from pathlib import Path
from PIL import Image

RAIZ = Path(__file__).resolve().parent.parent
L, A = 48, 80          # largura e altura de um quadro
BASE_Y = 76            # onde o tronco encosta no chão
CX = 24                # centro horizontal (onde fica o tronco)

# Paletas de folhas: (sombra, meio, luz, brilho)
FOLHAS = {
    "primavera": [(54, 132, 46), (104, 186, 56), (156, 220, 74), (220, 246, 138)],
    "verao":     [(30, 112, 50), (58, 158, 52), (108, 202, 58), (184, 238, 96)],
    "outono":    [(150, 42, 36), (212, 84, 38), (244, 142, 46), (255, 206, 96)],
}
TRONCO = [(96, 52, 26), (156, 92, 40), (206, 136, 58), (240, 182, 96)]
TRONCO_INVERNO = [(64, 44, 56), (118, 88, 104), (170, 136, 150), (214, 190, 200)]
NEVE = [(170, 190, 220), (236, 244, 255)]


# A copa é a união de vários "tufos" redondos: (centro x, centro y, raio).
# Mexa aqui para mudar o formato da árvore.
TUFOS = [
    (24, 11, 10), (13, 19, 10), (35, 19, 10), (24, 23, 11),
    (9, 31, 8), (39, 31, 8), (17, 37, 9), (31, 37, 9), (24, 33, 10),
]
TOPO_TRONCO = 38


def pinta(img, x, y, cor):
    if 0 <= x < img.width and 0 <= y < img.height:
        img.putpixel((x, y), cor + (255,))


# Raízes: (início no tronco, ponto de curva, ponta no chão, grossura inicial).
# Cada raiz sai do tronco, desce e se curva para fora, afinando até a ponta.
RAIZES = [
    ((CX - 3, BASE_Y - 7), (CX - 6, BASE_Y - 1), (CX - 12, BASE_Y), 4),   # esquerda
    ((CX + 3, BASE_Y - 7), (CX + 6, BASE_Y - 2), (CX + 11, BASE_Y - 1), 4),  # direita
    ((CX + 1, BASE_Y - 4), (CX + 2, BASE_Y), (CX + 5, BASE_Y + 1), 3),     # frente
    ((CX - 1, BASE_Y - 4), (CX - 3, BASE_Y - 1), (CX - 5, BASE_Y + 1), 2),  # frente (pequena)
]


def _curva(p0, p1, p2, t):
    """Ponto numa curva suave (Bézier quadrática) entre p0 e p2, puxada por p1."""
    a = (1 - t) ** 2
    b = 2 * (1 - t) * t
    c = t ** 2
    return (a * p0[0] + b * p1[0] + c * p2[0], a * p0[1] + b * p1[1] + c * p2[1])


def raiz(img, pal, inicio, curva, ponta, grossura):
    passos = 40
    for k in range(passos + 1):
        t = k / passos
        x, y = _curva(inicio, curva, ponta, t)
        g = max(1, round(grossura * (1 - t) + 0.4))
        x, y = round(x), round(y)
        for d in range(g):
            # em cima da raiz bate luz, embaixo fica a sombra
            cor = pal[2] if d == 0 else (pal[0] if d == g - 1 and g > 2 else pal[1])
            pinta(img, x, y + d - g + 1, cor)


def tronco(img, pal, rnd):
    """Tronco levemente mais largo embaixo, com raízes curvas saindo dele."""
    fim = BASE_Y - 3
    for y in range(TOPO_TRONCO, fim + 1):
        t = (y - TOPO_TRONCO) / (fim - TOPO_TRONCO)
        meia = 3.5 + t * 1.2
        x0, x1 = round(CX - meia), round(CX + meia)
        for x in range(x0, x1 + 1):
            u = (x - x0) / max(1, x1 - x0)
            cor = pal[1]
            if u < 0.3:
                cor = pal[2]
            if u < 0.12:
                cor = pal[3]
            if u > 0.75:
                cor = pal[0]
            pinta(img, x, y, cor)
    # sulcos verticais da casca
    for _ in range(7):
        x = rnd.randint(CX - 2, CX + 2)
        y = rnd.randint(TOPO_TRONCO + 2, fim - 6)
        for k in range(rnd.randint(3, 6)):
            pinta(img, x, y + k, pal[0])
    # um buraquinho no tronco (charme!)
    pinta(img, CX + 1, TOPO_TRONCO + 14, pal[0])
    pinta(img, CX + 1, TOPO_TRONCO + 15, pal[0])
    pinta(img, CX + 2, TOPO_TRONCO + 15, pal[0])
    # as raízes (as de trás primeiro, as da frente por cima)
    for (inicio, curva, ponta, grossura) in RAIZES:
        raiz(img, pal, inicio, curva, ponta, grossura)


def galho(img, x, y, ang, comp, grossura, pal, rnd, neve, nivel=0):
    """Galho recursivo (árvore de inverno)."""
    for i in range(int(comp)):
        px_ = x + math.cos(ang) * i
        py_ = y + math.sin(ang) * i
        g = max(1, round(grossura * (1 - i / (comp * 1.5))))
        for dx in range(-(g // 2), g - g // 2):
            pinta(img, round(px_) + dx, round(py_), pal[2] if dx < 0 else pal[1])
        if neve and g >= 2 and i % 2 == 0:  # neve só em cima dos galhos grossos
            pinta(img, round(px_), round(py_) - 1, NEVE[1])
    fx = x + math.cos(ang) * comp
    fy = y + math.sin(ang) * comp
    if nivel < 3 and comp > 3:
        for d in (-0.55, 0.5):
            galho(img, fx, fy, ang + d + rnd.uniform(-0.15, 0.15),
                  comp * rnd.uniform(0.55, 0.7), grossura * 0.65, pal, rnd, neve, nivel + 1)


# Forma de uma folha (4 x 4) e o "contorno" escuro embaixo dela.
FOLHA = [(1, 0), (0, 1), (1, 1), (2, 1), (0, 2), (1, 2), (2, 2), (3, 2), (1, 3), (2, 3)]
FOLHA_SOMBRA = [(3, 3), (2, 4), (1, 4)]


def copa(img, pal, rnd, flores=False, cores_flores=((255, 222, 238), (236, 140, 186))):
    """Copa feita de tufos; cada tufo é coberto de folhinhas."""
    sombra, meio, luz, brilho = pal
    for (tx, ty, r) in sorted(TUFOS, key=lambda c: c[1]):  # de trás (cima) para frente
        # fundo escuro do tufo
        for y in range(ty - r, ty + r + 1):
            for x in range(tx - r, tx + r + 1):
                if (x - tx) ** 2 + (y - ty) ** 2 <= (r - 1) ** 2:
                    pinta(img, x, y, sombra)
        # folhas numa grade "desencontrada" (como escamas)
        for gy in range(ty - r, ty + r + 1, 3):
            deslocamento = 2 if (gy // 3) % 2 else 0
            for gx in range(tx - r + deslocamento, tx + r + 1, 4):
                x = gx + rnd.randint(-1, 0)
                y = gy + rnd.randint(-1, 0)
                if (x - tx) ** 2 + (y - ty) ** 2 > (r - 1.5) ** 2:
                    continue
                # luz vem de cima e da esquerda do tufo
                l = -((x - tx) * 0.55 + (y - ty)) / r + rnd.uniform(-0.25, 0.25)
                cor = sombra if l < -0.45 else (meio if l < 0.25 else luz)
                for dx, dy in FOLHA:
                    pinta(img, x + dx - 2, y + dy - 2, cor)
                for dx, dy in FOLHA_SOMBRA:
                    pinta(img, x + dx - 2, y + dy - 2, sombra)
                if cor == luz and l > 0.6:
                    pinta(img, x - 1, y - 1, brilho)
    if flores:
        for _ in range(14):
            tx, ty, r = rnd.choice(TUFOS)
            x = tx + rnd.randint(-r + 3, r - 3)
            y = ty + rnd.randint(-r + 3, r - 3)
            pinta(img, x, y, cores_flores[0])
            pinta(img, x + 1, y, cores_flores[1])
            pinta(img, x, y + 1, cores_flores[1])


def contorno(img, fator=0.4):
    """Contorno escuro em volta de tudo (estilo pixel art)."""
    copia = img.copy()
    for y in range(img.height):
        for x in range(img.width):
            if copia.getpixel((x, y))[3] != 0:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < img.width and 0 <= ny < img.height:
                    r, g, b, a = copia.getpixel((nx, ny))
                    if a == 255:
                        img.putpixel((x, y), (int(r * fator), int(g * fator), int(b * fator), 255))
                        break


def sombra_no_chao(img):
    for y in range(BASE_Y - 2, A):
        for x in range(L):
            if ((x - CX) / 16) ** 2 + ((y - (BASE_Y + 1.5)) / 2.5) ** 2 <= 1 and img.getpixel((x, y))[3] == 0:
                img.putpixel((x, y), (20, 30, 20, 90))


def quadro(estacao, semente=7):
    rnd = random.Random(semente)
    img = Image.new("RGBA", (L, A), (0, 0, 0, 0))
    if estacao == "inverno":
        tronco(img, TRONCO_INVERNO, rnd)
        for ang, comp in ((-2.35, 13), (-1.85, 15), (-1.3, 15), (-0.8, 13)):
            galho(img, CX, TOPO_TRONCO + 2, ang, comp, 4, TRONCO_INVERNO, rnd, True)
        for (inicio, curva, ponta, grossura) in RAIZES:   # neve em cima das raízes
            for k in range(0, 30, 7):
                x, y = _curva(inicio, curva, ponta, k / 30)
                pinta(img, round(x), round(y) - grossura, NEVE[1])
    else:
        tronco(img, TRONCO, rnd)                     # primeiro o tronco...
        copa(img, FOLHAS[estacao], rnd, flores=(estacao == "primavera"))  # ...a copa por cima
    contorno(img)
    sombra_no_chao(img)
    return img


# ---------------------------------------------------------------------------
# FLORESTA CINZENTA: árvores antigas, com musgo no tronco e cogumelos.
# arvore_floresta.png: 4 quadros = 4 VARIAÇÕES (não estações).
# ---------------------------------------------------------------------------
TRONCO_FLORESTA = [(70, 44, 34), (118, 78, 52), (164, 114, 72), (204, 156, 100)]
MUSGO = [(46, 120, 60), (90, 176, 80)]
VARIACOES_FLORESTA = [
    {"folhas": [(20, 84, 56), (31, 120, 72), (52, 166, 96), (130, 220, 140)]},
    {"folhas": [(16, 86, 92), (28, 128, 124), (63, 184, 170), (150, 236, 214)], "cogumelos": True},
    {"folhas": [(26, 96, 48), (46, 140, 58), (92, 190, 80), (176, 232, 120)], "cogumelos": True},
    {"folhas": [(30, 90, 70), (46, 130, 90), (80, 176, 110), (160, 226, 160)],
     "flores": ((255, 168, 214), (222, 88, 160))},
]


def musgo_no_tronco(img, rnd):
    for _ in range(14):
        x = CX + rnd.randint(-4, 0)
        y = rnd.randint(TOPO_TRONCO + 4, BASE_Y - 6)
        pinta(img, x, y, MUSGO[rnd.randint(0, 1)])
        pinta(img, x, y + 1, MUSGO[0])


def cogumelos(img):
    """Cogumelinhos laranja de bolinhas brancas nas raízes."""
    CHAPEU, CHAPEU_ESC, PE = (255, 138, 61), (206, 84, 40), (250, 236, 210)
    for (x, y) in ((CX - 10, BASE_Y - 1), (CX + 9, BASE_Y - 2), (CX + 12, BASE_Y)):
        pinta(img, x, y, PE)
        pinta(img, x, y - 1, PE)
        for dx in range(-2, 3):
            pinta(img, x + dx, y - 2, CHAPEU if abs(dx) < 2 else CHAPEU_ESC)
        for dx in range(-1, 2):
            pinta(img, x + dx, y - 3, CHAPEU)
        pinta(img, x - 1, y - 3, (255, 245, 230))
        pinta(img, x + 1, y - 2, (255, 245, 230))


def quadro_floresta(cfg, semente):
    rnd = random.Random(semente)
    img = Image.new("RGBA", (L, A), (0, 0, 0, 0))
    tronco(img, TRONCO_FLORESTA, rnd)
    musgo_no_tronco(img, rnd)
    if "flores" in cfg:
        copa(img, cfg["folhas"], rnd, flores=True, cores_flores=cfg["flores"])
    else:
        copa(img, cfg["folhas"], rnd)
    if cfg.get("cogumelos"):
        cogumelos(img)
    contorno(img)
    sombra_no_chao(img)
    return img


def gerar_folha(quadros, nome):
    folha = Image.new("RGBA", (L * 4, A), (0, 0, 0, 0))
    for i, q in enumerate(quadros):
        folha.paste(q, (i * L, 0))
    destino = RAIZ / "assets/sprites/cenario"
    destino.mkdir(parents=True, exist_ok=True)
    folha.save(destino / nome)
    print("Árvores geradas em", destino / nome)


if __name__ == "__main__":
    gerar_folha([quadro(est) for est in ("primavera", "verao", "outono", "inverno")], "arvore_grande.png")
    gerar_folha([quadro_floresta(cfg, 20 + i) for i, cfg in enumerate(VARIACOES_FLORESTA)], "arvore_floresta.png")
