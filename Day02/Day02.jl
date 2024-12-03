""" Advent of Code 2024
    Day 2: Red-Nosed Reports
    Author: Chi-Kit Pao
    julia --optimize=3 Day02.jl
"""

function is_safe1(row)
    increasing = false
    decreasing = false
    for i ∈ 2:length(row)
        difference = row[i] - row[i-1]
        abs_difference = abs(difference)
        if abs_difference == 0 || abs_difference > 3
            return false
        end
        if difference > 0
            if decreasing
                return false
            end
            increasing = true
        else  # difference < 0
            if increasing
                return false
            end
            decreasing = true
        end
    end
    @assert increasing != decreasing  # either increasing or decreasing
    return true
end

function is_safe2(row)
    if is_safe1(row)
        return true
    end
    for i ∈ 1:length(row)
        new_row = deleteat!(copy(row), i)
        if is_safe1(new_row)
            return true
        end
    end
    return false
end

function main()
    rows = []
    for line ∈ eachline(("input.txt"))
        row = []
        for s ∈ eachsplit(line)
            push!(row, parse(Int64, s))
        end
        push!(rows, row)
    end
   
    println("Question 1: How many reports are safe?")
    answer1 = count(x -> is_safe1(x), rows)
    println("Answer: $answer1")
    println("Question 2: How many reports are now safe?")
    answer2 = count(x -> is_safe2(x), rows)
    println("Answer: $answer2")
end

@time main()

# Question 1: How many reports are safe?
# Answer: 432
# Question 2: How many reports are now safe?
# Answer: 488
#  0.077202 seconds (45.99 k allocations: 2.406 MiB, 95.27% compilation time)
