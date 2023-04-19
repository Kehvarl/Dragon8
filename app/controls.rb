class Momentary
  attr_sprite
  attr_reader :status

  def initialize args={}
    @x = args.x || 1200
    @y = args.y || 444
    @w = args.w || 32
    @h = args.h || 64
    @path = args.path ||  "sprites/switches/step_anim.png"
    @source_x = args.source_x || 0
    @source_y = args.source_y || 0
    @source_h = args.source_h || 64
    @source_w = args.source_w || 32
    @status = 0
    @animating = false
    @direction = 1
    @sprite_width = 32
    @held = false
    @onlick = args.callback || nil
  end

  def click args
    if @animating
      return
    end
    if args.inputs.mouse.inside_rect?(self)
      @animating = true
    end
  end

  def tick args
    @status = 0
    
    if args.inputs.mouse.button_left and !@held
      self.click(args)
      @status = 1
      @held = true
    elsif !args.inputs.mouse.button_left
      @held = false
    end
  
    if @animating
      if @direction == 1
        if @source_x < 128
          @source_x += @sprite_width
        else
          @direction = 0
        end
      else
        if @source_x > 0
          @source_x -= @sprite_width
        else
          @direction = 1
          @animating = false
        end
      end
    end
  end
end

# Display Color
# Run/Stop
# Step
# Keyboard
# ROM
# Memory/Machine

class Controls
  def initialize args={}
    @x = args.x || 1184
    @y = args.y || 256
    @w = args.w || 64
    @h = args.h || 412

    @color = 0
    @colors = [{r:255, g:255, b:255}, {r:128, g:128, b:0}, {r:0, g:128, b:0}]

    @run_stop=1
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
    case @run_stop
    when 1
      sx = 0
    when 0
      sx = 128
    end
    {x: x + 16, y: y+10, w: w-10, h: h,
     path: "sprites/switches/run_stop.png",
     source_w:32, source_x:sx}.sprite!
  end

  def step x, y, w, h
    {x: x + 5, y: y+10, w: w-10, h: 64, r:128, g:128, b:0}.solid!    
  end

  def render
    arr = []
    arr << {x: @x,  y: @y, w: @w, h: @h, r:90, g:90, b:90}.solid!
    # arr << run_stop(@x, @y+@h-138, 42, 64)
    arr << monitor_color(@x, @y + @h-37, @w, 32)
    # arr << step(@x, @y+@h-232, @w, 64)
    arr
  end
end
