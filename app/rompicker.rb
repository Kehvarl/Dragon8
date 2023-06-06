class RomPicker
attr_accessor :selected_file

  def initialize args
    @file_list = args.gtk.list_files "data/roms/"
  
  end

  def render
    draw = []
    draw << {x: 256, y: 300, w: 512, h: 256, path: "sprites/RomPick.png"}.sprite!
    (0..[@file_list.count, 6].min).each do |index|
       draw << {x: 272, y:556 - (index * 16) -24, text: @file_list[index], r: 255, g: 255, b: 255}.label!
     end
    draw
  end
  
end
