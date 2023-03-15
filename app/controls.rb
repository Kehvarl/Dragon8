class Controls
  def initialize args={}
    @x = args.x || 1184
    @y = args.y || 256
    @w = args.w || 64
    @h = args.h || 412
  end

  def render
    arr = []
    arr << {x: @x,  y: @y, w: @w, h: @h, r:90, g:90, b:90}.solid!
    arr << {x: @x + 5, y: @y+10, w: @w-10, h: 64, r:128, g:0, b:0}.solid!
    arr
  end
end
