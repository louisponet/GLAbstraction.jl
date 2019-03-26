module TestShader
using ModernGL
using GLAbstraction: shadertype, attributes, uniform_location, uniform_type,
    uniform_size, attribute_location, getinfolog, Program, set_uniform,
    bind
using Test
using FileIO
using GLFW

# create a GL context for tests
GLFW.WindowHint(GLFW.VISIBLE, false)
window = GLFW.CreateWindow(640, 480, "Test context")
@test window != C_NULL
GLFW.MakeContextCurrent(window)


@testset "Test shaders" begin
    # test a vertex shader
    vertshader = load("testshader.vert")
    @test vertshader.id != 0
    @test shadertype(vertshader) == GL_VERTEX_SHADER
    @test vertshader == vertshader

    # test the show method of Shader. only make sure that it runs and returns
    # some non empty string since we don't want to update the test everytime
    # the display of a shader may be changed
    @test repr(vertshader) != ""
    @test getinfolog(vertshader.id) == "success"

    # test a fragment shader
    fragshader = load("testshader.frag")
    @test getinfolog(fragshader.id) == "success"
    @test fragshader.id != 0
    @test shadertype(fragshader) == GL_FRAGMENT_SHADER
    @test fragshader == fragshader
    @test repr(fragshader) != ""

    @test vertshader != fragshader

    # test the error checking for a broken shader, ideally this test should
    # capture the @error somehow so we can check for it and it isn't displayed
    # when the test is successful...
    brokenshader = load("brokentestshader.frag")
    @test getinfolog(brokenshader.id) == "0:2(1): error: syntax error, unexpected NEW_IDENTIFIER\n"

    # test program
    p = Program([vertshader, fragshader])
    @test p.id != 0
    @test repr(p) != ""

    # test setting uniforms of program
    mat = Matrix(rand(GLfloat, 4,4))
    bind(p)
    set_uniform(p, :view, mat)

    # there isn't a method yet to get the value of a uniform so here it is
    # instead...TODO: move this somewhere more appropriate
    function get_uniform(p::Program, name)
        loc = uniform_location(p, name)
        typ = uniform_type(p, name)
        size = uniform_size(p, name)
        if size == 1
            if typ == GL_FLOAT_MAT4
                data = Array{GLfloat}(undef, (4, 4))
            elseif typ == GL_FLOAT_VEC3
                data = Array{GLfloat}(undef, 3)
            elseif typ == GL_FLOAT_VEC2
                data = Array{GLfloat}(undef, 2)
            elseif typ == GL_FLOAT
                data = Array{GLfloat}(undef, 1)
            end
        end
        glGetUniformfv(p.id, loc, data)
        if typ == GL_FLOAT
            return data[1]
        end
        data
    end

    @test get_uniform(p, :view) == mat

    vec3 = rand(GLfloat, 3)
    set_uniform(p, :color, vec3)
    @test get_uniform(p, :color) == vec3

    v = rand(GLfloat)
    set_uniform(p, :exposure, v)
    @test get_uniform(p, :exposure) == v

    # test setting attribute locations
    p2 = Program([vertshader, fragshader],
            attriblocation=[(2, "position"), (4, "texcoord")])
    @test attribute_location(p2, :position) == 2
    @test attribute_location(p2, :texcoord) == 4
 end

# clean up test context
GLFW.DestroyWindow(window)
end
