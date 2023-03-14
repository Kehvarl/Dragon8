class Controls
  def initialize args={}
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
  end

  def render
    arr = []
    arr << {x: (1280-96), y: 256, w: 64, h: (720-(256+52)), r:90, g:90, b:90}.solid!
    arr
  end
end
