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

function reset(computer::Computer)
    computer.regA = 0
    computer.regB = 0
    computer.regC = 0
    computer.ip = 0
    computer.output = Vector{Int64}()
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

function try_lsb(output::Int64, next_regA::Int64)
    # This is a Julia function which represent the program of the current 
    # puzzle. See Day17.txt for the "Assembly code". I've simplify the program
    # a little bit (e.g. merged successive xor operations).
    # Since AoC users may have diffent program input. So this may only works 
    # for my program and you have to write function.
    result = Vector{Int64}()
    for a ∈ 0:7
        test_regA = next_regA * 8 + a
        regC = test_regA ÷ 2^((test_regA % 8) ⊻ 1)
        regB = (test_regA % 8) ⊻ 4
        test_output = (regB ⊻ regC) % 8
        if output == test_output
            push!(result, a)
        end
    end
    return result
end

function part2(computer::Computer)
    reversed_program = reverse(computer.program)
    # Next register A value
    current_next_regA = [0]
    new_next_regA = []
    for output ∈ reversed_program
        for test_next_regA ∈ current_next_regA
            possibilities = try_lsb(output, test_next_regA)
            for possibility ∈ possibilities
                push!(new_next_regA, test_next_regA * 8 + possibility)
            end
        end
        current_next_regA = new_next_regA
        new_next_regA = []
    end
    # Output:
    # Any[164278764924605, 164278764924861, 164281717714621, 164281717714877, 
    # 164281784823485, 164281784823741, 164281851932349, 164281851932605, 
    # 164281919041213, 164281919041469, 164281986150077, 164281986150333, 
    # 165523097480893, 165523097481149, 165523164589757, 165523164590013]
    # println(current_next_regA)
    return minimum(current_next_regA)
end

function main()
    computer = parse_input("input.txt")
    original_program = split(readlines("input.txt")[5], ": ")[2]
    
    println("Question 1: What do you get if you use commas to join the values it output into a single string?")
    run(computer)
    println("Answer: $(format_output(computer.output))")

    println("Question 2: What is the lowest positive initial value for register A that causes the program to output a copy of itself?")
    answer2 = part2(computer)
    println("Answer: $answer2")

    # Run test
    reset(computer)
    computer.regA = answer2
    run(computer)
    @assert computer.output == computer.program
end

@time main()

# Question 1: What do you get if you use commas to join the values it output into a single string?
# Answer: 7,4,2,5,1,4,6,0,4
# Question 2: What is the lowest positive initial value for register A that causes the program to output a copy of itself?
# Answer: 164278764924605
#  0.114675 seconds (6.82 k allocations: 365.125 KiB, 14.44% compilation time)
