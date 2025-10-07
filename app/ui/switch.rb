class Switch
  attr_sprite
  attr_accessor :status

  def initialize args={}
    @x = args.x || 1200
    @y = args.y || 540
    @w = args.w || 32
    @h = args.h || 64
    @path = args.path ||  "sprites/switches/run_stop_anim.png"
    @source_x = args.source_x || 0
    @source_y = args.source_y || 0
    @source_h = args.source_h || 64
    @source_w = args.source_w || 32

    @animating = false
    @sprite_width = 32
    @held = false

    @status = 0
    @onlick = args.callback || nil
  end

  def handle_input args
    if !@held and (args.inputs.mouse.button_left and args.inputs.mouse.inside_rect?(self))
      self.click(args)
      @held = true
    elsif !args.inputs.mouse.button_left
      @held = false
    end
  end

  def click args
    if @animating
      return
    end
    @animating = true
  end

  def animate args
  end

  def tick args
    handle_input(args)
    animate(args)
  end
end

class Toggle_Switch < Switch
  def initialize args={}
    super(args)
    @source_x = args.source_x || 128
  end

  def animate args
    if @animating
      if @status == 1
        if @source_x < 128
          @source_x += @sprite_width
        else
          @status = 0
          @animating = false
          if @onclick != nil
            @onclick.call(args)
          end
        end
      else
        if @source_x > 0
          @source_x -= @sprite_width
        else
          @status = 1
          @animating = false
          if @onclick != nil
            @onclick.call(args)
          end
        end
      end
    end
  end
end

class Momentary_Switch < Switch
  def initialize args={}
    super(args)
    @direction = 1
  end

  def handle_input args
    @status = 0
    if !@held and (args.inputs.mouse.button_left and args.inputs.mouse.inside_rect?(self))
      self.click(args)
      @status = 1
      @held = true
    elsif !args.inputs.mouse.button_left
      @held = false
    end
  end

  def animate args
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
