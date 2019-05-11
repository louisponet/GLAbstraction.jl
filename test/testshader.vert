#version 120
attribute vec3 position;
attribute vec2 texcoord;

uniform mat4 view;

void main()
{
    gl_TexCoord[0] = vec4(texcoord, 0, 0);
    gl_Position = view * vec4(position.x, position.y, position.z, 1.0);
}
