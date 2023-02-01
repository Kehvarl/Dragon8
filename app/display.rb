class Display
  def initialize args
    @w = args.w || 64
    @h = args.h || 32
    @screen_width  = args.screen_width  || 1280
    @screen_height = args.screen_heignt || 720
    @margin_top    = args.margin_top    || 64
    @margin_bottom = args.margin_bottom || 64
    @margin_left   = args.margin_left   || 64
    @margin_right  = args.margin_right  || 64
    @sw = (@screen_width - (@margin_left + @margin_right))/@w
    @sh = (@screen_height - (@margin_top + @margin_bottom))/@h
    @screen_buffers = []
    @current_buffer = 0
    @screen_buffers << create_screen_buffer
    @screen_buffers << create_screen_buffer
  end

  def create_screen_buffer
    buffer = []
    (0..@h).each do |y|
      buffer << []
      (0..@w).each do |x|
        buffer[y] << {
          x: (@sw * x) + @margin_left,
          y: (@sh * y) + @margin_bottom,
          w: @sw,
          h: @sh,
          path: :pixel,
          a: 255,
          r: 0,
          g: 0,
          b: 0,
          blendmode_enum: 1
        }.sprite!
      end
    end
    buffer
  end

  def clear buffer=nil
    if buffer
      @screen_buffers[buffer] = create_screen_buffer
    else
    @screen_buffers = []
    @screen_buffers << create_screen_buffer
    @screen_buffers << create_screen_buffer      
    end
  end

  def setpixel x, y, r=0, g=0, b=0, buffer=0
    @screen_buffers[buffer][y][x].r = r
    @screen_buffers[buffer][y][x].g = g
    @screen_buffers[buffer][y][x].b = b    
  end

  def xorpixel x, y, set=false, buffer=0
    set_to_unset = false
    color = 0
    if set then color = 255 end
    if @screen_buffers[buffer][y][x].r == 255
      if set
        set_to_unset = true
        color = 0
      end
    end
    setpixel(x, y, color, color, color, buffer)
    return set_to_unset
  end

  def writebyte x, y, byte, buffer=nil
    any_set_to_unset = false
    if buffer == nil
      buffer = next_buffer      
    end
    b = byte.to_s(2)
    b.each_char.with_index do |char, index|
      if xorpixel(x+index, y, char=="1", buffer)
        any_set_to_unset = true
      end
    end
    any_set_to_unset
  end

  def next_buffer
    if @current_buffer == 0
      return 1
    end
    return 0
  end

  def current_buffer
    @current_buffer
  end

  def next_screen_buffer
    @screen_buffers[next_buffer]    
  end

  def swap
   @current_buffer = next_buffer
  end

  def screen
    @screen_buffers[@current_buffer]
  end
  
 end
