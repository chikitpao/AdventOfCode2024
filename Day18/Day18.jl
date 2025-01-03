""" Advent of Code 2024
    Day 18: RAM Run
    Author: Chi-Kit Pao
    julia --optimize=3 Day18.jl
"""

const EMPTY = '.'
const WALL = '#'

const UP = 1
const RIGHT = 2
const DOWN = 3
const LEFT = 4

const UNVISITED = 0
const VISITING = 1
const VISITED = 2

struct Pos
    row::Int64
    column::Int64
end

const offsets = [Pos(-1, 0), Pos(0, 1), Pos(1, 0), Pos(0, -1)]

mutable struct Node
    pos::Pos
    visit_state::Int64
    distance::Float64
    previousNode::Union{Nothing, Node}
    # four directions to the other nodes
    connections::Vector{Union{Nothing, Node}}
end
function Node(pos::Pos)::Node
    return Node(pos, UNVISITED, Inf64, nothing, Union{Nothing, Node}[nothing for _ in 1:4])
end

mutable struct Map
    start_node::Union{Nothing, Node}
    end_node::Union{Nothing, Node}
    nodes::Dict{Pos, Node}
    walls::Set{Pos}
    length_::Int64
    last_byte::String
end
function Map()::Map
    return Map(nothing, nothing, Dict{Pos, Node}(), Set{Pos}(), 0, "")
end

function parse_input(file_name::String, length_::Int64)::Map
    rows = readlines(file_name)
    map_ = Map()
    map_.length_ = length_
    map_.last_byte = rows[length_]
    row_count = 71
    column_count = 71
    field = zeros(Int64, (row_count, column_count))
    for line ∈ rows[1:length_]
        s = split(line, ",")
        pos = Pos(parse(Int64, s[1]), parse(Int64, s[2]))
        field[pos.row + 1, pos.column + 1] = 1
        push!(map_.walls, pos)
    end
    for (i , line) ∈ enumerate(eachrow(field))
        for (j, v) ∈ enumerate(line)
            if v != 0
                continue
            end
            map_.nodes[Pos(i - 1, j - 1)] = Node(Pos(i - 1, j - 1))
        end
    end
    map_.start_node = map_.nodes[Pos(0, 0)]
    map_.start_node.distance = 0.0
    map_.end_node = map_.nodes[Pos(row_count-1, column_count-1)]
    for node ∈ values(map_.nodes)
        for (dir, o) ∈ enumerate(offsets)
            new_row = node.pos.row + o.row
            new_column = node.pos.column + o.column
            neighbor_pos = Pos(new_row, new_column)
            if haskey(map_.nodes, neighbor_pos)
                node.connections[dir] = map_.nodes[neighbor_pos]
            end
        end
    end
    return map_
end

function get_steps(map_::Map)::Int64
    map_.start_node.visit_state = VISITING
    visiting = [map_.start_node]
    while !isempty(visiting)
        (_, min_index) = findmin(n -> n.distance, visiting)
        current_node = popat!(visiting, min_index)
        current_node.visit_state = VISITED
        if current_node == map_.end_node
            println("Exit found for $(map_.length_) steps.")
            return current_node.distance
        end

        for index ∈ 1:4
            next_node = current_node.connections[index]
            if isnothing(next_node) || next_node.visit_state == VISITED
                continue
            end
            next_distance = current_node.distance + 1.0
            if next_node.visit_state == UNVISITED
                next_node.visit_state = VISITING
                push!(visiting, next_node)
                next_node.distance = next_distance
                next_node.previousNode = current_node
            elseif next_distance < next_node.distance
                next_node.distance = next_distance
                next_node.previousNode = current_node
            end
        end
    end
    println("No exit for $(map_.length_) steps. Last Byte: $(map_.last_byte)")
    return -1
end

function main()
    println("Question 1: What is the minimum number of steps needed to reach the exit?")
    map_ = parse_input("input.txt", 1024)
    println("Answer: $(get_steps(map_))")

    println("Question 2: What are the coordinates of the first byte that will prevent the exit from being reachable from your starting position?")
    # Find the desired step count by bisection
    #
    # Last output lines:
    # average: 3037, lower: 3034, upper: 3041
    # No exit for 3035 steps. Last Byte: 5,60
    # average: 3035, lower: 3034, upper: 3036
    # Exit found for 3034 steps.
    # average: 3034, lower: 3034, upper: 3034
    # => Answer: 5,60
    boundaries = [1025, 3450]
    while boundaries[2] >= boundaries[1]
        average = (boundaries[2] + boundaries[1]) ÷ 2
        map_ = parse_input("input.txt", average)
        steps = get_steps(map_)
        println("average: $average, lower: $(boundaries[1]), upper: $(boundaries[2])")
        changed = false
        if steps == -1
            changed = boundaries[2] != (average - 1)
            boundaries[2] = (average - 1)
        else
            changed = boundaries[1] != (average + 1)
            boundaries[1] = (average + 1)
        end
        if !changed
            break
        end
    end
end

@time main()

# Question 1: What is the minimum number of steps needed to reach the exit?
# Answer: 252
# Question 2: What are the coordinates of the first byte that will prevent the exit from being reachable from your starting position?
# Answer: 5,60
#  0.049011 seconds (237.75 k allocations: 21.649 MiB, 11.20% gc time, 11.21% compilation time)

