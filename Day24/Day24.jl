""" Advent of Code 2024
    Day 23: LAN Party
    Author: Chi-Kit Pao
    julia --optimize=3 Day23.jl
"""


using Printf

mutable struct Gate
    input1_name::String
    operation::String
    input2_name::String
    output_name::String
    input1::Union{Nothing,Int64}
    input2::Union{Nothing,Int64}
    output::Union{Nothing,Int64}
end
function formula(gate::Gate)::String
    return "$(gate.input1_name) $(gate.operation) $(gate.input2_name) -> $(gate.output_name)"
end
function process(gate)::Bool
    if isnothing(gate.output) && !isnothing(gate.input1) && !isnothing(gate.input2)
        if gate.operation == "AND"
            gate.output = gate.input1 & gate.input2
        elseif gate.operation == "OR"
            gate.output = gate.input1 | gate.input2
        else
            @assert gate.operation == "XOR"
            gate.output = gate.input1 ⊻ gate.input2
        end
        return true
    end
    return false
end

mutable struct Circuit
    gates::Vector{Gate}
    z_gates::Vector{Gate}
end
function fill_input(circuit::Circuit, processing::Vector{Gate})
    for gate2 ∈ processing
        for gate ∈ circuit.gates
            if gate.input1_name == gate2.output_name
                gate.input1 = gate2.output
            end
            if gate.input2_name == gate2.output_name
                gate.input2 = gate2.output
            end
        end
    end
end
function swap_output(circuit::Circuit, out1::String, out2::String)
    g1 = circuit.gates[findfirst(g -> g.output_name == out1, circuit.gates)]
    g2 = circuit.gates[findfirst(g -> g.output_name == out2, circuit.gates)]
    (g2.output_name, g1.output_name) = (g1.output_name, g2.output_name)
end

function parse_input(file_name::String)::Circuit
    circuit = Circuit(Vector{Gate}(), Vector{Gate}())
    lines = readlines(file_name)
    empty_line_index = findfirst(x -> x == "", lines)
    @assert !isnothing(empty_line_index)

    for line ∈ lines[empty_line_index+1:end]
        # Example input:
        # x00 AND y00 -> z00
        m = match(r"(?<input1>\w+) (?<op>(AND|OR|XOR)) (?<input2>\w+) -> (?<output>\w+)", line)
        gate = Gate(m[:input1], m[:op], m[:input2], m[:output], nothing, nothing, nothing)
        push!(circuit.gates, gate)
        m2 = match(r"z(\d+)", m[:output])
        if !isnothing(m2)
            push!(circuit.z_gates, gate)
        end
    end
    sort!(circuit.z_gates, by=(g -> g.output_name))
    for line ∈ lines[1:empty_line_index-1]
        # Example input:
        # x00: 1
        m = match(r"(?<input>(x|y)\d+): (?<value>\d)", line)
        input = m[:input]
        value = parse(Int64, m[:value])
        for gate_index ∈ findall(g -> g.input1_name == input || g.input2_name == input, circuit.gates)
            gate = circuit.gates[gate_index]
            if gate.input1_name == input
                gate.input1 = value
            end
            if gate.input2_name == input
                gate.input2 = value
            end
            process(gate)
        end
    end

    part1(circuit)

    return circuit
end

function part1(circuit::Circuit)::Int64
    processing = Vector{Gate}()
    for gate ∈ circuit.gates
        if !isnothing(gate.output)
            push!(processing, gate)
        end
    end
    
    new_processing = Vector{Gate}()
    while !isempty(processing)
        fill_input(circuit, processing)
        for gate ∈ circuit.gates
            if process(gate)
                push!(new_processing, gate)
            end
        end
        if isempty(new_processing)
            break
        else
            processing = new_processing
            new_processing = Vector{Gate}()
        end
    end
    
    result = 0
    bitmask = 1
    for i ∈ 0:length(circuit.z_gates)-1
        if circuit.z_gates[i+1].output != 0
            result |= bitmask
        end
        bitmask <<= 1
    end
    return result
end

