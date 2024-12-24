""" Advent of Code 2024
    Day 23: LAN Party
    Author: Chi-Kit Pao
    julia --optimize=3 Day23.jl
"""


mutable struct Gate
    input1_name::String
    operation::String
    input2_name::String
    output_name::String
    input1::Union{Nothing,Int64}
    input2::Union{Nothing,Int64}
    output::Union{Nothing,Int64}
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

function main()
    circuit = parse_input("input.txt")
    
    println("Question 1: What decimal number does it output on the wires starting with z?")
    println("Answer: $(part1(circuit))")
end

@time main()

# Question 1: What decimal number does it output on the wires starting with z?
# Answer: 66055249060558
#  0.182761 seconds (535.36 k allocations: 27.420 MiB, 98.50% compilation time)