""" Advent of Code 2024
    Day 19: Linen Layout
    Author: Chi-Kit Pao
    julia --optimize=3 Day19.jl
"""

using Memoization

struct Pattern
    pattern::String
    length_::Int64
end

patterns = Vector{Pattern}()

function parse_input(file_name::String)::Vector{String}
    lines = readlines(file_name)
    global patterns = [Pattern(s, length(s)) for s ∈ sort(split(lines[1], ", "))]
    return lines[3:length(lines)]
end

@memoize function is_valid(design::String)
    for p ∈ patterns
        if !startswith(design, p.pattern)
            continue
        end
        if length(design) == p.length_
            return true
        else
            temp_result = is_valid(design[(p.length_+1):end])
            if temp_result
                return true
            end
        end
    end
    return false
end

function part1(designs::Vector{String})::Int64
    results = [is_valid(d) for d ∈ designs]
    return count(results)
end

function main()
    println("Question 1: How many designs are possible?")
    designs = parse_input("input.txt")
    answer1 = part1(designs)
    println("Answer: $answer1")
end

@time main()

# Question 1: How many designs are possible?
# Answer: 324
#  0.717287 seconds (11.82 M allocations: 362.343 MiB, 6.14% gc time, 8.18% compilation time)
