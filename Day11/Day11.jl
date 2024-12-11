""" Advent of Code 2024
    Day 11: Plutonian Pebbles
    Author: Chi-Kit Pao
    julia --optimize=3 Day11.jl
"""


mutable struct Stone
    text::String
    value::Int64
end

function parse_input(file_name::String)::Vector{Stone}
    stones = Vector{Stone}()
    for s ∈ split(readline(file_name))
        push!(stones, Stone(s, parse(Int64, s)))
    end
    return stones
end

function mutate!(stones::Vector{Stone})
    i = 1
    len = length(stones)
    while i <= len
        #println("mutate! i $i len $len")
        stone = stones[i]
        if stone.value == 0
            stone.value = 1
            stone.text = string(stone.value)
        elseif length(stone.text) % 2 == 0
            strlen = length(stone.text)
            new_strlen = strlen ÷ 2
            new_stone = Stone("", parse(Int64, stone.text[(new_strlen+1):strlen]))
            new_stone.text = string(new_stone.value)
            stone.value = parse(Int64, stone.text[1:new_strlen])
            stone.text = string(stone.value)
            insert!(stones, i + 1, new_stone)
            len += 1
            i += 1
        else
            stone.value *= 2024
            stone.text = string(stone.value)
        end
        i += 1
    end
end

function part1(stones::Vector{Stone})::Int64
    for i ∈ 1:25
        mutate!(stones)
    end
    return length(stones)
end

function main()
    println("Question 1: How many stones will you have after blinking 25 times?")
    println("Answer: $(part1(parse_input("input.txt")))")
end

@time main()

# Question 1: How many stones will you have after blinking 25 times?
# Answer: 186175
#  1.598008 seconds (1.65 M allocations: 47.751 MiB, 2.91% gc time, 0.34% compilation time)
