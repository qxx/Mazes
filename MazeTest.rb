require './Maze.rb'
s = "111111111100010001111010101100010101101110101100000101111011101100000101111111111"
m = Maze.new(9,9)
m.load(s)
m.display

puts m.solve(1,1,7,7)

p m.trace(1,1,7,7)

m.display_trace