class Display
  def initialize args
    @w = args.w || 63
    @h = args.h || 31
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

  # Create a new screen buffer
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

  # Clear the specified buffer.
  # If no buffer is specified, clears all buffers
  def clear buffer=nil
    if buffer
      @screen_buffers[buffer] = create_screen_buffer
    else
    @screen_buffers = []
    @screen_buffers << create_screen_buffer
    @screen_buffers << create_screen_buffer      
    end
  end

  # Actually set the appearance of a specific pixel in the screen buffer
  def setpixel x, y, r=0, g=0, b=0, buffer=0
    @screen_buffers[buffer][y][x].r = r
    @screen_buffers[buffer][y][x].g = g
    @screen_buffers[buffer][y][x].b = b
  end

  # Set a specific pixel
  # Return True if the pixel was already set
  def xorpixel x, y, set=false, buffer=0
    set_to_unset = false
    color = 0
    if set then color = 255 end

    y = @h - y
    if @screen_buffers[buffer][y][x].r == 255
      if set
        set_to_unset = true
        color = 0
      else
        color = 255
      end
    end
    setpixel(x, y, color, color, color, buffer)
    return set_to_unset
  end

  # Write a byte to the screen, 1 pixel per bit
  # Return true if any set pixel of the byte collides with
  # any pixel already on screen
  def writebyte x, y, byte, buffer=nil
    any_set_to_unset = false
    if buffer == nil
      buffer = next_buffer      
    end
    7.step(0,-1).each_with_index do |index, bit|
      if xorpixel(x+index, y, byte & (1<<bit) == (1<<bit), buffer)
        any_set_to_unset = true
      end
    end
    any_set_to_unset
  end

  # Draw an 8xN sprite to the display, 0 < N < 16
  # Return true if any set pixel of the sprite collides with some
  # other pixel on screen
  def writesprite x, y, sprite, buffer=nil
    any_set_to_unset = false
    if buffer == nil
      buffer = next_buffer
    end
    sprite.each.with_index do |byte, index|
      if writebyte(x, y+index, byte, buffer)
        any_set_to_unset = true
      end
    end
    any_set_to_unset
  end

  # Get the next screen buffer index
  def next_buffer
    if @current_buffer == 0
      return 1
    end
    return 0
  end

  # Get the current screen buffer index
  def current_buffer
    @current_buffer
  end

  # Make the next screen buffer active
  def swap
   @current_buffer = next_buffer
  end

  # Return the current screen buffer
  def screen
    @screen_buffers[@current_buffer]
  end

  # Return the next screen buffer
  def next_screen_buffer
    @screen_buffers[next_buffer]    
  end

  def serialize
    {
      w: @w,
      h: @h,
      screen_buffers: @screen_buffers,
      current_buffer: @current_buffer
    }
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end
  
end
