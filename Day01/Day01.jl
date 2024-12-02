""" Advent of Code 2024
    Day 1: Historian Hysteria
    Author: Chi-Kit Pao
    julia --optimize=3 Day01.jl
"""

function get_answer1(lists)
    list1 = sort(lists[1])
    list2 = sort(lists[2])
    result = 0
    for (i, v) ∈ enumerate(list1)
        result += abs(v - list2[i]) 
    end
    return result
end

function get_answer2(lists)
    d = Dict()
    for v ∈ lists[2]
        if haskey(d, v)
            d[v] += 1
        else
            d[v] = 1
        end
    end
    result = 0
    for v in lists[1]
        if haskey(d, v)
            result += v * d[v]
        end
    end
    return result
end

function main()
    # lines = readlines("input.txt")
    lists = [[], []]
    for line ∈ eachline(("input.txt"))
        auto = split(line)
        push!(lists[1], parse(Int64, auto[1]))
        push!(lists[2], parse(Int64, auto[2]))
    end

    get_answer1(lists)
   
    println("Question 1: What is the total distance between your lists?")
    println("Answer: $(get_answer1(lists))")
    println("Question 2: What is their similarity score?")
    println("Answer: $(get_answer2(lists))")
    
end

@time main()

# Question 1: What is the total distance between your lists?
# Answer: 2344935
# Question 2: What is their similarity score?
# Answer: 27647262
#  0.126421 seconds (71.08 k allocations: 3.341 MiB, 96.59% compilation time)
