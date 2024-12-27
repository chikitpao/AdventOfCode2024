""" Advent of Code 2024
    Day 21: Keypad Conundrum
    Author: Chi-Kit Pao
    julia --optimize=3 Day21.jl
"""

using DataStructures

struct ParsedInput
    codes::Vector{String}
    numbers::Vector{Int64}
end

function parse_input(file_name::String)::ParsedInput
    codes = readlines("input.txt")
    numbers = Vector{Int64}()
    for code ∈ codes
        @assert code[4] == 'A'
        @assert all(map(c -> isdigit(c), collect(code[1:3])))
        push!(numbers, parse(Int64, code[1:3]))
    end
    return ParsedInput(codes, numbers)
end

mutable struct Pad
    key_pair_to_seq::Dict{Tuple{Char, Char}, String}
end
mutable struct Keypads
    numeric_pad::Pad
    directional_pad::Pad
end

function init_keypads()::Keypads
    # Rules for key combinations:
    # 1. Same directional input shall be grouped to prevent cost of switching.
    # 2. Reddit user r/Boojum pointed out (in the Solution Megathread) to 
    #    prioritize moving < over ^ over v over >, if possible. (Thank you very much!)

    # numeric_pad_layout = ["789", "456", "123", " 0A"]
    np_dict = Dict( ('7','7') => "A", ('7','8') => ">A", ('7','9') => ">>A",
                    ('7','4') => "vA", ('7','5') => "v>A", ('7','6') => "v>>A",
                    ('7','1') => "vvA", ('7','2') => "vv>A", ('7','3') => "vv>>A",
                    ('7','0') => ">vvvA", ('7','A') => ">>vvvA",
                    ('8','7') => "<A", ('8','8') => "A", ('8','9') => ">A",
                    ('8','4') => "<vA", ('8','5') => "vA", ('8','6') => "v>A",
                    ('8','1') => "<vvA", ('8','2') => "vvA", ('8','3') => "vv>A",
                    ('8','0') => "vvvA", ('8','A') => "vvv>A",
                    ('9','7') => "<<A", ('9','8') => "<A", ('9','9') => "A",
                    ('9','4') => "<<vA", ('9','5') => "<vA", ('9','6') => "vA",
                    ('9','1') => "<<vvA", ('9','2') => "<vvA", ('9','3') => "vvA",
                    ('9','0') => "<vvvA", ('9','A') => "vvvA",
                    ('4','7') => "^A", ('4','8') => "^>A", ('4','9') => "^>>A",
                    ('4','4') => "A", ('4','5') => ">A", ('4','6') => ">>A",
                    ('4','1') => "vA", ('4','2') => "v>A", ('4','3') => "v>>A",
                    ('4','0') => ">vvA", ('4','A') => ">>vvA",
                    ('5','7') => "<^A", ('5','8') => "^A", ('5','9') => "^>A",
                    ('5','4') => "<A", ('5','5') => "A", ('5','6') => ">A",
                    ('5','1') => "<vA", ('5','2') => "vA", ('5','3') => "v>A",
                    ('5','0') => "vvA", ('5','A') => "vv>A",
                    ('6','7') => "<<^A", ('6','8') => "<^A", ('6','9') => "^A",
                    ('6','4') => "<<A", ('6','5') => "<A", ('6','6') => "A",
                    ('6','1') => "<<vA", ('6','2') => "<vA", ('6','3') => "vA",
                    ('6','0') => "<vvA", ('6','A') => "vvA",
                    ('1','7') => "^^A", ('1','8') => "^^>A", ('1','9') => "^^>>A",
                    ('1','4') => "^A", ('1','5') => "^>A", ('1','6') => "^>>A",
                    ('1','1') => "A", ('1','2') => ">A", ('1','3') => ">>A",
                    ('1','0') => ">vA", ('1','A') => ">>vA",
                    ('2','7') => "<^^A", ('2','8') => "^^A", ('2','9') => "^^>A",
                    ('2','4') => "<^A", ('2','5') => "^A", ('2','6') => "^>A",
                    ('2','1') => "<A", ('2','2') => "A", ('2','3') => ">A",
                    ('2','0') => "vA", ('2','A') => "v>A",
                    ('3','7') => "<<^^A", ('3','8') => "<^^A", ('3','9') => "^^A",
                    ('3','4') => "<<^A", ('3','5') => "<^A", ('3','6') => "^A",
                    ('3','1') => "<<A", ('3','2') => "<A", ('3','3') => "A",
                    ('3','0') => "<vA", ('3','A') => "vA",
                    ('0','7') => "^^^<A", ('0','8') => "^^^A", ('0','9') => "^^^>A",
                    ('0','4') => "^^<A", ('0','5') => "^^A", ('0','6') => "^^>A",
                    ('0','1') => "^<A", ('0','2') => "^A", ('0','3') => "^>A",
                    ('0','0') => "A", ('0','A') => ">A",
                    ('A','7') => "^^^<<A", ('A','8') => "<^^^A", ('A','9') => "^^^A",
                    ('A','4') => "^^<<A", ('A','5') => "<^^A", ('A','6') => "^^A", 
                    ('A','1') => "^<<A", ('A','2') => "<^A", ('A','3') => "^A",
                    ('A','0') => "<A", ('A','A') => "A")
    numeric_pad = Pad(np_dict)

    # directional_pad_layout = [" ^A", "<v>"]
    dp_dict = Dict( ('^','^') => "A", ('^','A') => ">A",
                    ('^','<') => "v<A", ('^','v') => "vA", ('^','>') => "v>A",
                    ('A','^') => "<A", ('A','A') => "A",
                    ('A','<') => "v<<A", ('A','v') => "<vA", ('A','>') => "vA",
                    ('<','^') => ">^A", ('<','A') => ">>^A",
                    ('<','<') => "A", ('<','v') => ">A", ('<','>') => ">>A",
                    ('v','^') => "^A", ('v','A') => "^>A",
                    ('v','<') => "<A", ('v','v') => "A", ('v','>') => ">A",
                    ('>','^') => "<^A", ('>','A') => "^A",
                    ('>','<') => "<<A", ('>','v') => "<A", ('>','>') => "A")
    directional_pad = Pad(dp_dict)

    return Keypads(numeric_pad, directional_pad)
