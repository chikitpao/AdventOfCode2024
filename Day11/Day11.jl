""" Advent of Code 2024
    Day 11: Plutonian Pebbles
    Author: Chi-Kit Pao
    julia --optimize=3 Day11.jl
"""


using DataStructures

mutable struct Stone
    value::Int64
end

function parse_input(file_name::String)::Vector{Stone}
    stones = Vector{Stone}()
    for s ∈ split(readline(file_name))
        push!(stones, Stone(parse(Int64, s)))
    end
    return stones
end

function answer(stones::Vector{Stone}, rounds::Int64)::Int64
    dict = Dict{Int64,Vector{Int64}}()
    ddict = DefaultDict{Int64, Int64}(0)
    
    for stone ∈ stones
        ddict[stone.value] += 1
    end
    
    new_ddict = DefaultDict{Int64, Int64}(0)
    for i ∈ 1:rounds
        for (k, v) ∈ pairs(ddict)
            if k == 0
                new_ddict[1] += v
            else
                mutation = []
                if haskey(dict, k)
                    mutation = dict[k]
                else
                    s = string(k)
                    strlen = length(s)
                    if strlen % 2 == 0
                        new_strlen = strlen ÷ 2
                        mutation = [parse(Int64, s[1:new_strlen]), parse(Int64, s[(new_strlen+1):strlen])]
                    else
                        mutation = [k * 2024]
                    end
                    dict[k] = mutation
                end
                for m ∈ mutation
                    new_ddict[m] += v
                end
            end
        end
        ddict = new_ddict
        new_ddict = DefaultDict{Int64, Int64}(0)
    end
    
    return sum(collect(values(ddict)))
end

function main()
    stones = parse_input("input.txt")
    println("Question 1: How many stones will you have after blinking 25 times?")
    println("Answer: $(answer(stones, 25))")
    println("Question 2: How many stones would you have after blinking a total of 75 times?")
    println("Answer: $(answer(stones, 75))")
end

@time main()

# Question 1: How many stones will you have after blinking 25 times?
# Answer: 186175
# Question 2: How many stones would you have after blinking a total of 75 times?
# Answer: 220566831337810
#  0.023043 seconds (36.63 k allocations: 14.445 MiB, 23.87% compilation time)
