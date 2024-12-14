""" Advent of Code 2024
    Day 14: Restroom Redoubt
    Author: Chi-Kit Pao
    julia --optimize=3 Day14.jl
"""

struct Robot
    pos::Tuple{Int64,Int64}
    velocity::Tuple{Int64,Int64}
end

function parse_input(file_name::String)::Vector{Robot}
    robots = Vector{Robot}()
    for line ∈ eachline(file_name)
        # Example input:
        # p=69,11 v=-25,6
        m = match(r"p=(?<posx>-?\d+)\,(?<posy>-?\d+) v=(?<velox>-?\d+)\,(?<veloy>-?\d+)", line)
        push!(robots, Robot((parse(Int64, m[:posx]), parse(Int64, m[:posy])), (parse(Int64, m[:velox]), parse(Int64, m[:veloy]))))
    end
    return robots
end

function do_steps(robot::Robot, width::Int64, height::Int64, steps::Int64)::Tuple{Int64,Int64}
    x = (robot.pos[1] + steps * robot.velocity[1]) % width
    if x < 0
        x += width
    end
    y = (robot.pos[2] + steps * robot.velocity[2]) % height
    if y < 0
        y += height
    end
    return (x, y)
end

function get_quadrant(pos::Tuple{Int64,Int64}, width::Int64, height::Int64)
    (hx, m) = divrem(width, 2)
    @assert m == 1
    (hy, m) = divrem(height, 2)
    @assert m == 1
    if pos[1] == hx || pos[2] == hy
        return 0
    end
    if pos[1] < hx
        if pos[2] < hy
            return 1
        else
            return 4
        end
    else
        if pos[2] < hy
            return 2
        else
            return 3
        end
    end
end

function part1(robots::Vector{Robot}, width::Int64, height::Int64)::Int64
    count = zeros(Int64, 4)
    
    for robot ∈ robots
        pos = do_steps(robot, width, height, 100)
        quadrant = get_quadrant(pos, width, height)
        if quadrant != 0
            count[quadrant] += 1
        end
    end

    result = 1
    for c ∈ count
        result *= c
    end
    return result
end

function main()
    robots = parse_input("input.txt")
    width = 101
    height = 103
    println("Question 1: What will the safety factor be after exactly 100 seconds have elapsed?")
    println("Answer: $(part1(robots, width, height))")
end

@time main()

# Question 1: What will the safety factor be after exactly 100 seconds have elapsed?
# Answer: 223020000
#  0.007467 seconds (10.74 k allocations: 555.117 KiB, 75.37% compilation time) 