function part2_count_input_output(circuit::Circuit)::Tuple{Set{String}, Set{String}, Set{String}}
    x_wires = Set{String}()
    y_wires = Set{String}()
    z_wires = Set{String}()
    for gate ∈ circuit.gates
        input_names = [gate.input1_name, gate.input2_name]
        for input_name ∈ input_names
            if input_name[1] == 'x'
                push!(x_wires, input_name)
            elseif input_name[1] == 'y'
                push!(y_wires, input_name)
            end
        end
    end
    for gate ∈ circuit.z_gates
        push!(z_wires, gate.output_name)
    end
    
    x_count = length(x_wires)
    y_count = length(y_wires)
    z_count = length(z_wires)
    # Output: 45 45 46 222
    # println("$x_count $y_count $z_count $(length(circuit.gates))")
    @assert x_count == y_count
    @assert z_count == x_count + 1
    return (x_wires, y_wires, z_wires)
end

function part2_fill_input_gates(circuit::Circuit, x_count::Int64)::Tuple{Vector{Union{Nothing, Gate}},Vector{Union{Nothing, Gate}}}
    in_xor_gates = Union{Nothing, Gate}[nothing for _ ∈ 0:x_count-1]
    in_and_gates = Union{Nothing, Gate}[nothing for _ ∈ 0:x_count-1]
    xy = ('x', 'y')
    for gate ∈ circuit.gates
        if gate.input1_name[1] ∈ xy
            @assert gate.input2_name[1] ∈ xy && gate.input1_name[1] != gate.input2_name[1]
            @assert gate.input1_name[2:end] == gate.input2_name[2:end]
            number = parse(Int64, gate.input1_name[2:end])
            index = number + 1
            @assert gate.operation == "AND" || gate.operation == "XOR"
            if gate.operation == "AND"
                in_and_gates[index] = gate
            else
                in_xor_gates[index] = gate
            end
            if gate.output_name[1] == 'z'
                if gate.operation != "XOR" || number != 0
                    @printf("Found inproper z output: %s!\n", formula(gate))
                end
            end
        end
    end
    return (in_xor_gates, in_and_gates)
end

function part2_fill_output_gates(circuit::Circuit, x_count::Int64)::Vector{Union{Nothing, Gate}}
    out_gates = Union{Nothing, Gate}[nothing for _ ∈ 0:x_count-1]
    for gate ∈ circuit.gates
        if gate.output_name[1] == 'z'
            number = parse(Int64, gate.output_name[2:end])
            if number == 45
                if gate.operation != "OR"
                    @printf("Found inproper operation for gate with z output: %s!\n", formula(gate))
                end
                continue
            end
            if number != 0
                if gate.operation != "XOR"
                    @printf("Found inproper operation for gate with z output: %s!\n", formula(gate))
                end
            end
            index = number + 1
            out_gates[index] = gate
        end
    end
    return out_gates
end

function part2_fill_carry_and_gates(circuit::Circuit, x_count::Int64, in_xor_gates::Vector{Union{Nothing, Gate}}, 
    in_and_gates::Vector{Union{Nothing, Gate}})::Tuple{Vector{Union{Nothing, Gate}},Vector{Union{Nothing, Gate}}}
    carry_and_gates = Union{Nothing, Gate}[nothing for _ ∈ 0:x_count-1]  # III, carry in
    missing_carry_and_gates = []
    
    for gate ∈ circuit.gates
        if gate.operation == "AND" && gate ∉ in_and_gates
            search = [i for (i, v) ∈ enumerate(in_xor_gates) if v.output_name ∈ (gate.input1_name, gate.input2_name)]
            if length(search) == 0
                push!(missing_carry_and_gates, gate)
            elseif length(search) > 1
                println("Found too many inputs for Carry AND ", search, " ", formula(gate) )
                carry_and_gates[search[1][1]] = gate
            else
                carry_and_gates[search[1][1]] = gate
            end
        end
    end

    for i ∈ 2:x_count
        if isnothing(carry_and_gates[i])
            println("carry_and_gates[$i] is nothing!")
            continue
        end
    end
    return (carry_and_gates, missing_carry_and_gates)
end

