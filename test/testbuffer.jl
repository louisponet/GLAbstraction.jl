module TestBuffer
using ModernGL
using Test
using GLFW
using GLAbstraction: Context, set_context!, Buffer, bind, unbind
using StaticArrays

# create a GL context for tests
GLFW.WindowHint(GLFW.VISIBLE, false)
window = GLFW.CreateWindow(640, 480, "Test context")
@test window != C_NULL
GLFW.MakeContextCurrent(window)
set_context!(Context(:window))


@testset "Test buffers" begin
    vec = rand(8)
    buffer = Buffer(vec)

    @test size(buffer) == size(vec)
    @test buffer == vec

    vec32 = rand(GLfloat, 8)
    buffer32 = Buffer(vec32)

    @test buffer32 == vec32

    points = rand(SVector{3, GLfloat}, 4)
    buffer_arr = Buffer(points)

    @test size(buffer_arr) == size(points)
    @test buffer_arr == points
end

# clean up test context
GLFW.DestroyWindow(window)
end
