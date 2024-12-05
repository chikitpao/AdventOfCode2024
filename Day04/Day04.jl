""" Advent of Code 2024
    Day 4: Ceres Search
    Author: Chi-Kit Pao
    julia --optimize=3 Day04.jl
"""

mutable struct Map
    rows::Vector{String}
    row_count::Int64
    column_count::Int64
end

function find_xmas_count(map_::Map, row::Int64, column::Int64)::Int64
    if map_.rows[row][column] != 'X'
        return 0
    end

    result = 0
    offsets = [Pair(-1, -1), Pair(-1, 0), Pair(-1, 1), Pair(0, -1), Pair(0, 1), 
        Pair(1, -1), Pair(1, 0), Pair(1, 1)]
    test_value = ['M', 'A', 'S']
    for p ∈ offsets
        try
            current_value = [map_.rows[row + i * p[1]][column + i * p[2]] for i ∈ 1:3]
            if current_value == test_value
                result += 1
            end
        catch BoundsError
        end
    end
    return result
end

function find_mas_count(map_::Map, row::Int64, column::Int64)::Int64
    if map_.rows[row][column] != 'A'
        return 0
    end
    
    test_value = ['M', 'S']
    try
        diagonal1 = [map_.rows[row-1][column-1], map_.rows[row+1][column+1]]
        sort!(diagonal1)
        if diagonal1 != test_value
            return 0
        end
        diagonal2 = [map_.rows[row-1][column+1], map_.rows[row+1][column-1]]
        sort!(diagonal2)
        if diagonal2 != test_value
            return 0
        end
        return 1
    catch BoundsError
        return 0
    end
end

function answer(map_::Map, part::Int64)::Int64
    retval = 0
    f = (part == 1) ? find_xmas_count : find_mas_count
    for row ∈ 1:map_.row_count
        for column ∈ 1:map_.column_count
            retval += f(map_, row, column)
        end
    end
    return retval
end

function main()
    map_ = Map(Vector{String}(), 0, 0)
    map_.rows = readlines("input.txt")
    map_.row_count = length(map_.rows)
    map_.column_count = length(map_.rows[1])
   
    println("Question 1: How many times does XMAS appear?")
    println("Answer: $(answer(map_, 1))")
    println("Question 2: How many times does an X-MAS appear?")
    println("Answer: $(answer(map_, 2))")
end

@time main()

# Question 1: How many times does XMAS appear?
# Answer: 2642
# Question 2: How many times does an X-MAS appear?
# Answer: 1974
#  0.120579 seconds (96.56 k allocations: 4.042 MiB, 5.14% compilation time)
