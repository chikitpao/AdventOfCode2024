""" Advent of Code 2024
    Day 8: Resonant Collinearity
    Author: Chi-Kit Pao
    julia --optimize=3 Day08.jl
"""

using Combinatorics
using DataStructures

mutable struct Antinode
    pos::Pair{Int64, Int64}
    valid::Bool
    digit_bits::Int16
    upper_letter_bits::Int32
    lower_letter_bits::Int32
end

mutable struct Map
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
    antinode = nothing
    if haskey(map_.antinodes, pos)
        antinode = map_.antinodes[pos]
    else
        antinode = Antinode(pos, false, 0, 0, 0)
        map_.antinodes[pos] = antinode
    end
    if isdigit(name)
        antinode.digit_bits |= (1 << (Int16(name) - Int16('0')))
    elseif islowercase(name)
        antinode.lower_letter_bits |= (1 << (Int32(name) - Int32('a')))
    elseif isuppercase(name)
        antinode.upper_letter_bits |= (1 << (Int32(name) - Int32('A')))
    end
end

function calculate_antinodes(map_::Map)
    for (name, positions) ∈ pairs(map_.antennas)
        for c ∈ combinations(positions, 2)
            # Calculate Antinode positions
            dx = c[2][2] - c[1][2]
            dy = c[2][1] - c[1][1]
            pos1 = Pair(c[1][1] - dy, c[1][2] - dx)
            pos2 = Pair(c[2][1] + dy, c[2][2] + dx)
            if check_position(map_, pos1)
                add_antinode(map_, name, pos1)
            end
            if check_position(map_, pos2)
                add_antinode(map_, name, pos2)
            end
        end
    end
    for an ∈ values(map_.antinodes)
        an.valid = an.digit_bits != 0 || an.lower_letter_bits != 0 || an.upper_letter_bits != 0
    end
end

function parse_input(file_name::String)::Map
    map_ = Map(SortedDict{Char, Vector{Pair{Int64, Int64}}}(), 
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

function part1(map_::Map)::Int64
    result = 0
    for an ∈ values(map_.antinodes)
        if an.valid
            result += 1
        end
    end
    return result
end

function main()
    map_ = parse_input("input.txt")
    println("Question 1: How many unique locations within the bounds of the map contain an antinode?")
    println("Answer: $(part1(map_))")
end

@time main()

# Question 1: How many unique locations within the bounds of the map contain an antinode?
# Answer: 254
#  0.402314 seconds (351.26 k allocations: 16.979 MiB, 99.30% compilation time)
