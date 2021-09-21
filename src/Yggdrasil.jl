module Yggdrasil

function reftreetovec(tree::Expr)::Vector{Any}
    if typeof(tree.args[1]) == Expr
        inner = reftreetovec(tree.args[1])
        push!(inner,tree.args[2])
        return inner
    else
        return vec([tree.args[1],tree.args[2]])
    end
end

function buildyggexpr(inputexpr)
    blockargs = Vector()
    if inputexpr.head == Symbol("=")
        tree = inputexpr.args[1]
        indices = reftreetovec(tree)
        blockargs = Vector()

        for i in 2:length(indices)
            varname = "$(indices[i])$i"
            prevvarname = i == 2 ? indices[i-1] : "$(indices[i-1])$(i-1)"
            prevsymbol = i==2 ? esc(Symbol(prevvarname)) : Symbol(prevvarname)
            if i == length(indices)
                myexpr = :($(prevsymbol)=set($(prevsymbol),
                    $(indices[i]),$(esc(inputexpr.args[2]))))
                push!(blockargs,myexpr)
            else
                myexpr = :($(Symbol(varname))=get($(prevsymbol),
                    $(indices[i])))
                push!(blockargs,myexpr)
            end
        end

        for i in (length(indices)-1):-1:2
            varname = "$(indices[i])$i"
            prevvarname = i == 2 ? indices[i-1] : "$(indices[i-1])$(i-1)"
            prevsymbol = i==2 ? esc(Symbol(prevvarname)) : Symbol(prevvarname)
            myexpr = :($(prevsymbol)=set($(prevsymbol),
                $(indices[i]),$(Symbol(varname))))
            push!(blockargs,myexpr)
        end
        
    end

    if inputexpr.head == Symbol("ref")
        tree = inputexpr
        indices = reftreetovec(tree)
    
        for i in 2:length(indices)
            varname = "$(indices[i])$i"
            prevvarname = i == 2 ? indices[i-1] : "$(indices[i-1])$(i-1)"
            prevsymbol = i==2 ? esc(Symbol(prevvarname)) : Symbol(prevvarname)
            myexpr = :($(Symbol(varname))=get($(prevsymbol),
                $(indices[i])))
            push!(blockargs,myexpr)
        end
    end
    return Expr(:block,blockargs...)
end

macro ygg(inputexpr)
    return buildyggexpr(inputexpr)
end

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

function printnode(io::IO,node::YggdrasilNode;depth=0,visited=Set())
    padding = (*)([' ' for i in 1:depth+1]...)

    if isempty(visited)
        if isnothing(node.key)
            print(io,padding)
            print(io,"[Root]")
        end
    end

    if !isnothing(node.key) && !(node.key in visited)
        print(io,padding)
        print(io,node.key,"=>")
        if typeof(node.value) == YggdrasilNode
            println()
            printnode(io,node.value,depth=depth+1)
        else
            print(io,node.value)
            println(io)
        end
    end
    if !(isnothing(node.tail))
        printnode(io,node.tail,depth=depth,visited=push!(visited, node.key))
    end
end

#Base.show(io::IO, node::YggdrasilNode) = printnode(io,node)
# this is used to show values in the REPL and when using IJulia
Base.show(io::IO, m::MIME"text/plain", node::YggdrasilNode) = printnode(io,node)

export YggdrasilNode,get,set,@ygg

end # module
