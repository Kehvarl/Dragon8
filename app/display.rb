class Display
  attr_accessor :border, :w, :h, :screen, :buff
  def initialize args
    @w = args.w || 64
    @h = args.h || 32
    @margin = args.margin || 64
    @screen = []
    @sw = (1280 - (@margin*2))/@w
    @sh = (720 - (@margin*2))/@h
    (0..@w).each do |y|
      @screen << []
      (0..@h).each do |x|
        @screen[y] << {
    x: @sw * x + @margin,
    y: @sh * y + @margin,
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
    @buff = @screen.dup()
  end

  def swap
    temp = @screen.dup
    @screen = @buff.dup()
    @buff = temp
  end
  
 end
