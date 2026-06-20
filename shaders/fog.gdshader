shader_type canvas_item;

// La texture de bruit (Perlin/Simplex) qu'on va faire défiler
uniform sampler2D noise_texture : repeat_enable;

// Paramètres de contrôle depuis l'inspecteur Godot
uniform vec4 fog_color : source_color = vec4(0.35, 0.4, 0.45, 0.3); // Couleur gris-bleuâtre transparente
uniform vec2 speed = vec2(0.02, 0.01); // Vitesse de déplacement du brouillard
uniform float density = 0.8; // Densité globale

void fragment() {
    // Fait défiler les coordonnées UV de la texture de bruit avec le temps (TIME)
    vec2 moving_uv1 = UV + TIME * speed;
    vec2 moving_uv2 = UV - TIME * speed * 0.7; // Deuxième couche inversée pour donner du relief

    // On récupère la valeur du bruit (entre 0.0 et 1.0)
    float noise1 = texture(noise_texture, moving_uv1).r;
    float noise2 = texture(noise_texture, moving_uv2).r;
    
    // On mélange les deux bruits pour un effet plus organique
    float final_noise = (noise1 + noise2) / 2.0;

    // On applique la densité
    final_noise = smoothstep(1.0 - density, 1.0, final_noise);

    // Couleur finale : On garde la couleur choisie, et on multiplie son opacité par notre bruit
    vec4 final_color = fog_color;
    final_color.a *= final_noise;

    COLOR = final_color;
}