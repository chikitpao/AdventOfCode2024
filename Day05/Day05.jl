""" Advent of Code 2024
    Day 5: Print Queue
    Author: Chi-Kit Pao
    julia --optimize=3 Day05.jl
"""

mutable struct PrintQueue
    rules::Set{Tuple{Int64, Int64}}
    updates::Vector{Vector{Int64}}
end

function check_update(rules::Set{Tuple{Int64, Int64}}, update::Vector{Int64})::Bool
    for i ∈ 1:length(update)
        for j ∈ (i+1):length(update)
            # Rule violated?
            if (update[j], update[i]) ∈ rules
                return false
            end
        end
    end
    return true
end

function part1(pq::PrintQueue)
    result = 0
    for update ∈ pq.updates
        if check_update(pq.rules, update)
            @assert length(update) % 2 == 1
            result += update[(length(update) + 1) ÷ 2]
        end
    end
    return result
end

function part2(pq::PrintQueue)
    result = 0
    for update ∈ pq.updates
        if !check_update(pq.rules, update)
            @assert length(update) % 2 == 1
            ordered = zeros(Int64, length(update))
            for i ∈ 1:length(update)
                pivot = update[i]
                rule_count = 0
                for j ∈ 1:length(update)
                    if i == j
                        continue
                    end
                    # Conform to rules?
                    if (update[j], pivot) ∈ pq.rules
                        rule_count += 1
                    else
                        # Conform to rules when swapped positions?
                        @assert (pivot, update[j]) ∈ pq.rules
                    end
                end
                ordered[rule_count + 1] = pivot
            end
            @assert isnothing(findfirst(isequal(0), ordered))
            result += ordered[(length(update) + 1) ÷ 2]
        end
    end
    return result
end

function parse_input(filename::String)::PrintQueue
    pq = PrintQueue(Set(), Vector())
    for line in eachline("input.txt")
        if '|' ∈ line
            a, b = (parse(Int64, d) for d in split(line, "|"))
            push!(pq.rules, (a, b))
        elseif ',' ∈ line
            push!(pq.updates, [parse(Int64, d) for d in split(line, ",")])
        end
    end
    return pq
end

function main()
    pq = parse_input("input.txt")
    println("Question 1: What do you get if you add up the middle page number from those correctly-ordered updates?")
    println("Answer: $(part1(pq))")
    println("Question 2: What do you get if you add up the middle page numbers after correctly ordering just those updates?")
    println("Answer: $(part2(pq))")
end

@time main()

# Question 1: What do you get if you add up the middle page number from those correctly-ordered updates?
# Answer: 5747
# Question 2: What do you get if you add up the middle page numbers after correctly ordering just those updates?
# Answer: 5502
#  0.009744 seconds (10.74 k allocations: 1.014 MiB, 57.58% compilation time)
