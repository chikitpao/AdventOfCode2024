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

function get_properties1(map_::Map, area_::Area)::Tuple{Int64,Int64}
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
            (area, perimeter) = get_properties1(map_, a)
            result += area * perimeter
        end
    end
    return result
end

mutable struct HLine
    row::Int64 # row below
    column1::Int64
    column2::Int64
    side::Int64  # 0: upper, 1: lower
end
mutable struct VLine
    row1::Int64
    row2::Int64
    column::Int64 # column on the left
    side::Int64  # 0: left, 1: right
end

Base.isless(a::HLine, b::HLine) = a.column1 < b.column1
Base.isless(a::VLine, b::VLine) = a.row1 < b.row1

function get_properties2(map_::Map, area_::Area)::Tuple{Int64,Int64}
    hdict = Dict{Int64, Vector{HLine}}()
    vdict = Dict{Int64, Vector{VLine}}()
    
    for e ∈ area_.area
        (row, column) = e
        c = map_.rows[row][column]
        if row == 1 || map_.rows[row-1][column] != c
            if !haskey(hdict, row)
                hdict[row] = [HLine(row, column, column, 1)]
            else
                push!(hdict[row], HLine(row, column, column, 1))
            end
        end
        if row == map_.row_count || map_.rows[row+1][column] != c
            if !haskey(hdict, row+1)
                hdict[row+1] = [HLine(row+1, column, column, 0)]
            else
                push!(hdict[row+1], HLine(row+1, column, column, 0))
            end
        end
        if column == 1 || map_.rows[row][column-1] != c
            if !haskey(vdict, column-1)
                vdict[column-1] = [VLine(row, row, column-1, 1)]
            else
                push!(vdict[column-1], VLine(row, row, column-1, 1))
            end
        end
        if  column == map_.column_count || map_.rows[row][column+1] != c
            if !haskey(vdict, column)
                vdict[column] =  [VLine(row, row, column, 0)]
            else
                push!(vdict[column], VLine(row, row, column, 0))
            end
        end
    end
    for v ∈ values(hdict)
        sort!(v)
        i = 1
        len = length(v)
        while i + 1 <= len
            if (v[i].column2 + 1) == v[i+1].column1 && v[i].side == v[i+1].side
                v[i].column2 = v[i+1].column2
                deleteat!(v, i+1)
                len -= 1
                # i remains the same
            else
                i += 1
            end
        end
    end
    for v ∈ values(vdict)
        sort!(v)
        i = 1
        len = length(v)
        while i + 1 <= len
            if (v[i].row2 + 1) == v[i+1].row1 && v[i].side == v[i+1].side
                v[i].row2 = v[i+1].row2
                deleteat!(v, i+1)
                len -= 1
                # i remains the same
            else
                i += 1
            end
        end
    end
    hsides = sum([length(v) for v ∈ values(hdict)])
    vsides = sum([length(v) for v ∈ values(vdict)])
    return (length(area_.area), hsides + vsides)
end

function part2(map_::Map)::Int64
    result = 0
    for v ∈ values(map_.areas)
        for a ∈ v
            (area, sides) = get_properties2(map_, a)
            result += area * sides
        end
    end
    return result
end

function main()
    map_ = parse_input("input.txt")
    println("Question 1: What is the total price of fencing all regions on your map?")
    println("Answer: $(part1(map_))")
    println("Question 2: What is the new total price of fencing all regions on your map?")
    println("Answer: $(part2(map_))")
end

@time main()

# Question 1: What is the total price of fencing all regions on your map?
# Answer: 1473408
# Question 2: What is the new total price of fencing all regions on your map?
# Answer: 886364
#  0.126548 seconds (57.15 k allocations: 13.172 MiB, 4.46% gc time, 11.94% compilation time)
