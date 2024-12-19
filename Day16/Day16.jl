""" Advent of Code 2024
    Day 16: Reindeer Maze
    Author: Chi-Kit Pao
    julia --optimize=3 Day16.jl
"""

const EMPTY = '.'
const START = 'S'
const END = 'E'
const WALL = '#'

const bit_up = 1
const bit_right = 2
const bit_down = 4
const bit_left = 8

const NO_DIR = 0
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
    directions::Int64   # bit field
    fromDirection::Int64
    visit_state::Int64
    distance::Float64
    previousNode::Union{Nothing, Node}
    # four directions to the other nodes + left / straight / right to the same node
    connections::Vector{Union{Nothing, Node}}
end
function Node(pos::Pos, directions::Int64, fromDirection::Int64)::Node
    return Node(pos, directions, fromDirection, UNVISITED, Inf64, nothing, Union{Nothing, Node}[nothing for _ in 1:7])
end

mutable struct Map
    start_pos::Pos
    end_pos::Pos
    start_node::Union{Nothing, Node}
    end_node::Union{Nothing, Node}
    nodes::Dict{Pos, Vector{Union{Nothing, Node}}}
    wall::Set{Pos}
end
function Map()::Map
    return Map(Pos(0, 0), Pos(0, 0), nothing, nothing, Dict{Pos, Vector{Union{Nothing, Node}}}(), Set{Pos}())
end

function get_direction_bits(rows::Vector{String}, row::Int64, column::Int64)::Int64
    result = 0 
    @assert rows[row][column] ∈ (EMPTY, START)
    for i ∈ 1:4
        new_row = row + offsets[i].row
        new_column = column + offsets[i].column
        if rows[new_row][new_column] ∈ (EMPTY, START, END)
            result |= 1 << (i - 1)
        end
    end
    return result
end

function is_junction(bits::Int64)
    vertical = (bits & (bit_up | bit_down)) != 0
    horizontal = (bits & (bit_right | bit_left)) != 0
    return vertical && horizontal
end

