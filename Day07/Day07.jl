""" Advent of Code 2024
    Day 7: Bridge Repair
    Author: Chi-Kit Pao
    julia --optimize=3 Day07.jl
"""

struct Equation
    test_value::Int64
    operands::Vector{Int64}
    operand_lengths::Vector{Int64}
end

function check_equation(e::Equation, current_index::Int64, accumulated_value::Int64, part::Int64)::Bool
    len = length(e.operands)
    new_accumulated_values = []
    if current_index == 1
        push!(new_accumulated_values, e.operands[1])
    else
        # Add current value
        push!(new_accumulated_values, accumulated_value + e.operands[current_index])
        # Multiply with current value
        push!(new_accumulated_values, accumulated_value * e.operands[current_index])
        if part == 2
            # Concatenate with current value
            
            ## Either calculate exponent of 10 directly,
            #  exp = floor(Int64, log10(e.operands[current_index])) + 1
            #  or use stored value.
            exp = e.operand_lengths[current_index]
            shift = 10^exp
            push!(new_accumulated_values, accumulated_value * shift + e.operands[current_index])
        end
    end

    if current_index == len
        return e.test_value ∈ new_accumulated_values
    else
        # Operations will only increase the accumulated value, so if it's already 
        # larger than the test value, we will never reach it.
        if all(x > e.test_value for x in new_accumulated_values)
            return false
        end

        # Returns true if either addition or mulitplication leads to correct test value.
        retval = check_equation(e, current_index + 1, new_accumulated_values[1], part)
        if !retval && length(new_accumulated_values) >= 2
            retval = check_equation(e, current_index + 1, new_accumulated_values[2], part)
        end
        if !retval && length(new_accumulated_values) == 3
            retval = check_equation(e, current_index + 1, new_accumulated_values[3], part)
        end
        return retval
    end
end

function parse_input(file_name::String)::Vector{Equation}
    equations = Vector{Equation}()
    for s ∈ eachline(file_name)
        s1, s2 = split(s, ": ")
        splitted_values = split(s2)
        operands = [parse(Int64, x) for x in splitted_values]
        operand_lengths = [length(x) for x in splitted_values]
        push!(equations, Equation(parse(Int64, s1), operands, operand_lengths))
    end
    return equations
end

function main()
    equations = parse_input("input.txt")
    println("Question 1: What is their total calibration result?")
    answer1 = 0
    for e ∈ equations
        if check_equation(e, 1, 0, 1)
            answer1 += e.test_value
        end
    end
    println("Answer: $answer1")
    println("Question 2: What is their total calibration result?")
    answer2 = 0
    for e ∈ equations
        if check_equation(e, 1, 0, 2)
            answer2 += e.test_value
        end
    end
    println("Answer: $answer2")
end

@time main()

# Question 1: What is their total calibration result?
# Answer: 2664460013123
# Question 2: What is their total calibration result?
# Answer: 426214131924213
#  0.601873 seconds (26.68 M allocations: 771.548 MiB, 8.37% gc time, 1.62% compilation time)
