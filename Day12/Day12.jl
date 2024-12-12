""" Advent of Code 2024
    Day 12: Garden Groups 
    Author: Chi-Kit Pao
    julia --optimize=3 Day12.jl
"""

using DataStructures

mutable struct Area
    area::Set{Tuple{Int64,Int64}}
end

mutable struct Map
    row_count::Int64
    column_count::Int64
    rows::Vector{String}
    areas::Dict{Char,Vector{Area}}
end

function fill_area(map_::Map, marked::Matrix{Bool}, row::Int64, column::Int64)::Area
    directions = ((-1, 0), (0, 1), (1, 0), (0, -1))
    marked[row, column] = true
    char = map_.rows[row][column]
    deque = Deque{Tuple{Int64, Int64}}()
    area = Area(Set{Tuple{Int64,Int64}}())
    pos = (row, column)
    push!(area.area, pos)
    push!(deque, pos)
    while !isempty(deque)
        current = popfirst!(deque)
        for direction ∈ directions
            new_row = current[1] + direction[1]
            new_column = current[2] + direction[2]
            try
                if !marked[new_row, new_column] && char == map_.rows[new_row][new_column]
                    marked[new_row, new_column] = true
                    new_pos = (new_row, new_column)
                    push!(area.area, new_pos)
                    push!(deque, new_pos)
                end
            catch BoundsError
            end
        end
    end
    return area
end

function parse_input(file_name::String)::Map
    rows = readlines(file_name)
    map_ = Map(length(rows), length(rows[1]), rows, Dict{Char,Vector{Area}}())
    
    marked = zeros(Bool, (map_.row_count, map_.column_count))

    for row ∈ 1:map_.row_count
        for column ∈ 1:map_.column_count
            if !marked[row, column]
                c = map_.rows[row][column]
                new_area = fill_area(map_, marked, row, column)
                if !haskey(map_.areas, c)
                    map_.areas[c] = [new_area]
                else
                    push!(map_.areas[c], new_area)
                end
            end
        end
    end

    return map_
end

function get_properties(map_::Map, area_::Area)::Tuple{Int64,Int64}
    perimeter = 0
    for e ∈ area_.area
        (row, column) = e
        c = map_.rows[row][column]
        if row == 1 || map_.rows[row-1][column] != c
            perimeter += 1
        end
        if row == map_.row_count || map_.rows[row+1][column] != c
            perimeter += 1
        end
        if column == 1 || map_.rows[row][column-1] != c
            perimeter += 1
        end
        if  column == map_.column_count || map_.rows[row][column+1] != c
            perimeter += 1
        end
    end
    return (length(area_.area), perimeter)
end

function part1(map_::Map)::Int64
    result = 0
    for v ∈ values(map_.areas)
        for a ∈ v
            (area, perimeter) = get_properties(map_, a)
            result += area * perimeter
        end
    end
    return result
end

function main()
    map_ = parse_input("input.txt")
    println("Question 1: What is the total price of fencing all regions on your map?")
    println("Answer: $(part1(map_))")
end

@time main()

# Question 1: What is the total price of fencing all regions on your map?
# Answer: 1473408
#   0.120849 seconds (15.91 k allocations: 10.744 MiB, 12.68% compilation time)

