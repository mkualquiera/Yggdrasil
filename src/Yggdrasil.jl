module Yggdrasil

struct YggdrasilNode
    id::UInt64
    height::UInt64
    tail::Union{Nothing,YggdrasilNode}
    key::Any
    value::Any
end

YggdrasilNode() = YggdrasilNode(rand(UInt64),0,nothing,nothing,nothing)

function get(node::YggdrasilNode,key::Any)::Any
    if node.key == key
        return node.value
    else
        if isnothing(node.tail)
            throw(KeyError(key))
        else
            return get(node.tail,key)
        end
    end
end

function set(node::YggdrasilNode,key::Any,value::Any)::YggdrasilNode
    YggdrasilNode(
        node.id,
        node.height + 1,
        node,
        key,
        value
    )
end

export YggdrasilNode,get,set

end # module
