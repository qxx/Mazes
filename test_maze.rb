require_relative './Maze.rb'

# Test given example
s = "111111111100010001111010101100010101101110101100000101111011101100000101111111111"
m = Maze.new(9,9)
m.load(s)

# puts "\nShows internal representation of the maze:"
# m.plane_display

puts "\nDisplays the maze:"
m.display

puts "\nHas a solution?:"
puts m.solve(1,1,7,7)

puts "\nShows the solution in an array:"
p m.trace(1,1,7,7)

puts "\nDisplays the solution:"
m.display_trace

# puts "\nNote: The original maze is not changed by the trace"
# m.display

# Test redesign
puts "\nGenerate a new maze:"
m.redesign
m.display

puts "\nSolve the new maze:"
m.trace(1,1,7,7)
m.display_trace
