class RomPicker
attr_accessor :selected_file

  def initialize args
    @roms = []
    @file_list = args.gtk.list_files "data/roms/"
    @file_list.each do |attachment|
      @roms << attachment if attachment[-4..-1]  == '.rom'
    end
    @selected = 0
  end

  def render
    draw = []
    draw << {x: 256, y: 300, w: 512, h: 256, path: "sprites/RomPick.png"}.sprite!
    (0..[@file_list.count, 6].min).each do |index|
      if index == @selected
        draw << {x:270, y:556 - (index * 16) -48, w:484, h:24, r:128, g:0, b:128}.solid!
      end
      draw << {x:272, y:556 - (index * 16) -24, text:@roms[index], r:255, g:255, b:255}.label!
     end
    draw
  end
  
end
