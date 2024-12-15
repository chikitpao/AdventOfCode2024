""" Advent of Code 2024
    Day 15: Warehouse Woes
    Author: Chi-Kit Pao
    julia --optimize=3 Day15.jl
"""

const EMPTY = '.'
const ROBOT = '@'
const BOX = 'O'
const WALL = '#'
const BOX_LEFT = '['
const BOX_RIGHT = ']'

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

function do_step1(map_::Map, instruction::Char)
    directions = [Direction((-1, 0), '^'), Direction((0, 1), '>'), Direction((1, 0), 'v'), Direction((0, -1), '<')]
    next_tiles = []
    next_coordinates = (map_.robot[1], map_.robot[2])
    direction = directions[findfirst(x -> (x.instruction == instruction), directions)]
    while true
        try
            next_coordinates = (next_coordinates[1] + direction.offset[1], next_coordinates[2] + direction.offset[2])
            next_tile = NextTile((next_coordinates[1], next_coordinates[2]), map_.rows[next_coordinates[1]][next_coordinates[2]])
            push!(next_tiles, next_tile)
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
        # Move everything to the empty tile. Robot position will be empty.
        for i ∈ length(next_tiles):-1:2
            map_.rows[next_tiles[i].coordinates[1]][next_tiles[i].coordinates[2]] = map_.rows[next_tiles[i-1].coordinates[1]][next_tiles[i-1].coordinates[2]]
        end
        map_.rows[next_tiles[1].coordinates[1]][next_tiles[1].coordinates[2]] = ROBOT
        map_.rows[map_.robot[1]][map_.robot[2]] = EMPTY
        map_.robot = next_tiles[1].coordinates
    end
end

function coordinates_sum1(map_::Map)::Int64
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

function do_step2(map_::Map, instruction::Char)
    directions = [Direction((-1, 0), '^'), Direction((0, 1), '>'), Direction((1, 0), 'v'), Direction((0, -1), '<')]
    next_tiles::Vector{Vector{NextTile}} = []
    next_coordinates::Vector{Tuple{Int64,Int64}} = [(map_.robot[1], map_.robot[2])]
    direction = directions[findfirst(x -> (x.instruction == instruction), directions)]
    move_vertical = direction.instruction ∈ ('^', 'v')
    while true
        try
            old_next_coordinates = next_coordinates
            next_coordinates = []
            if move_vertical
                next_coordinates_set = Set{Tuple{Int64,Int64}}()
                for onc ∈ old_next_coordinates
                    test_coordinates = (onc[1]+direction.offset[1], onc[2]+direction.offset[2])
                    # Any wall found -> return
                    # => Stay at position
                    if map_.rows[test_coordinates[1]][test_coordinates[2]] == WALL
                        return
                    end
                    if map_.rows[test_coordinates[1]][test_coordinates[2]] != EMPTY
                        push!(next_coordinates_set, test_coordinates)
                    end
                    if map_.rows[test_coordinates[1]][test_coordinates[2]] == BOX_LEFT
                        push!(next_coordinates_set, (test_coordinates[1], test_coordinates[2] + 1))
                    elseif map_.rows[test_coordinates[1]][test_coordinates[2]] == BOX_RIGHT
                        push!(next_coordinates_set, (test_coordinates[1], test_coordinates[2] - 1))
                    end
                end
                append!(next_coordinates, next_coordinates_set)
            else
                @assert length(old_next_coordinates) == 1
                test_coordinates = (old_next_coordinates[1][1]+direction.offset[1], old_next_coordinates[1][2]+direction.offset[2])
                
                # Any wall found -> return
                # => Stay at position
                if map_.rows[test_coordinates[1]][test_coordinates[2]] == WALL
                    return
                end
                if map_.rows[test_coordinates[1]][test_coordinates[2]] != EMPTY
                    next_coordinates = [test_coordinates]
                end
            end
            current_next_tiles = [NextTile(pos, map_.rows[pos[1]][pos[2]]) for pos ∈ next_coordinates]
            # All empty -> abort loop
            # => Move boxes.
            @assert all([(tile.tile != EMPTY) for tile ∈ current_next_tiles])
            if isempty(current_next_tiles)
                break
            end

            # Else -> box found -> stay in loop
            # => Find boxes behind the current pile.
            push!(next_tiles, current_next_tiles)
        catch e # all types
            if e isa BoundsError
                # handle exception
                println("It shouldn't be BoundsError at all!")
                println(e)
                exit(-1)
            else
                rethrow(e)
            end
        end
    end

    # Move everything to the empty tiles. Robot position will be empty.
    for i ∈ length(next_tiles):-1:1
        empty_tiles = []
        current_tiles = next_tiles[i]
        for tile ∈ current_tiles
            push!(empty_tiles, (tile.coordinates[1], tile.coordinates[2]))
            map_.rows[tile.coordinates[1]+direction.offset[1]][tile.coordinates[2]+direction.offset[2]] = map_.rows[tile.coordinates[1]][tile.coordinates[2]]
        end
        for tile ∈ empty_tiles
            map_.rows[tile[1]][tile[2]] = EMPTY
        end
    end
    robot_next_coordinates = (map_.robot[1]+direction.offset[1], map_.robot[2]+direction.offset[2])
    map_.rows[robot_next_coordinates[1]][robot_next_coordinates[2]] = ROBOT
    map_.rows[map_.robot[1]][map_.robot[2]] = EMPTY
    map_.robot = robot_next_coordinates
end

function coordinates_sum2(map_::Map)::Int64
    result = 0
    for i ∈ 1:length(map_.rows)
        for j ∈ 1:length(map_.rows[1])
            if map_.rows[i][j] == BOX_LEFT
                result += 100 * (i - 1) + (j - 1)
            end
        end
    end
    return result
end

function answer(map_::Map, part::Int64)::Int64
    do_step = (part == 1) ? do_step1 : do_step2
    coordinates_sum = (part == 1) ? coordinates_sum1 : coordinates_sum2
    for i ∈ 1:length(map_.instructions)
        do_step(map_, map_.instructions[i])
    end
    return coordinates_sum(map_)
end

function transform_map(map_::Map)
    map_.robot = (map_.robot[1], map_.robot[2] * 2 - 1)
    for i ∈ 1:length(map_.rows)
        new_row = []
        for c ∈ map_.rows[i]
            if c == EMPTY
                append!(new_row, (EMPTY, EMPTY))
            elseif c == ROBOT
                append!(new_row, (ROBOT, EMPTY))
            elseif c == BOX
                append!(new_row, (BOX_LEFT, BOX_RIGHT))
            elseif c == WALL
                append!(new_row, (WALL, WALL))
            end
        end
        map_.rows[i] = new_row
    end
end

function main()
    map1 = parse_input("input.txt")
    # length(map1.instructions): 20000
    println("length(map1.instructions): ", length(map1.instructions))
    
    println("Question 1: What is the sum of all boxes' GPS coordinates?")
    println("Answer: $(answer(map1, 1))")
    
    map2 = parse_input("input.txt")
    transform_map(map2)
    println("Question 2: What is the sum of all boxes' final GPS coordinates?")
    println("Answer: $(answer(map2, 2))")
end

@time main()

# Question 1: What is the sum of all boxes' GPS coordinates?
# Answer: 1426855
# Question 2: What is the sum of all boxes' final GPS coordinates?
# Answer: 1404917
#  0.565680 seconds (1.59 M allocations: 76.834 MiB, 7.74% gc time, 92.99% compilation time)
