require 'app/ui/switch.rb'
require 'app/ui/rompicker.rb'


# Display Color
# Run/Stop
# Step
# Keyboard
# ROM
# Memory/Machine

class RunStop < Toggle_Switch
  def initialize args={}
    super args
    @x = args.x || 1200
    @y = args.y || 540
    @w = args.w || 32
    @h = args.h || 64
    @path = args.path ||  "sprites/switches/run_stop_anim.png"
  end
end

class Step < Momentary_Switch
  def initialize args={}
    super args
    @x = args.x || 1200
    @y = args.y || 444
    @w = args.w || 32
    @h = args.h || 64
    @path = args.path ||  "sprites/switches/step_anim.png"
  end
end

class ROM_Load < Momentary_Switch
  def initialize args={}
    super args
    @x = args.x || 1200
    @y = args.y || 348
    @w = args.w || 32
    @h = args.h || 64
    @path = args.path || "sprites/switches/step_anim.png"
  end
end

class Color_Picker
  attr_accessor :w, :h, :x, :y, :color
  def initialize args={}
    @colors = [{r:255, g:255, b:255}, {r:128, g:128, b:0}, {r:0, g:128, b:0}]
    @color = args.color || 0
    @x = args.x || 0
    @y = args.y || 0
    @w = args.w || 64
    @h = args.h || 32
  end

  def tick args
    if args.inputs.mouse.button_left and args.inputs.mouse.inside_rect?(self)

    end
  end

  def render
    wi = {x: @x,          y: @y, w: @w/3, h: @h, **@colors[0]}.solid!
    a  = {x: @x+(@w/3),   y: @y, w: @w/3, h: @h, **@colors[1]}.solid!
    g  = {x: @x+(2*@w/3), y: @y, w: @w/3, h: @h, **@colors[2]}.solid!
    border = {x: @x + (@color * @w/3), y: @y, w: @w/3, h: @h, r: 0, g: 0, b: 0}.border!
    shade = {x: @x + (@color * @w/3),  y: @y, w: @w/3, h: @h, r: 128, g: 128, b: 128, a: 64}.solid!
    return [wi, a, g, border, shade]
  end

end

class Controls
  def initialize args={}
    @x = args.x || 1184
    @y = args.y || 256
    @w = args.w || 64
    @h = args.h || 412
    @run_stop=1
  end

  def render
    arr = []
    arr << {x: @x,  y: @y, w: @w, h: @h, r:90, g:90, b:90}.solid!
    arr << {x: 64, y: @y-48, w: 96, h: 24, path: "sprites/label_mem.png", source_w: 64, source_h: 16}.sprite!    
    arr << {x: 64, y: @y-76, w: 16, h: 16, path: "sprites/led_red.png", source_w: 32, source_h: 32}.sprite!
    arr << {x: 84, y: @y-76, w: 16, h: 16, path: "sprites/led_red.png", source_w: 32, source_h: 32}.sprite!
    arr << {x: 104, y: @y-76, w: 16, h: 16, path: "sprites/led_red.png", source_w: 32, source_h: 32}.sprite!
    arr << {x: 124, y: @y-76, w: 16, h: 16, path: "sprites/led_red.png", source_w: 32, source_h: 32}.sprite!

    arr << {x: 164, y: @y-76, w: 16, h: 16, path: "sprites/led_red.png", source_w: 32, source_h: 32}.sprite!
    arr << {x: 184, y: @y-76, w: 16, h: 16, path: "sprites/led_red.png", source_w: 32, source_h: 32}.sprite!
    arr << {x: 204, y: @y-76, w: 16, h: 16, path: "sprites/led_red.png", source_w: 32, source_h: 32}.sprite!
    arr << {x: 224, y: @y-76, w: 16, h: 16, path: "sprites/led_red.png", source_w: 32, source_h: 32}.sprite!
    arr
  end
end
