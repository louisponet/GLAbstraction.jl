#version 120
struct Material {
    vec3 a;
    float b;
};
uniform Material structtest;
uniform vec3 color;
uniform sampler2D texture;
uniform float exposure;
void main()
{
    vec3 texcol = texture2D(texture, gl_TexCoord[0].st).xyz;
    texcol += structtest.a * structtest.b;
    gl_FragColor = vec4(color+texcol, 1.0f)*exposure;
}
