class Toggle_Switch
  attr_sprite
  attr_accessor :status

  def initialize args={}
    @x = args.x || 1200
    @y = args.y || 540
    @w = args.w || 32
    @h = args.h || 64
    @path = args.path ||  "sprites/switches/run_stop_anim.png"
    @source_x = args.source_x || 128
    @source_y = args.source_y || 0
    @source_h = args.source_h || 64
    @source_w = args.source_w || 32
    @status = 0
    @animating = false
    @sprite_width = 32
    @held = false
    @onlick = args.callback || nil
  end

  def click args
    if @animating
      return
    end
    @animating = true
  end

  def tick args  
    if !@held and (args.inputs.mouse.button_left and args.inputs.mouse.inside_rect?(self)) or args.inputs.keyboard.key_down.r
      self.click(args)
      @held = true
    elsif !args.inputs.mouse.button_left
      @held = false
    end
  
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
