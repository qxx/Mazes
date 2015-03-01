# Mazes

Maze requires rubytree gem. Try "gem install rubytree" if you don't have it.

### Digit representation interpretation
* "0" => empty cell / unvisited cell when building search tree
* "1" => wall
* "2" => visited when building search tree
* "3" => trace of solution, used in display_trace
* "4" => unvisited cell when redesigning, which means it's not decided that whether it's an empty cell or wall
