class Controls
  def initialize args={}
    @x = args.x || 1184
    @y = args.y || 256
    @w = args.w || 64
    @h = args.h || 412

    @color = 0
    @colors = [{r:255, g:255, b:255}, {r:128, g:128, b:0}, {r:0, g:128, b:0}]
  end

  def monitor_color x, y, w, h
    wi = {x: x, y: y, w: w/3, h:h, **@colors[0]}.solid!
    a = {x: x+(w/3), y: y, w: w/3, h:h, **@colors[1]}.solid!
    g = {x: x+(2*w/3), y: y, w: w/3, h:h, **@colors[2]}.solid!
    case @color
    when 0
      bx = x
    when 1
      bx = x + (w/3)
    when 2
      bx = x + (2*w/3)
    end

    border = {x: bx, y: y, w: w/3, h: h, r: 0, g: 0, b: 0}.border!
    shade = {x: bx, y: y, w: w/3, h: h, r: 128, g: 128, b: 128, a: 64}.solid!
    return [wi, a, g, border, shade]
  end
  
  def run_stop x, y, w, h
    {x: x + 5, y: y+10, w: w-10, h: h, r:128, g:0, b:0}.solid!
  end

  def step x, y, w, h
    {x: x + 5, y: y+10, w: w-10, h: 64, r:128, g:128, b:0}.solid!    
  end

  def render
    arr = []
    arr << {x: @x,  y: @y, w: @w, h: @h, r:90, g:90, b:90}.solid!
    arr << run_stop(@x, @y+@h-138, @w, 64)
    arr << monitor_color(@x, @y + @h-37, @w, 32)
    arr << step(@x, @y+@h-232, @w, 64)
    arr
  end
end