function part2_fill_carry_or_gates(circuit::Circuit, x_count::Int64, in_xor_gates::Vector{Union{Nothing, Gate}},
    in_and_gates::Vector{Union{Nothing, Gate}}, out_gate_msb::Gate)::Tuple{Vector{Union{Nothing, Gate}},Vector{Union{Nothing, Gate}}}
    carry_or_gates = Union{Nothing, Gate}[nothing for _ ∈ 0:x_count-1]  # IV, index 1 = carry out of bit 0
    carry_or_gates[x_count] = out_gate_msb
    missing_carry_or_gates = []
    for gate ∈ circuit.gates
        if gate.operation == "OR"
            search = [i for (i, v) ∈ enumerate(in_and_gates) if v.output_name ∈ (gate.input1_name, gate.input2_name)]
            if length(search) == 0
                push!(missing_carry_or_gates, gate)
            elseif length(search) > 1
                println("Found too many inputs for Carry OR ", search, " ", formula(gate) )
                carry_or_gates[search[1][1]] = gate
            else
                carry_or_gates[search[1][1]] = gate
            end
        end
    end
    
    for i ∈ 2:x_count
        if isnothing(carry_or_gates[i])
            println("carry_or_gates[$i] is nothing!")
            continue
        end
    end
    return (carry_or_gates, missing_carry_or_gates)
end

function print_xor_not_connected(gate::Gate, input::Int64, in_xor_gates::Vector{Union{Nothing, Gate}}, 
    carry_or_gates::Vector{Union{Nothing, Gate}})
    input_name = input == 1 ? gate.input1_name : gate.input2_name
    temp_result = [(i, formula(g)) for (i, g) ∈ enumerate(in_xor_gates) if !isnothing(g) && g.output_name == input_name]
    @printf("  gate.input%d_name in in_xor_gates output: %s\n", input, temp_result)
    temp_result = [(i, formula(g)) for (i, g) ∈ enumerate(carry_or_gates) if !isnothing(g) && g.output_name == input_name]
    @printf("  gate.input%d_name in carry_or_gates output: %s\n", input, temp_result)
end

function print_carry_and_not_connected(gate::Gate, input::Int64, in_xor_gates::Vector{Union{Nothing, Gate}}, 
    carry_or_gates::Vector{Union{Nothing, Gate}}, in_and_gates::Vector{Union{Nothing, Gate}})
    input_name = input == 1 ? gate.input1_name : gate.input2_name
    temp_result1 = [(i, formula(g)) for (i, g) ∈ enumerate(in_xor_gates) if !isnothing(g) && g.output_name == input_name]
        @printf("  gate.input%d_name in in_xor_gates output: %s\n", input, temp_result1)
    temp_result2 = [(i, formula(g)) for (i, g) ∈ enumerate(carry_or_gates) if !isnothing(g) && g.output_name == input_name]
    @printf("  gate.input%d_name in carry_or_gates output: %s\n", input, temp_result2)
    if isempty(temp_result1) && isempty(temp_result2)
        temp_result3 = [(i, formula(g)) for (i, g) ∈ enumerate(in_and_gates) if !isnothing(g) && g.output_name == input_name]
        if !isempty(temp_result3)
            @printf("  BUT gate.input%d_name in in_and_gates output: %s\n", input, temp_result3)
        end
    end
end

function print_carry_or_not_connected(gate::Gate, input::Int64, in_and_gates::Vector{Union{Nothing, Gate}}, 
    carry_and_gates::Vector{Union{Nothing, Gate}}, in_xor_gates::Vector{Union{Nothing, Gate}})
    input_name = input == 1 ? gate.input1_name : gate.input2_name
    temp_result1 = [(i, formula(g)) for (i, g) ∈ enumerate(in_and_gates) if !isnothing(g) && g.output_name == input_name]
    @printf("  gate.input%d_name in in_and_gates output: %s\n", input, temp_result1)
    temp_result2 = [(i, formula(g)) for (i, g) ∈ enumerate(carry_and_gates) if !isnothing(g) && g.output_name == input_name]
    @printf("  gate.input%d_name in carry_and_gates output: %s\n", input, temp_result2)
    if isempty(temp_result1) && isempty(temp_result2)
        temp_result3 = [(i, formula(g)) for (i, g) ∈ enumerate(in_xor_gates) if !isnothing(g) && g.output_name == input_name]
        if !isempty(temp_result3)
            @printf("  BUT gate.input%d_name in in_xor_gates output: %s\n", input, temp_result3)
        end
    end
