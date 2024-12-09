""" Advent of Code 2024
    Day 9: Disk Fragmenter (Part1)
    Author: Chi-Kit Pao
    julia --optimize=3 Day09_1.jl
"""

using DataStructures

struct Data
    pos::Int64  # one-based position
    id::Int32  # id (zero-based), -1 if free
end

mutable struct Disk
    metadata::Vector{Int32}
    data::Vector{Int32}
    free::Deque{Data}
    occupied::Deque{Data}
end

const FREE_ID = -1

function parse_input(file_name::String)::Disk
    disk = Disk([Int32(i) - Int32('0') for i ∈ collect(readline(file_name))], Vector{Int32}(),
        Deque{Data}(), Deque{Data}())
    id = 0
    pos = 1
    for (i, m) ∈ enumerate(disk.metadata)
        if i % 2 == 1
            # occupied
            @assert m != 0
            for j ∈ 1:m
                push!(disk.occupied, Data(pos, id))
                push!(disk.data, id)
                pos += 1
            end
            id += 1
        else
            # free
            for j ∈ 1:m
                push!(disk.free, Data(pos, FREE_ID))
                push!(disk.data, FREE_ID)
                pos += 1
            end
        end
    end
    return disk
end

function part1(disk::Disk)
    occupied_count = length(disk.occupied)
    while length(disk.free) > 0
        free_ = popfirst!(disk.free)
        occupied_ = pop!(disk.occupied)
        if free_.pos >= occupied_.pos
            break
        end
        disk.data[free_.pos] = occupied_.id
        disk.data[occupied_.pos] = FREE_ID
    end
    temp = [(i - 1) * v for (i, v) ∈ enumerate(disk.data[1:occupied_count])]
    result = sum(temp)

    return result
end

function main()
    disk = parse_input("input.txt")
    println("Question 1: What is the resulting filesystem checksum?")
    println("Answer: $(part1(deepcopy(disk)))")
end

@time main()

# Question 1: What is the resulting filesystem checksum?
# Answer: 6370402949053
#  0.096650 seconds (78.08 k allocations: 8.234 MiB, 95.51% compilation time)