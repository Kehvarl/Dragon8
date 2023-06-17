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
    draw << {x: 256, y: 300, w: 512, h: 256, path: "sprites/RomPick.png"}.sprite!
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
