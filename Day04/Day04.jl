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

function check_coordinates(map_::Map, row::Int64, column::Int64)
    if row <= 0
        return false
    elseif row > map_.row_count
        return false
    elseif column <= 0
        return false
    elseif column > map_.column_count
        return false
    end
    return true
end

function find_xmas_count(map_::Map, stack::Vector{Pair{Int64, Int64}}, direction::Int64, retval::Vector{Int64})
    stack_size = length(stack)
    @assert stack_size >= 1 && stack_size <= 4

    result = 0
    (row, column) = last(stack)
    if stack_size == 1 && map_.rows[row][column] != 'X'
        return
    elseif stack_size == 2 && map_.rows[row][column] != 'M'
        return
    elseif stack_size == 3 && map_.rows[row][column] != 'A'
        return
    elseif stack_size == 4
        if map_.rows[row][column] == 'S'
            retval[1] += 1
        end
        return
    end

    offsets = [Pair(-1, -1), Pair(-1, 0), Pair(-1, 1), Pair(0, -1), Pair(0, 1), 
        Pair(1, -1), Pair(1, 0), Pair(1, 1)]
    next_steps = direction == -1 ? collect(enumerate(offsets)) : [(direction, offsets[direction])]
    for (dir, p) ∈ next_steps
        new_row = row + p[1]
        new_column = column + p[2]
        if check_coordinates(map_, new_row, new_column)
            new_stack = deepcopy(stack)
            push!(new_stack, Pair(new_row, new_column))
            find_xmas_count(map_, new_stack, dir, retval)
        end
    end
end

function part1(map_::Map)
    retval = [0]
    for row ∈ 1:map_.row_count
        for column ∈ 1:map_.column_count
            find_xmas_count(map_, [Pair(row, column)], -1, retval)
        end
    end
    return retval[1]
end

function find_mas_count(map_::Map, row::Int64, column::Int64, retval::Vector{Int64})
    if map_.rows[row][column] != 'A'
        return
    end
    
    try
        test_value = ['M', 'S']
        diagonal1 = [map_.rows[row-1][column-1], map_.rows[row+1][column+1]]
        sort!(diagonal1)
        if diagonal1 != test_value
            return
        end
        diagonal2 = [map_.rows[row-1][column+1], map_.rows[row+1][column-1]]
        sort!(diagonal2)
        if diagonal2 != test_value
            return
        end
        retval[1] += 1
    catch BoundsError
        return
    end
end

function answer(map_::Map, part::Int64)
    retval = [0]
    for row ∈ 1:map_.row_count
        for column ∈ 1:map_.column_count
            if part == 1
                find_xmas_count(map_, [Pair(row, column)], -1, retval)
            else
                find_mas_count(map_, row, column, retval)
            end
        end
    end
    return retval[1]
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
#  0.162051 seconds (406.49 k allocations: 33.541 MiB, 22.68% gc time, 6.11% compilation time)
