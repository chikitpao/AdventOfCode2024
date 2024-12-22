""" Advent of Code 2024
    Day 17: Chronospatial Computer
    Author: Chi-Kit Pao
    julia --optimize=3 Day17.jl
"""

mutable struct Computer
    regA::Int64
    regB::Int64
    regC::Int64
    program::Vector{Int64}
    ip::Int64
    output::Vector{Int64}
end


function parse_input(file_name::String)::Computer
    lines = readlines(file_name)
    registerA = parse(Int64, split(lines[1], ": ")[2])
    registerB = parse(Int64, split(lines[2], ": ")[2])
    registerC = parse(Int64, split(lines[3], ": ")[2])
    program = map(s -> parse(Int64, s), split(split(lines[5], ": ")[2], ","))

    return Computer(registerA, registerB, registerC, program, 0, [])
end

function combo(computer::Computer, operand::Int64)
    # println("operand=$operand")
    @assert operand >=0 && operand <= 6
    if operand == 4
        return computer.regA
    elseif operand == 5
        return computer.regB
    elseif operand == 6
        return computer.regC
    else
        return operand
    end
end

function run(computer::Computer)
    while true
        try
            # Turn zero-based instruction pointer to one-based for Julia vector.
            ip = computer.ip + 1
            # println("ip=$ip computer.program[ip]=$(computer.program[ip])")
            instruction = computer.program[ip]
            if instruction == 0
                # adv
                computer.regA = computer.regA ÷ 2^(combo(computer, computer.program[ip + 1]))
            elseif instruction == 1
                # bxl
                computer.regB = computer.regB ⊻ computer.program[ip + 1]
            elseif instruction == 2
                # bst
                computer.regB = combo(computer, computer.program[ip + 1]) % 8
            elseif instruction == 3
                # jnz
                if computer.regA != 0
                    computer.ip = computer.program[ip + 1]
                    continue
                end
            elseif instruction == 4
                # bxc
                computer.regB = computer.regB ⊻ computer.regC
            elseif instruction == 5
                # out
                push!(computer.output, combo(computer, computer.program[ip + 1]) % 8)
            elseif instruction == 6
                # bdv
                computer.regB = computer.regA ÷ 2^(combo(computer, computer.program[ip + 1]))
            elseif instruction == 7
                # cdv
                computer.regC = computer.regA ÷ 2^(combo(computer, computer.program[ip + 1]))
            end
            computer.ip += 2
        catch BoundsError
            # println("Program finished!")
            break
        end
    end
end

function format_output(output::Vector{Int64})::String
    result = ""
    for (i, n) ∈ enumerate(output)
        if i > 1
            result = result * ","
        end
        result = result * string(n)
    end
    return result
end

function main()
    computer = parse_input("input.txt")
    
    println("Question 1: What do you get if you use commas to join the values it output into a single string?")
    run(computer)
    println("Answer: $(format_output(computer.output))")
end

@time main()

# Question 1: What do you get if you use commas to join the values it output into a single string?
# Answer: 7,4,2,5,1,4,6,0,4
#  0.103063 seconds (5.81 k allocations: 325.773 KiB, 5.30% compilation time)
