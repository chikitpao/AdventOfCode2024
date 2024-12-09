""" Advent of Code 2024
    Day 8: Resonant Collinearity
    Author: Chi-Kit Pao
    julia --optimize=3 Day08.jl
"""

using Combinatorics
using DataStructures

mutable struct Antinode
    pos::Pair{Int64, Int64}
end

mutable struct Map
    part::Int64
    antennas::SortedDict{Char, Vector{Pair{Int64, Int64}}}
    antinodes::SortedDict{Pair{Int64, Int64}, Antinode}
    rows::Vector{String}
end

function add_antenna(map_, i, j, c)
    if haskey(map_.antennas, c)
        push!(map_.antennas[c], Pair(i, j))
    else
        map_.antennas[c] = [Pair(i, j)]
    end
end

function check_position(map_::Map, pos::Pair{Int64,Int64})::Bool
    if pos[1] <= 0 || pos[1] > length(map_.rows)
        return false
    end
    if pos[2] <= 0 || pos[2] > length(map_.rows[1])
        return false
    end
    return true;
end

function add_antinode(map_::Map, name::Char, pos::Pair{Int64,Int64})
    if !haskey(map_.antinodes, pos)
        map_.antinodes[pos] = Antinode(pos)
    end
end

function calculate_antinodes(map_::Map)
    for (name, positions) ∈ pairs(map_.antennas)
        if length(positions) > 1 && map_.part == 2
            for p ∈ positions
                add_antinode(map_, name, deepcopy(p))
            end
        end
        for c ∈ combinations(positions, 2)
            # Calculate Antinode positions
            dx = c[2][2] - c[1][2]
            dy = c[2][1] - c[1][1]
            pos1 = Pair(c[1][1] - dy, c[1][2] - dx)
            pos2 = Pair(c[2][1] + dy, c[2][2] + dx)
            if map_.part == 1
                if check_position(map_, pos1)
                    add_antinode(map_, name, pos1)
                end
                if check_position(map_, pos2)
                    add_antinode(map_, name, pos2)
                end
            else
                while check_position(map_, pos1)
                    add_antinode(map_, name, deepcopy(pos1))
                    pos1 = Pair(pos1[1] - dy, pos1[2] - dx)
                end
                while check_position(map_, pos2)
                    add_antinode(map_, name, deepcopy(pos2))
                    pos2 = Pair(pos2[1] + dy, pos2[2] + dx)
                end
            end
        end
    end
end

function parse_input(file_name::String, part::Int64)::Map
    map_ = Map(part, SortedDict{Char, Vector{Pair{Int64, Int64}}}(), 
        SortedDict{Pair{Int64, Int64}, Antinode}(), Vector{String}())
    map_.rows = readlines(file_name)
    for i ∈ 1:length(map_.rows)
        for (j, c) ∈ enumerate(map_.rows[i])
            if isdigit(c) || isletter(c)
                add_antenna(map_, i, j, c)
            end
        end
    end
    calculate_antinodes(map_)
    return map_
end

function answer(map_::Map)::Int64
    return length(collect(values(map_.antinodes)))
end

function main()
    println("Question 1: How many unique locations within the bounds of the map contain an antinode?")
    println("Answer: $(answer(parse_input("input.txt", 1)))")
    println("Question 2: How many unique locations within the bounds of the map contain an antinode?")
    println("Answer: $(answer(parse_input("input.txt", 2)))")
end

@time main()

# Question 1: How many unique locations within the bounds of the map contain an antinode?
# Answer: 254
# Question 2: How many unique locations within the bounds of the map contain an antinode?
# Answer: 951
#  0.400880 seconds (373.92 k allocations: 18.169 MiB, 99.09% compilation time)
