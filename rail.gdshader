shader_type canvas_item;

// Uniform to control the tiling of the texture
uniform float repeat = 1.0;

void vertex() {
    // Pass the vertex position to the fragment shader
    UV = vec2(VERTEX.x, VERTEX.y);
}

void fragment() {
    // Calculate UV coordinates for tiling
    vec2 uv = vec2(UV.x * repeat, UV.y);

    // Sample the texture using the UV coordinates
    vec4 tex_color = texture(TEXTURE, uv);

    // Set the fragment color
    COLOR = tex_color;
}
