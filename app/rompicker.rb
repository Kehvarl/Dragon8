class RomPicker
attr_accessor :selected_file

  def initialize args
    @file_list = args.gtk.list_files "data/roms/"
  
  end

  def render
    draw = []
    draw << {x: 256, y: 300, w: 512, h: 256, r: 0x80, g: 0x80, b: 0x80}.solid!
    draw << {x: 256, y: 300, w: 512, h: 256, r: 0x80, g: 0x00, b: 0x00}.border!

    draw
  end
  
end
