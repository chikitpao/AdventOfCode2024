""" Advent of Code 2024
    Day 25: Code Chronicle
    Author: Chi-Kit Pao
    julia --optimize=3 Day25.jl
"""

struct KeyLock
    heights::Vector{Int} # height is by one more as in the examples
end

function parse_input(file_name::String)::Tuple{Vector{KeyLock}, Vector{KeyLock}}
    locks = Vector{KeyLock}()
    keys = Vector{KeyLock}()
    lines = readlines(file_name)
    current_line = 1
    while current_line <= length(lines)
        heights = zeros(Int, 5)
        is_lock = true
        for (j, line) ∈ enumerate(lines[current_line:current_line+6])
            if j == 1 && line[1] == '.'
                is_lock = false
            end
            for (k, c) ∈ enumerate(line)
                @assert c ∈ ('.', '#')
                if c == '#'
                    heights[k] += 1
                end
            end
            current_line += 1
        end
        if is_lock
            push!(locks, KeyLock(heights))
        else
            push!(keys, KeyLock(heights))
        end
        current_line += 1
    end
    return (locks, keys)
end

function part1(keylocks::Tuple{Vector{KeyLock}, Vector{KeyLock}})::Int64
    locks = keylocks[1]
    keys = keylocks[2]
    result = 0
    for lock ∈ locks
        for key ∈ keys
            height_checks = [a + b <= 7 for (a, b) in zip(lock.heights, key.heights)]
            if all(height_checks)
                result += 1
            end
        end
    end
    return result
end

function main()
    println("Question: How many unique lock/key pairs fit together without overlapping in any column?")
    println("Answer: $(part1(parse_input("input.txt")))")
end

@time main()

# Question: How many unique lock/key pairs fit together without overlapping in any column?
# Answer: 3356
#  0.010231 seconds (139.75 k allocations: 4.420 MiB, 60.37% compilation time)
