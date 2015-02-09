class Maze
  def initialize(xSize, ySize)
    @xSize = xSize
    @ySize = ySize
    @maze = "1" * xSize + ("1" + "0"*(@xSize-2) + "1") * (ySize - 2) + "1" * xSize
  end

  def display
    #p @maze
    #(0...@ySize).each {|y| puts @maze[y*@xSize .. (y+1)*@xSize-1]}

    maze_display = @maze.chars.map.with_index { |digit, i| digit_to_symble(i) }.join

    (0...@ySize).each { |y| puts maze_display[y * @xSize .. (y + 1) * @xSize -1] }
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
        


  def digit_to_symble(*args)
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

  def getSurroundings(*args)
    s = digitAt(topOf(*args)).to_i.to_s + digitAt(bottomOf(*args)).to_i.to_s +
        digitAt(leftOf(*args)).to_i.to_s + digitAt(rightOf(*args)).to_i.to_s
    return s
  end

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

  def digitAt(*args)
    return args[0].nil? ? nil : @maze[to_index(*args)]
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

end