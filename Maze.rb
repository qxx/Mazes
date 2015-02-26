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
      puts "Input string size does not match"
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

  def redesign
    load_empty("4") # 4 => undecided cell
    r = Random.new
    begEdge = r.rand(4)
    if begEdge == 0
      begY = 1
    elsif begEdge == 1
      begY = @ySize - 2
    else
      begY = r.rand(@ySize - 2) + 1
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
    s = digitAt(topOf(*args)).to_i.to_s + digitAt(bottomOf(*args)).to_i.to_s +
        digitAt(leftOf(*args)).to_i.to_s + digitAt(rightOf(*args)).to_i.to_s
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

end