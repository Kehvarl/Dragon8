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
    
    if !@held and (args.inputs.mouse.button_left and args.inputs.mouse.inside_rect?(self))
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

