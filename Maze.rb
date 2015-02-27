begin
  require 'rubytree'
rescue LoadError
  puts "Cannot load such file -- rubytree (LoadError)"
  puts "try 'gem install rubytree' and run again"
  exit(1)
end

class Maze
  def initialize(xSize, ySize)
    @xSize = xSize
    @ySize = ySize
    load_empty()
  end

  def plane_display(map=@maze)
    (0...@ySize).each { |y| puts map[y * @xSize .. (y + 1) * @xSize -1]}
  end

  def display
    maze_display = @maze.chars.map.with_index { |digit, i| digit_to_symbol(i) }.join
    plane_display(maze_display)
  end

  def load(s)
    s.chomp!
    if s.length != @xSize * @ySize
      puts "Input string size does not match with maze size"
      exit(1)
    elsif (s =~ /[^01]/) != nil
      puts "Input string contains illegal characters"
      exit(1)
    else
      @maze = s
    end
  end
  
  def solve(begX, begY, endX, endY)
    begI = to_index(begX, begY)
    endI = to_index(endX, endY)

    return false if @maze[begI] == "1" || @maze[endI] == "1"
    @endI = endI
    buildTree(begI) if @begI != begI

    # Depth-first Search
    @root.each do |node|
      if node.name == @endI.to_s
        @solution = node
        return true
      end
    end
    return false
  end

  def trace(begX, begY, endX, endY)
    begI = to_index(begX, begY)
    endI = to_index(endX, endY)

    if @begI != begI || @endI != endI
      if !solve(begX, begY, endX, endY)
        return nil
      end
    end

    @steps = @solution.parentage.map{ |node| node.name.to_i}.reverse.push(endI)
    return @steps.map { |i| to_xy(i)}
  end

  def display_trace
    if @steps.nil?
      puts "You must call trace before display_trace."
      return
    end
    @steps.each { |i| @solveMaze[i] = "3" } # 3 => trace cell
    maze_display = @solveMaze.chars.map.with_index { |digit, i| solved_digit_to_symbol(i) }.join
    plane_display(maze_display)
  end
  
  # Using DFS recursive backtracker
  def redesign
    load_empty_redesign
    # clear solution cache
    @begI = -1

    stack = Array.new

    current = to_index(1, 1)
    @maze[current] = "0"

    while @maze.include? "4" # "4" => unvisited cell
      
      unvisited_neighbours = secondary_neighbours(current).select { |i| digitAt(i) == "4" }
      if unvisited_neighbours.any?
        # choose randomly one of the unvisited neighbours
        chosen = unvisited_neighbours.sample
        # push the current cell to to stack
        stack.push(current)
        # remove the wall between the current cell and the chosen cell
        @maze[cell_between(current, chosen)] = "0"
        # make the chosen cell the current cell and mark it as visited
        current = chosen
        @maze[current] = "0"
      elsif stack.any?
        # pop a cell from the stack
        # make it the current cell
        current = stack.pop
      else
        # pick a random unvisited cell, make it the current cell and mark it as visited
        current = match_index(@maze, "4").sample
        @maze[current] = "0"
      end

    end
  end
  
  private
  # Part 1 Load maze
  def load_empty(cell = "0")
    @maze = "1" * @xSize + ("1" + cell * (@xSize - 2) + "1") * (@ySize - 2) + "1" * @xSize
  end

  # Part 2 Move around
  def to_xy(*args)
    if args.size == 1
      return (args[0] % @xSize) , (args[0] / @xSize)
    else
      return args[0], args[1]
    end
  end

  def to_index(*args)
    if args.size == 1
      return args[0]
    else
      return args[1] * @xSize + args[0]
    end
  end

  def topOf(*args)
    x, y = to_xy(*args)
    return y == 0 ? nil : to_index(x, y-1)
  end

  def bottomOf(*args)
    x, y = to_xy(*args)
    return y == @ySize - 1 ? nil : to_index(x, y + 1)
  end

  def leftOf(*args)
    x, y = to_xy(*args)
    return x == 0 ? nil : to_index(x - 1 , y)
  end

  def rightOf(*args)
    x, y = to_xy(*args)
    return x == @xSize - 1 ? nil : to_index(x + 1, y)
  end

  def neighbours(*args)
    [topOf(*args), bottomOf(*args), leftOf(*args), rightOf(*args)]
  end

  def secondary_neighbours(*args)
    [topOf(topOf(*args)), bottomOf(bottomOf(*args)), leftOf(leftOf(*args)), rightOf(rightOf(*args))]
  end



  # Part 3 Display maze
  def solved_digit_to_symbol(*args)
    return @solveMaze[to_index(*args)] == "3" ? "*" : digit_to_symbol(*args)
  end

  def digit_to_symbol(*args)
    return " " if @maze[to_index(*args)]=="0"
    s = getSurroundings(*args)
    if (s == "1100")
      return "|"
    elsif s == "0011"
      return "-"
    else
      return "+"
    end
  end

  def digitAt(*args)
    return args[0].nil? ? nil : @maze[to_index(*args)]
  end

  def getSurroundings(*args)
    s = ""
    neighbours(*args).each { |i| s += digitAt(i).to_i.to_s}
    return s
  end

  # Part 4 Solve maze
  def buildTree(rootName)
    @begI = rootName
    @solveMaze = @maze.clone
    @solveMaze[rootName] = "2"
    @root = Tree::TreeNode.new(rootName.to_s)

    addChildren(@root)
  end

  def addChildren(p)
    index = p.name.to_i
    [topOf(index), bottomOf(index), leftOf(index), rightOf(index)].each_with_index do |childName, i|
      tryAddNode(childName, p)
    end
    p.children.each do |child|
      addChildren(child)
    end
    return unless p.has_children?
  end

  def tryAddNode(childName, parent)
    return if @solveMaze[childName].to_i > 0
    @solveMaze[childName] = "2" # 2 => has been visited
    parent << Tree::TreeNode.new(childName.to_s)
    return to_xy(childName)
  end

  # Part 5 Redesign maze
  def load_empty_redesign
    load_empty("1")
    oddX = (1..@xSize-1).step(2).to_a
    oddY = (1..@ySize-1).step(2).to_a
    empty_cells = oddX.product(oddY).map { |tuple| to_index(*tuple) }
    empty_cells.each { |index| @maze[index] = "4"}  # "4" => unvisited cell
  end

  def cell_between(i, j)
    x1, y1 = to_xy(i)
    x2, y2 = to_xy(j)
    if x1 == x2
      return to_index(x1, (y1 + y2) / 2)
    elsif y1 == y2
      return to_index((x1 + x2) / 2, y1)
    else
      return nil
    end
  end

  def match_index(str, pattern)
    res = []
    str.scan(pattern) { res << Regexp.last_match.offset(0).first}
    return res
  end
end