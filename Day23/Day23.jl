""" Advent of Code 2024
    Day 23: LAN Party
    Author: Chi-Kit Pao
    julia --optimize=3 Day23.jl
"""


using Combinatorics

mutable struct Connections
    computers::Vector{String}
    connections::Set{Tuple{String,String}}
end

function parse_input(file_name::String)::Connections
    computer_set = Set{String}()
    connections = Set{Tuple{String,String}}()
    for line ∈ eachline(file_name)
        (a, b) = split(line, "-")
        if b < a
            (a, b) = (b, a)
        end
        push!(computer_set, a)
        push!(computer_set, b)
        push!(connections, (a, b))
    end
    computers = []
    append!(computers, computer_set)
    sort!(computers)
    return Connections(computers, connections)
end

function part1(connections::Connections)::Int64
    result = 0
    for c ∈ combinations(connections.computers, 3)
        if c[1][1] != 't' && c[2][1] != 't' && c[3][1] != 't'
            continue
        end
        if (c[1], c[2]) ∈ connections.connections && (c[2], c[3]) ∈ connections.connections && (c[1], c[3]) ∈ connections.connections
            result += 1
        end
    end
    return result
end

function part2(connections::Connections)::String
    dd = Dict{String, Vector{String}}()
    for connection ∈ connections.connections
        if !haskey(dd, connection[1])
            dd[connection[1]] = [connection[1], connection[2]]
        else
            push!(dd[connection[1]], connection[2])
        end
        if !haskey(dd, connection[2])
            dd[connection[2]] = [connection[2], connection[1]]
        else
            push!(dd[connection[2]], connection[1])
        end
    end
    results = []
    remaining = 12
    # No result for remaining = 13 but result for remaining = 12
    for (k, v) ∈ dd
        max_set = dd[k]
        for intersection_set ∈ combinations(max_set[2:end], remaining)
            intersection_set2 = append!([k], intersection_set)
            for vv ∈ intersection_set
                intersection_set2 = intersect(intersection_set2, dd[vv])
            end
            if length(intersection_set2) == length(intersection_set) + 1
                push!(results, intersection_set2)
            end
        end
    end
    @assert length(results) == remaining + 1
    return join(sort!(results[1]),",")
end

function main()
    connections = parse_input("input.txt")
    
    println("Question 1: How many sets of three inter-connected computers contain at least one computer with a name that starts with t?")
    println("Answer: $(part1(connections))")
    println("Question 2: What is the password to get into the LAN party?")
    println("Answer: $(part2(connections))")
end

@time main()

# Question 1: How many sets of three inter-connected computers contain at least one computer with a name that starts with t?
# Answer: 1098
# Question 2: What is the password to get into the LAN party?
# Answer: ar,ep,ih,ju,jx,le,ol,pk,pm,pp,xf,yu,zg
#   1.309821 seconds (70.82 M allocations: 2.522 GiB, 4.96% gc time, 2.58% compilation time)
