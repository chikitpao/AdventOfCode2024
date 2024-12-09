""" Advent of Code 2024
    Day 9: Disk Fragmenter (Part 2)
    Author: Chi-Kit Pao
    julia --optimize=3 Day09_2.jl
"""

using DataStructures

# MutableLinkedList:
# https://juliacollections.github.io/DataStructures.jl/latest/mutable_linked_list/
#
# l = MutableLinkedList{T}()        # initialize an empty list of type T
# l = MutableLinkedList{T}(elts...) # initialize a list with elements of type T
# isempty(l)                        # test whether list is empty
# length(l)                         # get the number of elements in list
# collect(l)                        # return a vector consisting of list elements
# eltype(l)                         # return type of list
# first(l)                          # return value of first element of list
# last(l)                           # return value of last element of list
# l1 == l2                          # test lists for equality
# map(f, l)                         # return list with f applied to elements
# filter(f, l)                      # return list of elements where f(el) == true
# reverse(l)                        # return reversed list
# copy(l)                           # return a copy of list
# getindex(l, idx)   || l[idx]      # get value at index
# getindex(l, range) || l[range]    # get values within range a:b
# setindex!(l, data, idx)           # set value at index to data
# append!(l1, l2)                   # attach l2 at the end of l1
# append!(l, elts...)               # attach elements at end of list
# delete!(l, idx)                   # delete element at index
# delete!(l, range)                 # delete elements within range a:b
# push!(l, data)                    # add element to end of list
# pushfirst!(l, data)               # add element to beginning of list
# pop!(l)                           # remove element from end of list
# popfirst!(l)                      # remove element from beginning of list

mutable struct Data
    pos::Int64  # one-based position
    length::Int64
    id::Int32  # id (zero-based), -1 if free
end

mutable struct Disk
    metadata::Vector{Int32}
    data::Vector{Int32}
    free::MutableLinkedList{Data}
    occupied::Deque{Data}
end

const FREE_ID = -1

function parse_input(file_name::String)::Disk
    disk = Disk([Int32(i) - Int32('0') for i ∈ collect(readline(file_name))], Vector{Int32}(),
        MutableLinkedList{Data}(), Deque{Data}())
    id = 0
    pos = 1
    for (i, m) ∈ enumerate(disk.metadata)
        if i % 2 == 1
            # occupied
            @assert m != 0
            push!(disk.occupied, Data(pos, m, id))
            for j ∈ 1:m
                push!(disk.data, id)
                pos += 1
            end
            id += 1
        else
            # free
            push!(disk.free, Data(pos, m, FREE_ID))
            for j ∈ 1:m
                push!(disk.data, FREE_ID)
                pos += 1
            end
        end
    end
    return disk
end

function f(i, v)
    if v == FREE_ID
        return 0
    end
    return (i - 1) * v
end

function part2(disk::Disk)
    while length(disk.occupied) > 0
        occupied_ = pop!(disk.occupied)
        for (i, free_) ∈ enumerate(disk.free)
            if free_.pos > occupied_.pos
                break
            end
            if free_.length < occupied_.length
                continue
            elseif free_.length == occupied_.length
                for j ∈ 0:(occupied_.length-1)
                    disk.data[free_.pos + j] = occupied_.id
                    disk.data[occupied_.pos + j] = FREE_ID
                end
                delete!(disk.free, i)
                break
            else
                for j ∈ 0:(occupied_.length-1)
                    disk.data[free_.pos + j] = occupied_.id
                    disk.data[occupied_.pos + j] = FREE_ID
                end
                free_.pos += occupied_.length
                free_.length -= occupied_.length
                break
            end

        end
    end
    temp = [f(i, v) for (i, v) ∈ enumerate(disk.data)]
    result = sum(temp)

    return result
end

function main()
    disk = parse_input("input.txt")
    println("Question 2: What is the resulting filesystem checksum?")
    println("Answer: $(part2(disk))")
end

@time main()

# Question 2: What is the resulting filesystem checksum?
# Answer: 6398096697992
#  0.032898 seconds (40.94 k allocations: 3.228 MiB, 34.54% compilation time)
