
abstract Unit
abstract Composable{unit}
typealias BoundingBox Union{TOrSignal{HyperRectangle}}
typealias Transformation Union{TOrSignal{Mat}}

immutable DeviceUnit <: Unit end

type Composition{Unit, B<:BoundingBox, T<:Transformation} <: Composable{Unit}
    children
    context::B
end
function translationmatrix(b::BoundingBox)
    const_lift(b) do b
        m = minimum(b)
        w = widths(b)
        T = eltype(w)
        # make code work also for N == 2
        m3 = ndims(m) > 2 ? zero(T) : m[3]
        w3 = ndims(w) > 2 ? one(T) : w[3]
        Mat{4,4,T}(
            (w[1], 0   , 0 , 0),
            (0   , w[2], 0 , 0),
            (0   , 0   , w3, 0),
            (m[1], m[2], m3, 1),
        )
    end
end

function layout(b::BoundingBox, x)
    translationmatrix(b)*x
end

layout(HyperRectangle(0,0,50,500), layout([
    "hello gurl",
    slider(1:10),
    RGBA{Float32}(0,0,0,1)
], gap=Vec3f0(0)))



Context() = Context{DeviceUnit}(Composable[], Signal(AABB{Float32}(Vec3f0(0), Vec3f0(0))), Signal(eye(Mat{4,4, Float32})))
Context(trans::Signal{Mat{4,4, Float32}}) = Context{DeviceUnit}(Composable[], Signal(AABB{Float32}(Vec3f0(0), Vec3f0(0))), trans)
function Context(a::Composable...; parent=Context())
    append!(parent, a)
    parent
end
boundingbox(c::Composable) = c.boundingbox
transformation(c::Composable) = c.transformation

function transformation(c::Composable, model)
    c.transformation = const_lift(*, model, c.transformation)
    for elem in c.children
        transformation(elem, c.transformation)
    end
end

convert!{unit <: Unit}(::Type{unit}, x::Composable) = x # We don't do units just yet

function Base.append!{unit <: Unit, N}(context::Context{unit}, x::Union{Vector{Composable}, NTuple{N, Composable}})
    for elem in x
        push!(context, elem)
    end
    context
end

function Base.push!{unit <: Unit}(context::Context{unit}, x::Composable)
    x = convert!(unit, x)
    context.boundingbox = const_lift(transformation(x), transformation(context), boundingbox(x), boundingbox(context)) do transa, transb, a,b
        a = transa*a
        b = transb*b
         # we need some zero element for an empty context
         # sadly union(zero(AABB), ...) doesn't work for this
        if a == AABB{Float32}(Vec3f0(0), Vec3f0(0))
            return b
        elseif b == AABB{Float32}(Vec3f0(0), Vec3f0(0))
            return a
        end
        union(a,b)
    end
    transformation(x, transformation(context))
    push!(context.children, x)
    context
end
export transformation
export boundingbox
