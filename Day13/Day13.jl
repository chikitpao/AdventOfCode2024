""" Advent of Code 2024
    Day 13: Claw Contraption
    Author: Chi-Kit Pao
    julia --optimize=3 Day13.jl
"""


mutable struct Machine
    a::Tuple{Int64, Int64}
    b::Tuple{Int64, Int64}
    prize::Tuple{Int64, Int64}
end

function parse_input(file_name::String)::Vector{Machine}
    machines = Vector{Machine}()
    v = []
    for (i, line) ∈ enumerate(eachline(file_name))
        modulo = i % 4
        # Example input:
        # Button A: X+94, Y+34
        # Button B: X+22, Y+67
        # Prize: X=8400, Y=5400
        if modulo == 1
            m = match(r"Button A: X\+(?<x>\d+)\, Y\+(?<y>\d+)", line)
            append!(v, [parse(Int64, m[:x]), parse(Int64, m[:y])])
        elseif modulo == 2
            m = match(r"Button B: X\+(?<x>\d+)\, Y\+(?<y>\d+)", line)
            append!(v, [parse(Int64, m[:x]), parse(Int64, m[:y])])
        elseif modulo == 3
            m = match(r"Prize: X=(?<x>\d+)\, Y=(?<y>\d+)", line)
            append!(v, [parse(Int64, m[:x]), parse(Int64, m[:y])])
            push!(machines, Machine((v[1], v[2]), (v[3], v[4]), (v[5], v[6])))
            v = []
        end
        
    end
    return machines
end

function calculate_tokens1(machine::Machine)::Int64
    temp_results = Vector{Tuple{Int64, Int64, Int64}}()
    a = 0
    ax = 0
    while ax <= machine.prize[1]
        bx = machine.prize[1] - ax
        (b , m) = divrem(bx, machine.b[1])
        if m == 0 && a * machine.a[2] + b * machine.b[2] == machine.prize[2]
            push!(temp_results, (3 * a + b, a, b))
        end
        ax += machine.a[1]
        a += 1
    end
    if length(temp_results) == 0
        return 0
    end
    sort!(temp_results)
    last_temp_result = last(temp_results)
    @assert last_temp_result[2] <= 100 && + last_temp_result[3] <= 100
    return last_temp_result[1]
end

const UPDATE = 10000000000000
function update_machines(machines::Vector{Machine})
    for machine ∈ machines
        machine.prize = (machine.prize[1] + UPDATE, machine.prize[2] + UPDATE)
    end
end

function calculate_tokens2(machine::Machine)::Int64
    # We can solve the problem with system of linear equations.
    #  a * ax + b * bx = px
    #  a * ay + b * by = py

    M = [machine.a[1] machine.b[1]; machine.a[2] machine.b[2]]
    p = [machine.prize[1]; machine.prize[2]]
    #println("M ", M)
    #println("p ", p)
    
    # Not working well since floating point results are returned.
    # x = M \ p

    M2 = copy(M)
    p2 = copy(p)
    # row2 = row2 * ax - row1 * ay
    M2[2, 1] = 0
    M2[2, 2] = M[2, 2] * M[1, 1] - M[1, 2] * M[2, 1]
    p2[2] = p[2] * M[1, 1] - p[1] * M[2, 1]
    #println("M2 ", M2)
    #println("p2 ", p2)
    (b, m) = divrem(p2[2], M2[2, 2])
    if m == 0
        (a, m) = divrem(p2[1] - b * M2[1, 2], M2[1, 1])
        if m == 0
            # println("$a, $b")
            # println("$(M \ p)")
            # println("")
            @assert a * M[1, 1] + b * M[1, 2] == p[1]
            @assert a * M[2, 1] + b * M[2, 2] == p[2]
            return 3 * a + b
        end
    end
    return 0
end

function answer(machines::Vector{Machine}, part::Int64)::Int64
    result = 0
    f = (part == 1) ? calculate_tokens1 : calculate_tokens2
    for machine ∈ machines
        result += f(machine)
    end
    return result
end

function main()
    machines = parse_input("input.txt")
    println("Question 1: What is the fewest tokens you would have to spend to win all possible prizes?")
    println("Answer: $(answer(machines, 1))")
    println("Question 2: What is the fewest tokens you would have to spend to win all possible prizes?")
    update_machines(machines)
    println("Answer: $(answer(machines, 2))")

end

@time main()

# Question 1: What is the fewest tokens you would have to spend to win all possible prizes?
# Answer: 26599
# Question 2: What is the fewest tokens you would have to spend to win all possible prizes?
# Answer: 106228669504887
#  0.015348 seconds (20.59 k allocations: 959.078 KiB, 69.08% compilation time)
