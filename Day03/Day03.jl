""" Advent of Code 2024
    Day 3: Mull It Over
    Author: Chi-Kit Pao
    julia --optimize=3 Day03.jl
"""

function part1(lines)
    result = 0
    for line ∈ lines
        for m ∈ eachmatch(r"mul\((?<arg1>\d+)\,(?<arg2>\d+)\)", line)
            result += parse(Int64, m[:arg1]) * parse(Int64, m[:arg2])
        end
    end
    return result
end

function part2(lines)
    result = 0
    enabled = true
    for line ∈ lines
        for m ∈ eachmatch(r"mul\((?<arg1>\d+)\,(?<arg2>\d+)\)|do\(\)|don't\(\)", line)
            s = m.match
            if s == "do()"
                enabled = true
            elseif s == "don't()"
                enabled = false
            else
                # mul(<arg1>,<arg2>)
                if enabled
                    result += parse(Int64, m[:arg1]) * parse(Int64, m[:arg2])
                end
            end
        end
    end
    return result
end

function main()
    lines = readlines("input.txt")
   
    println("Question 1: What do you get if you add up all of the results of the multiplications?")
    println("Answer: $(part1(lines))")
    println("Question 2: What do you get if you add up all of the results of just the enabled multiplications?")
    println("Answer: $(part2(lines))")
end

@time main()

# Question 1: What do you get if you add up all of the results of the multiplications?
# Answer: 184122457
# Question 2: What do you get if you add up all of the results of just the enabled multiplications?
# Answer: 107862689
#  0.009210 seconds (15.91 k allocations: 749.312 KiB, 61.43% compilation time)
