// ============================================================================
// nevoa.gdshader  —  A NÉVOA DO ESQUECIMENTO
// ----------------------------------------------------------------------------
// Desenha uma névoa que se mexe devagar por cima do mapa, com um "buraco"
// de luz em volta da Lia (a Lanterna de Luz). Os valores são controlados
// pelo script scripts/mundo/clima.gd.
// ============================================================================
shader_type canvas_item;

uniform vec4 cor_nevoa : source_color = vec4(0.84, 0.8, 0.94, 0.8);
uniform vec2 centro_luz = vec2(160.0, 90.0);   // posição da Lia na tela (pixels)
uniform float raio_luz = 44.0;                 // tamanho do círculo limpo
uniform float suavidade = 28.0;                // largura da borda do círculo
uniform vec2 deslocamento_mundo = vec2(0.0);   // faz a névoa "ficar" no mundo
uniform vec2 tamanho_tela = vec2(320.0, 180.0);
uniform vec2 vento = vec2(6.0, 2.0);           // direção/velocidade da névoa
uniform sampler2D ruido : repeat_enable, filter_linear;

void fragment() {
	// Trabalha em blocos de 2x2 pixels para combinar com a pixel art.
	vec2 px = floor(UV * tamanho_tela / 2.0) * 2.0;
	vec2 mundo = px + deslocamento_mundo;

	// Duas camadas de "ruído" se movendo em direções diferentes = névoa viva.
	float n1 = texture(ruido, (mundo + TIME * vento) / 160.0).r;
	float n2 = texture(ruido, (mundo - TIME * vento * 0.6) / 96.0 + vec2(0.37, 0.71)).r;
	float densidade = smoothstep(0.3, 0.75, (n1 + n2) * 0.5);

	// Perto da Lanterna a névoa some.
	float luz = smoothstep(raio_luz, raio_luz + suavidade, distance(px, centro_luz));

	float alfa = cor_nevoa.a * mix(0.45, 1.0, densidade) * luz;
	alfa = floor(alfa * 6.0 + 0.5) / 6.0;  // poucos "degraus" = visual pixel art
	COLOR = vec4(cor_nevoa.rgb, alfa);
}
