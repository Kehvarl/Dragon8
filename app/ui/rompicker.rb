class RomIcon
  attr_accessor :primitives, :x, :y, :w, :h, :text, :highlight, :selected
  def initialize args
    @text = args.text || "no name"
    @type = args.type || "ROM"
    @x = args.x || 0
    @y = args.y || 0
    @w = args.w || 64
    @h = args.h || 64
    @highlight = false
    @selected = false
  end

  def tick args
    if args.inputs.mouse.button_left
      @selected = args.inputs.mouse.inside_rect?(self)
    end
  end

  def render
    out = []
    if @highlight
      out << {x: @x-1, y: @y-1, w: @w + 2, h: @h + 2, r: 128, g: 0, b: 128}.solid!
    else
      out << {x: @x-1, y: @y-1, w: @w + 2, h: @h + 2, r: 128, g: 128, b: 128}.solid!
    end
    out << {x: @x, y: @y, w: @w, h: @w, path: "sprites/rom.png"}.sprite!
    out << {x: @x+12, y: @y+54, w: @w, h: @w, text: @type}.label!
    out << {x: @x+4, y: @y+20, w: @w, h: @w, size_px: 18, text: @text}.label!
    out
  end
end

# grid of Icons
# If click, select  works
# If click on scroll bar, shift scrollbar and view
# If select and click, Open
# on arrow, move select
# If select is off screen, move screen.
# If end of screen, prevent move.
# On Enter and select, open

class RomPicker2
  attr_accessor :selected_file, :close_select, :close_quit
  def initialize args
    @roms = []
    @file_list = args.gtk.list_files "data/roms/"
    @file_list.each do |rom|
      if ['.rom', '.ch8'].include?(rom[-4..-1])
        @roms << RomIcon.new({text: rom[0..-5], type: rom[-3..-1]})
      end
    end
    @close_select = false
    @close_quit = false
    @selected = 0
    @selected_file = @roms[@selected]
  end

  def select_down
    @selected = [@selected+1, @roms.length() -1].min()
    @selected_file = @roms[@selected]
  end

  def select_up
    @selected = [@selected-1, 0].max()
    @selected_file = @roms[@selected]
  end

  def tick args
    @roms.each_with_index do |r, index|
      r.tick args
      if r.selected
        @selected = index
        @selected_file = @roms[index]
      end
    end

    if args.inputs.keyboard.key_down.enter
      @close_select = true
    end

    if args.inputs.keyboard.down
      select_down
    end

    if args.inputs.keyboard.up
      select_up
    end

    if args.inputs.keyboard.key_down.q
      @close_quit = true
    end
    args.outputs.primitives << args.state.rom.render
  end

  def render
    draw = []
    draw << {x: 256, y: 300, w: 512, h: 256, path: "sprites/rompick.png"}.sprite!
    (0..[@roms.count-1, 6].min).each do |index|
      icon =  @roms[index]
      icon.x = 270 + (index * 72)
      icon.y = 556 - 96
      icon.highlight = (index == @selected)
      draw << icon.render
     end
    draw
  end
end


class RomPicker
attr_accessor :selected_file, :close_select, :close_quit

  def initialize args
    @roms = []
    @file_list = args.gtk.list_files "data/roms/"
    @file_list.each do |attachment|
      @roms << attachment if ['.rom', '.ch8'].include?(attachment[-4..-1])
    end
    @close_select = false
    @close_quit = false
    @selected = 0
    @selected_file = @roms[@selected]
  end

  def select_down
    @selected = [@selected+1, @roms.length() -1].min()
    @selected_file = @roms[@selected]
  end

  def select_up
    @selected = [@selected-1, 0].max()
    @selected_file = @roms[@selected]
  end


  def tick args

    args.outputs.primitives << args.state.rom.render

    if args.inputs.keyboard.key_down.enter
      @close_select = true
    end

    if args.inputs.keyboard.down
      select_down
    end

    if args.inputs.keyboard.up
      select_up
    end

    if args.inputs.keyboard.key_down.q
      @close_quit = true
    end
  end

  def render
    draw = []
    draw << {x: 256, y: 300, w: 512, h: 256, path: "sprites/rompick.png"}.sprite!
    (0..[@file_list.count, 6].min).each do |index|
      if index == @selected
        draw << {x:270, y:556 - (index * 24) -46, w:484, h:24,
                 r:128, g:0, b:128}.solid!
      end
      draw << {x:272, y:556 - (index * 24) -24, text:@roms[index],
               r:255, g:255, b:255}.label!
     end
    draw
  end

end