end

function part2(circuit::Circuit)
    println("##### part 2")
    # 1. Check number of x, y, and z wires
    (x_wires, y_wires, z_wires) = part2_count_input_output(circuit)
    x_count = length(x_wires)

    # 2. Check connections regarding bit addition
    # x, y: Input
    # o: Output
    # c: Carry
    # a, b, d: Only temporary place holders
    # I)   x_n XOR y_n -> a_n
    # II)  x_n AND y_n -> b_n
    # III) c_(n-1) AND a_n -> d_n
    # IV)  a_n XOR c_(n-1) -> o_n
    # V)   b_n OR d_n -> c_n

    (in_xor_gates, in_and_gates) = part2_fill_input_gates(circuit, x_count) # I and II
    out_gates = part2_fill_output_gates(circuit, x_count) # V
    # Special handling for MSB output gate
    out_gate_msb = [g for g ∈ circuit.z_gates if g.output_name == ("z" * string(x_count))][1]
    @assert out_gate_msb.operation == "OR"
    @assert all(map(x -> !isnothing(x), in_and_gates))
    @assert all(map(x -> !isnothing(x), in_xor_gates))
    @assert all(map(x -> !isnothing(x), out_gates))
    @assert in_xor_gates[1].output_name == "z00"

    (carry_and_gates, missing_carry_and_gates) = part2_fill_carry_and_gates(circuit, x_count, in_xor_gates, 
        in_and_gates)  # III, carry in
    (carry_or_gates, missing_carry_or_gates) = part2_fill_carry_or_gates(circuit, x_count, in_xor_gates, 
        in_and_gates, out_gate_msb)  # IV, index 1 = carry out of bit 0

    for gate ∈ circuit.gates
        if gate.operation == "XOR" && gate ∉ in_xor_gates && gate ∉ out_gates
            @printf("XOR gate not connected to output: %s!\n", formula(gate))
            print_xor_not_connected(gate, 1, in_xor_gates, carry_or_gates)
            print_xor_not_connected(gate, 2, in_xor_gates, carry_or_gates)
        end
    end
    for gate ∈ missing_carry_and_gates
        println("Couldn't find input for Carry AND in in_xor_gates: ", formula(gate))
        print_carry_and_not_connected(gate, 1, in_xor_gates, carry_or_gates, in_and_gates)
        print_carry_and_not_connected(gate, 2, in_xor_gates, carry_or_gates, in_and_gates)
    end
    for gate ∈ missing_carry_or_gates
        println("Couldn't find input for Carry OR in in_and_gates: ", formula(gate))
        print_carry_or_not_connected(gate, 1, in_and_gates, carry_and_gates, in_xor_gates)
        print_carry_or_not_connected(gate, 2, in_and_gates, carry_and_gates, in_xor_gates)
    end
end

function main()
    circuit = parse_input("input.txt")
    
    println("Question 1: What decimal number does it output on the wires starting with z?")
    println("Answer: $(part1(circuit))")
    
    println("Question 2: What do you get if you sort the names of the eight wires involved in a swap and then join those names with commas?")
    part2(circuit)
    
    # Evaluate output and figure out wrong outputs manually.
    wrong_outputs = ["z16", "hmk", "z20", "fhp", "z33", "fcd", "rvf", "tpc"]
    for i ∈ 1:(length(wrong_outputs) ÷ 2)
        a = wrong_outputs[2 * i - 1]
        b = wrong_outputs[2 * i]
        swap_output(circuit, a, b)
    end
    part2(circuit)
    answer2 = join(sort!(wrong_outputs), ",");
    println("Answer: $answer2")
end

@time main()

# Question 1: What decimal number does it output on the wires starting with z?
# Answer: 66055249060558
# Question 2: What do you get if you sort the names of the eight wires involved in a swap and then join those names with commas?
# Answer: fcd,fhp,hmk,rvf,tpc,z16,z20,z33
#  0.843198 seconds (938.19 k allocations: 46.961 MiB, 1.81% gc time, 96.66% compilation time)