end

function get_sequence_count(keypads::Keypads, input_sequence::DefaultDict{Tuple{Char,Char}, Int64}, level::Int64, 
    directional_robot_count::Int64)::DefaultDict{Tuple{Char,Char}, Int64}
    @assert level <= directional_robot_count + 1
    output_sequence = DefaultDict{Tuple{Char,Char}, Int64}(0)

    pad = level == 1 ? keypads.numeric_pad.key_pair_to_seq : keypads.directional_pad.key_pair_to_seq
    for (p, pc) ∈ input_sequence
        sequence = pad[p]
        for (i, c) = enumerate(sequence)
            if i == 1
                output_sequence[('A', c)] += pc
            else
                output_sequence[(sequence[i-1], c)] += pc
            end
        end
    end

    if level == directional_robot_count + 1
        return output_sequence
    else
        return get_sequence_count(keypads, output_sequence, level + 1, directional_robot_count)
    end
end


function get_sequence_length(keypads::Keypads, code::String, directional_robot_count::Int64)::Int64
    input_sequence = DefaultDict{Tuple{Char,Char}, Int64}(0)
    for (i, c) = enumerate(code)
        if i == 1
            input_sequence[('A', c)] += 1
        else
            input_sequence[(code[i-1], c)] += 1
        end
    end

    output_sequence = get_sequence_count(keypads, input_sequence, 1, directional_robot_count)
    return sum(values(output_sequence))
end

function answer(parsed_input::ParsedInput, keypads::Keypads, directional_robot_count::Int64)::Int64
    result = 0
    for (code, number) ∈ zip(parsed_input.codes, parsed_input.numbers)
        result += number * get_sequence_length(keypads, code, directional_robot_count) 
    end
    return result
end


function main()
    parsed_input = parse_input("input.txt")
    keypads = init_keypads()

    para1 = ["029A", "980A", "179A", "456A", "379A"]
    para2 = map(s -> parse(Int64, s[1:3]), para1)
    println("Test Answer: $(answer(ParsedInput(para1, para2), keypads, 2))")
    
    println("Question 1: What is the sum of the complexities of the five codes on your list?")
    println("Answer: $(answer(parsed_input, keypads, 2))")
    println("Question 2: What is the sum of the complexities of the five codes on your list?")
    println("Answer: $(answer(parsed_input, keypads, 25))")
end

@time main()

# Test Answer: 126384
# Question 1: What is the sum of the complexities of the five codes on your list?
# Answer: 94426
# Question 2: What is the sum of the complexities of the five codes on your list?
# Answer: 118392478819140
#   0.009336 seconds (6.97 k allocations: 577.266 KiB, 59.27% compilation time)