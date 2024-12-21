""" Advent of Code 2024
    Day 20: Race Condition
    Author: Chi-Kit Pao
    julia --optimize=3 Day20.jl
"""

const EMPTY = '.'
const START = 'S'
const END = 'E'
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
    cheats::Vector{Node}
end
function Map()::Map
    return Map(nothing, nothing, Dict{Pos, Node}(), Set{Pos}(), Vector{Node}())
end

function parse_input(file_name::String)::Map
    rows = 
    map_ = Map()
    i = 0
    row_count = 0
    column_count = 0
    for line ∈ eachline(file_name)
        i += 1
        row_count = i
        column_count = length(line)
        for (j, v) ∈ enumerate(line)
            if v == WALL
                push!(map_.walls, Pos(i,j))
                continue
            end
            node = Node(Pos(i,j))
            map_.nodes[Pos(i,j)] = node
            if v == START
                map_.start_node = node
                map_.start_node.distance = 0.0
            elseif v == END
                map_.end_node = node
            end
        end
    end

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

    for wall ∈ values(map_.walls)
        if wall.row ∈ (1, row_count) || wall.column ∈ (1, column_count)
            continue
        end
        connections::Vector{Union{Nothing, Node}} = [nothing for _ in 1:4]
        neighbor_count = 0
        for (dir, o) ∈ enumerate(offsets)
            new_row = wall.row + o.row
            new_column = wall.column + o.column
            neighbor_pos = Pos(new_row, new_column)
            if haskey(map_.nodes, neighbor_pos)
                connections[dir] = map_.nodes[neighbor_pos]
                neighbor_count += 1
            end
        end
        if neighbor_count >= 2
            cheat = Node(wall)
            cheat.connections = connections
            push!(map_.cheats, cheat)
        end
    end
    return map_
end

function reset(map_::Map)
    for node ∈ values(map_.nodes)
        node.visit_state = UNVISITED
        node.distance = Inf64
        node.previousNode = nothing
    end
    for node ∈ values(map_.cheats)
        node.visit_state = UNVISITED
        node.distance = Inf64
        node.previousNode = nothing
    end
    map_.start_node.visit_state = VISITING
    map_.start_node.distance = 0.0
end

function apply_cheat(map_::Map, cheat::Union{Nothing, Node})
    if isnothing(cheat)
        return
    end
    for dir ∈ 1:4
        neighbor_node = cheat.connections[dir]
        if !isnothing(neighbor_node)
            opposite_dir = (dir > 2) ? (dir - 2) : (dir + 2)
            neighbor_node.connections[opposite_dir] = cheat
        end
    end
end

function undo_cheat(map_::Map, cheat::Union{Nothing, Node})
    if isnothing(cheat)
        return
    end
    for dir ∈ 1:4
        neighbor_node = cheat.connections[dir]
        if !isnothing(neighbor_node)
            opposite_dir = (dir > 2) ? (dir - 2) : (dir + 2)
            neighbor_node.connections[opposite_dir] = nothing
        end
    end
end

function get_steps(map_::Map, cheat::Union{Nothing, Node})::Int64
    reset(map_)
    visiting = [map_.start_node]
    apply_cheat(map_, cheat)

    while !isempty(visiting)
        (_, min_index) = findmin(n -> n.distance, visiting)
        current_node = popat!(visiting, min_index)
        current_node.visit_state = VISITED
        if current_node == map_.end_node
            undo_cheat(map_, cheat)
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
    undo_cheat(map_, cheat)
    return -1
end

function main()
    println("Question 1: How many cheats would save you at least 100 picoseconds?")
    map_ = parse_input("input.txt")
    steps_needed_orig = get_steps(map_, nothing)
    steps_saved = []
    for cheat ∈ map_.cheats
        push!(steps_saved, steps_needed_orig - get_steps(map_, cheat))
    end
    answer1 = count(x -> x >= 100, steps_saved)
    println("Answer: $answer1")
end

@time main()

# Question 1: How many cheats would save you at least 100 picoseconds?
# Answer: 1445
#  1.892123 seconds (112.96 k allocations: 6.573 MiB, 0.52% compilation time)