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

@memoize function is_valid(design::String)::Bool
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

@memoize function check_variations(design::String)::Int64
    result = 0
    for p ∈ patterns
        if !startswith(design, p.pattern)
            continue
        end
        if length(design) == p.length_
            result += 1
        else
            result += check_variations(design[(p.length_+1):end])
        end
    end
    return result
end

function part2(designs::Vector{String})::Int64
    results = [check_variations(d) for d ∈ designs]
    return sum(results)
end

function main()
    designs = parse_input("input.txt")
    
    println("Question 1: How many designs are possible?")
    println("Answer: $(part1(designs))")

    println("Question 2: What do you get if you add up the number of different ways you could make each design?")
    println("Answer: $(part2(designs))")
end

@time main()

# Question 1: How many designs are possible?
# Answer: 324
# Question 2: What do you get if you add up the number of different ways you could make each design?
# Answer: 575227823167869
#  2.191498 seconds (37.11 M allocations: 1.108 GiB, 6.32% gc time, 4.29% compilation time)

