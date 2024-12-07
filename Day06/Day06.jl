""" Advent of Code 2024
    Day 6: Guard Gallivant
    Author: Chi-Kit Pao
    julia --optimize=3 Day06.jl
"""

@enum Direction UP=1 RIGHT=2 DOWN=3 LEFT=4

mutable struct Map
    guard_pos::Pair{Int64, Int64}
    direction::Direction
    rows::Vector{String}
end

function parse_input(file_name::String)::Map
    map_ = Map(Pair{Int64, Int64}(0, 0), UP, Vector{String}())
    found_guard = false
    map_.rows = readlines(file_name)
    for (i, row) ∈ enumerate(map_.rows)
        j = findfirst('^', row)
        if !isnothing(j)
            map_.guard_pos = Pair(i, j)
        end
    end
    @assert map_.guard_pos != Pair(0, 0)
    return map_
end

function do_step(map_::Map)::Bool
    offsets = [Pair(-1, 0), Pair(0, 1), Pair(1, 0), Pair(0, -1)]
    next_direction = [RIGHT, DOWN, LEFT, UP]
    next_x = map_.guard_pos[1] + offsets[Integer(map_.direction)][1]
    next_y = map_.guard_pos[2] + offsets[Integer(map_.direction)][2]
    next_pos = Pair(next_x, next_y)
    if next_pos[1] <= 0 || next_pos[1] > length(map_.rows)
        return false
    elseif next_pos[2] <= 0 || next_pos[2] > length(map_.rows[1])
        return false
    elseif map_.rows[next_pos[1]][next_pos[2]] == '#' || map_.rows[next_pos[1]][next_pos[2]] == 'O'
        map_.direction = next_direction[Integer(map_.direction)]
        return do_step(map_)
    else
        map_.guard_pos = next_pos
        return true
    end
end

function part1(map_::Map)::Int64
    visited = Set{Pair{Int64, Int64}}()
    push!(visited, deepcopy(map_.guard_pos))
    while do_step(map_)
        push!(visited, deepcopy(map_.guard_pos))
    end
    return length(visited)
end

function part2(map_::Map)::Int64
    result = 0
    for i ∈ 1:length(map_.rows)
        for j ∈ 1:length(map_.rows[1])
            map_item = map_.rows[i][j]
            if map_item == '#' || map_item == '^'
                continue
            end
            map_copy = deepcopy(map_)
            
            char_array = collect(map_copy.rows[i])
            char_array[j] = 'O'
            map_copy.rows[i] = String(char_array)

            visited = Set{Tuple{Int64, Int64, Int64}}()
            push!(visited, (map_copy.guard_pos[1], map_copy.guard_pos[2], Int64(map_copy.direction)))
            while do_step(map_copy)
                tuple = (map_copy.guard_pos[1], map_copy.guard_pos[2], Int64(map_copy.direction))
                if tuple ∈ visited
                    result += 1
                    break
                end
                push!(visited, tuple)
            end
        end
    end
    return result
end

function main()
    map_ = parse_input("input.txt")
    println("Question 1: How many distinct positions will the guard visit before leaving the mapped area?")
    println("Answer: $(part1(deepcopy(map_)))")
    println("Question 2: How many different positions could you choose for this obstruction?")
    println("Answer: $(part2(map_))")
end

@time main()

# Question 1: How many distinct positions will the guard visit before leaving the mapped area?
# Answer: 5177
# Question 2: How many different positions could you choose for this obstruction?
# Answer: 1686
#  19.049353 seconds (332.29 M allocations: 23.807 GiB, 5.24% gc time, 0.61% compilation time)
