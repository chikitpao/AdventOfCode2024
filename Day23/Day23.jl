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

function main()
    connections = parse_input("input.txt")
    
    println("Question 1: How many sets of three inter-connected computers contain at least one computer with a name that starts with t?")
    println("Answer: $(part1(connections))")
end

@time main()

# Question 1:  How many sets of three inter-connected computers contain at least one computer with a name that starts with t?
# Answer: 1098
#  1.173640 seconds (69.93 M allocations: 2.432 GiB, 7.28% gc time, 2.14% compilation time)
