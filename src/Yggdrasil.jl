module Yggdrasil

struct YggdrasilNode
    tail::Union{Nothing,YggdrasilNode}
    key::Any
    value::Any
end

root = YggdrasilNode(nothing,nothing,nothing)

YggdrasilNode() = root

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
        node,
        key,
        value
    )
end

export YggdrasilNode,get,set

end # module