function parse_input(file_name::String)::Map
    rows = readlines(file_name)
    map_ = Map()
    
    # Create nodes 
    for (i, line) ∈ enumerate(rows)
        for (j, c) ∈ enumerate(line)
            pos = Pos(i,j)
            if c == EMPTY
                directions = get_direction_bits(rows, i, j)
                if is_junction(directions)
                    map_.nodes[pos] = [
                        rows[pos.row-1][pos.column] ∈ (EMPTY, END) ? Node(Pos(i, j), directions, UP) : nothing, 
                        rows[pos.row][pos.column+1] ∈ (EMPTY, END) ? Node(Pos(i, j), directions, RIGHT) : nothing, 
                        rows[pos.row+1][pos.column] ∈ (EMPTY, END) ? Node(Pos(i, j), directions, DOWN) : nothing, 
                        rows[pos.row][pos.column-1] ∈ (EMPTY, END) ? Node(Pos(i, j), directions, LEFT) : nothing
                        ]
                else
                    map_.nodes[pos] = [Node(Pos(i, j), directions, NO_DIR)]
                end
            elseif c == START
                map_.start_pos = pos
                @assert rows[pos.row+1][pos.column] == WALL
                @assert rows[pos.row][pos.column-1] == WALL
                directions = get_direction_bits(rows, i, j)
                if rows[pos.row-1][pos.column] ∈ (EMPTY, END)
                    map_.start_node = Node(Pos(i, j), directions, LEFT)
                    node_right = (rows[pos.row][pos.column+1] ∈ (EMPTY, END)) ? Node(Pos(i, j), directions, RIGHT) : nothing
                    map_.start_node.distance = 0.0
                    map_.nodes[pos] = [Node(Pos(i, j), directions, UP), 
                        node_right, 
                        nothing, 
                        map_.start_node]
                else
                    map_.start_node = Node(Pos(i, j), directions, NO_DIR)
                    map_.start_node.distance = 0.0
                    map_.nodes[pos] = [map_.start_node]
                end
            elseif c == END
                map_.end_pos = pos
                # No connections from end node
                map_.end_node = Node(Pos(i, j), 0, NO_DIR)
                map_.nodes[pos] = [map_.end_node]
            else
                push!(map_.wall, pos)
                @assert c == WALL
            end
        end
    end

    # Connect nodes
    for (pos, pos_nodes) ∈ pairs(map_.nodes)
        @assert length(pos_nodes) ∈ (1, 4)
        pos_nodes_length = length(pos_nodes)
        if pos_nodes_length == 1
            node = pos_nodes[1]
            @assert !isnothing(node)
            for neighbor_index ∈ (UP, RIGHT, DOWN, LEFT)
                if (node.directions & (1 << (neighbor_index - 1))) != 0
                    neighbor_pos_nodes = map_.nodes[Pos(pos.row + offsets[neighbor_index].row,pos.column + offsets[neighbor_index].column)]
                    if length(neighbor_pos_nodes) == 1
                        node.connections[neighbor_index] = neighbor_pos_nodes[1]
                    else
                        next_index = neighbor_index > 2 ? (neighbor_index + 2 - 4) : neighbor_index + 2
                        node.connections[neighbor_index] = neighbor_pos_nodes[next_index]
                    end
                end
            end
        else
            for node_index ∈ (UP, RIGHT, DOWN, LEFT)
                node = pos_nodes[node_index]
                if isnothing(node)
                    continue
                end
                inner_node_connections = [
                    (RIGHT, DOWN, LEFT),
                    (DOWN, LEFT, UP),
                    (RIGHT, UP, LEFT),
                    (UP, RIGHT, DOWN)
                ]
                for (inner_index, inner_link) ∈ enumerate(inner_node_connections[node_index])
                    node.connections[inner_index + 4] = pos_nodes[inner_link]
                end
                if node_index != node.fromDirection
                    continue
                end
                neighbor_index = node.fromDirection
                if (node.directions & (1 << (neighbor_index - 1))) != 0
                    neighbor_pos_nodes = map_.nodes[Pos(pos.row + offsets[neighbor_index].row,pos.column + offsets[neighbor_index].column)]
                    if length(neighbor_pos_nodes) == 1
                        node.connections[neighbor_index] = neighbor_pos_nodes[1]
                    else
                        next_index = neighbor_index > 2 ? (neighbor_index + 2 - 4) : neighbor_index + 2
                        node.connections[neighbor_index] = neighbor_pos_nodes[next_index]
                    end
                end
            end
        end
    end

    return map_
end

function part1(map_::Map)::Int64
    indices = [6, 1, 2, 3, 4, 5, 7]
    distances = [0.0, 1.0, 1.0, 1.0, 1.0, 1000.0, 1000.0]
    map_.start_node.visit_state = VISITING
    visiting = [map_.start_node]
    while !isempty(visiting)
        (_, min_index) = findmin(n -> n.distance, visiting)
        current_node = popat!(visiting, min_index)
        current_node.visit_state = VISITED
        if current_node == map_.end_node
            return current_node.distance
        end

        for (i, index) ∈ enumerate(indices)
            next_node = current_node.connections[index]
            if !isnothing(next_node) && current_node.pos == (7, 10)
                println("next $(next_node.pos)")
            end
            if isnothing(next_node) || next_node.visit_state == VISITED
                continue
            end
            next_distance = current_node.distance + distances[i]
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
        # println("length $(length(visiting))")
    end
    return -1
end

function main()
    map_ = parse_input("input.txt")

    println("Question 1: What is the lowest score a Reindeer could possibly get?")
    println("Answer: $(part1(map_))")
end

@time main()

# Question 1: What is the lowest score a Reindeer could possibly get?
# Answer: 106512
#  0.194854 seconds (447.77 k allocations: 23.439 MiB, 2.86% gc time, 85.05% compilation time)
