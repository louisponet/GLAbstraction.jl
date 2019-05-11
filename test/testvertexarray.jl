module TestVertexArray
using ModernGL
using Test
using GLFW
using GLAbstraction: Context, set_context!, Buffer, VertexArray,
    GEOMETRY_DIVISOR, BufferAttachmentInfo, is_null, bind, unbind, draw,
    bufferinfo
using StaticArrays

# create a GL context for tests
GLFW.WindowHint(GLFW.VISIBLE, false)
window = GLFW.CreateWindow(640, 480, "Test context")
@test window != C_NULL
GLFW.MakeContextCurrent(window)
set_context!(Context(:window))


@testset "Test vertex array" begin
    vec = rand(SVector{3, GLfloat}, 8)
    buffer = Buffer(vec)

    attinfo = BufferAttachmentInfo(:testbuffer, GLint(0), buffer, GEOMETRY_DIVISOR)
    vao = VertexArray(BufferAttachmentInfo[attinfo], 3)

    @test !is_null(vao)
    @test bufferinfo(vao, :testbuffer) == attinfo
    @test length(vao) == 8
    @test repr(vao) != ""

    bind(vao)
    unbind(vao)
    draw(vao)
end

# clean up test context
GLFW.DestroyWindow(window)
end
