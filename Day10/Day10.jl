""" Advent of Code 2024
    Day 10: Hoof It 
    Author: Chi-Kit Pao
    julia --optimize=3 Day10.jl
"""


mutable struct Map
    row_count::Int64
    column_count::Int64
    rows::Vector{String}
end

function parse_input(file_name::String)::Map
    rows = readlines(file_name)
    return Map(length(rows), length(rows[1]), rows)
end

function dfs1(map_::Map, row::Int64, column::Int64)::Vector{Pair{Int64,Int64}}
    c = map_.rows[row][column]
    if c == '9'
        return [Pair(row, column)]
    end
    result = []
    for direction ∈ ((-1, 0), (0, 1), (1, 0), (0, -1))
        try
            new_row = row + direction[1]
            new_column = column + direction[2]
            if Int(map_.rows[new_row][new_column]) == (Int(c) + 1)
                append!(result, dfs1(map_, new_row, new_column))
            end
        catch BoundsError
        end
    end
    return result
end

function part1(map_::Map)::Int64
    result = 0
    for i ∈ 1:map_.row_count
        for j ∈ 1:map_.column_count
            if map_.rows[i][j] == '0'
               result += length(Set(dfs1(map_, i, j)))
            end
        end
    end
    return result
end

function dfs2(map_::Map, row::Int64, column::Int64)::Vector{Vector{Pair{Int64,Int64}}}
    c = map_.rows[row][column]
    if c == '9'
        return [[Pair(row, column)]]
    end
    result = []
    for direction ∈ ((-1, 0), (0, 1), (1, 0), (0, -1))
        try
            new_row = row + direction[1]
            new_column = column + direction[2]
            if Int(map_.rows[new_row][new_column]) == (Int(c) + 1)
                for v ∈ dfs2(map_, new_row, new_column)
                    temp = append!([Pair(row, column)], v)
                    push!(result, temp)
                end
            end
        catch BoundsError
        end
    end
    return result
end

function part2(map_::Map)::Int64
    result = 0
    for i ∈ 1:map_.row_count
        for j ∈ 1:map_.column_count
            if map_.rows[i][j] == '0'
               result += length(dfs2(map_, i, j))
            end
        end
    end
    return result
end

function main()
    map_ = parse_input("input.txt")
    println("Question 1: What is the sum of the scores of all trailheads on your topographic map?")
    println("Answer: $(part1(map_))")
    println("Question 2: What is the sum of the ratings of all trailheads?")
    println("Answer: $(part2(map_))")
end

@time main()

# Question 1: What is the sum of the scores of all trailheads on your topographic map?
# Answer: 538
# Question 2: What is the sum of the ratings of all trailheads?
# Answer: 1110
#  0.122923 seconds (89.99 k allocations: 5.202 MiB, 14.60% compilation time)
