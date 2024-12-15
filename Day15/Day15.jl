""" Advent of Code 2024
    Day 15: Warehouse Woes
    Author: Chi-Kit Pao
    julia --optimize=3 Day15.jl
"""

const EMPTY = '.'
const ROBOT = '@'
const BOX = 'O'
const WALL = '#'

mutable struct Map
    robot::Tuple{Int64,Int64}
    rows::Vector{Vector{Char}}
    instructions::String
end

struct Direction
    offset::Tuple{Int64,Int64}
    instruction::Char
end

struct NextTile
    coordinates::Tuple{Int64,Int64}
    tile::Char
end

function parse_input(file_name::String)::Map
    lines = readlines(file_name)
    empty_line_index = findfirst(x -> x == "", lines)
    @assert !isnothing(empty_line_index)

    map_ = Map((0, 0), Vector{Vector{Char}}(), "")
    found_robot = false
    for (i, line) ∈ enumerate(lines[1:empty_line_index-1])
        push!(map_.rows, collect(line))
        if !found_robot && !isnothing(findfirst(x -> x == ROBOT, line))
            map_.robot = (i, findfirst(x -> x == ROBOT, line))
            found_robot = true
        end
    end
    @assert map_.robot != (0, 0)

    map_.instructions = join(lines[(empty_line_index+1):length(lines)])
    return map_
end

function do_step(map_::Map, instruction::Char)
    directions = [Direction((-1, 0), '^'), Direction((0, 1), '>'), Direction((1, 0), 'v'), Direction((0, -1), '<')]
    next_tiles = []
    next_coordinates = (map_.robot[1], map_.robot[2])
    direction = directions[findfirst(x -> (x.instruction == instruction), directions)]
    while true
        try
            next_coordinates = (next_coordinates[1] + direction.offset[1], next_coordinates[2] + direction.offset[2])
            #println("1 ", next_tiles, " next_coordinates $next_coordinates")
            next_tile = NextTile((next_coordinates[1], next_coordinates[2]), map_.rows[next_coordinates[1]][next_coordinates[2]])
            push!(next_tiles, next_tile)
            #println("2 ", next_tiles)
            if next_tile.tile == EMPTY || next_tile.tile == WALL
                break
            end
        catch BoundsError
            break
        end
    end
    len = length(next_tiles)
    @assert len >= 1
    if last(next_tiles).tile == WALL
        # Stay at position
        return
    elseif last(next_tiles).tile == EMPTY
        # Move everything to the empty tile. Robot position will be empty
        for i ∈ length(next_tiles):-1:2
            map_.rows[next_tiles[i].coordinates[1]][next_tiles[i].coordinates[2]] = map_.rows[next_tiles[i-1].coordinates[1]][next_tiles[i-1].coordinates[2]]
        end
        map_.rows[next_tiles[1].coordinates[1]][next_tiles[1].coordinates[2]] = ROBOT
        map_.rows[map_.robot[1]][map_.robot[2]] = EMPTY
        map_.robot = next_tiles[1].coordinates
    end
end

function coordinates_sum(map_::Map)::Int64
    result = 0
    for i ∈ 1:length(map_.rows)
        for j ∈ 1:length(map_.rows[1])
            if map_.rows[i][j] == BOX
                result += 100 * (i - 1) + (j - 1)
            end
        end
    end
    return result
end

function part1(map_::Map)::Int64
    for i ∈ 1:length(map_.instructions)
        do_step(map_, map_.instructions[i])
    end
    return coordinates_sum(map_)
end

function main()
    map_ = parse_input("input.txt")
    
    # length(map_.instructions): 20000
    println("length(map_.instructions): ", length(map_.instructions))
    
    println("Question 1: What is the sum of all boxes' GPS coordinates?")
    println("Answer: $(part1(map_))")
end

@time main()

# Question 1: What is the sum of all boxes' GPS coordinates?
# Answer: 1426855
#  0.103000 seconds (342.09 k allocations: 14.006 MiB, 70.18% compilation time)