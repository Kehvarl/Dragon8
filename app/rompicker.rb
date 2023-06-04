class RomPicker
attr_accessor :selected_file

  def initialize args
    @file_list = args.gtk.list_files "data/roms/"
  
  end

  def render
    draw = []
    draw << {x: 256, y: 300, w: 512, h: 256, path: "sprites/RomPick.png"}.sprite!
    draw
  end
  
end
