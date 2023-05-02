def initialize args
  args.state.run ||= false
  args.state.display ||=  Display.new({margin_right: 128, margin_bottom:256})
  args.state.controls ||= Controls.new()
  args.state.rs = RunStop.new()
  args.state.s = Step.new()
  args.state.keyboard ||= Keyboard.new()
  args.state.cpu ||= CPU.new(args.state.display)
  #args.state.cpu.set([0x00e0, 0xa22a, 0x600c, 0x6108, 0xd01f, 0x7009, 0xa239, 0xd01f, 0xa248, 0x7008,
  #                    0xd01f, 0x7004, 0xa257, 0xd01f, 0x7008, 0xa266, 0xd01f, 0x7008, 0xa275, 0xd01f,
  #                    0x1228, 0xff00, 0xff00, 0x3c00, 0x3c00, 0x3c00, 0x3c00, 0xff00, 0xffff, 0x00ff,
  #                    0x0038, 0x003f, 0x003f, 0x0038, 0x00ff, 0x00ff, 0x8000, 0xe000, 0xe000, 0x8000,
  #                    0x8000, 0xe000, 0xe000, 0x80f8, 0x00fc, 0x003e, 0x003f, 0x003b, 0x0039, 0x00f8,
  #                    0x00f8, 0x0300, 0x0700, 0x0f00, 0xbf00, 0xfb00, 0xf300, 0xe300, 0x43e0, 0x00e0,
  #                    0x0080, 0x0080, 0x0080, 0x0080, 0x00e0, 0x00e0], 0x200)
  # Load Logo Sprites starting at 0x400
  args.state.cpu.set([0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF,
                      0xFFFF, 0xFFFE, 0xFEFC, 0xFCF9, 0xFBF2, 0xF0F0, 0xF8FC, 0xFEFF,
                      0x8083, 0x0100, 0x3EFF, 0xFF87, 0x1C38, 0x7870, 0xF070, 0x783C,
                      0x9ECE, 0xE7F3, 0xF9FD, 0xFEFE, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF,
                      0x0080, 0xC1EE, 0x67E3, 0xE7EF, 0xDF9F, 0x1E1E, 0x1E0F, 0x0F0F,
                      0x0F03, 0x0381, 0xC1E1, 0xF078, 0x3F9F, 0xCFE7, 0xF3F8, 0xFCFF,
                      0x0000, 0xC0FC, 0xFFFB, 0xFFFF, 0xFF7F, 0xCCA0, 0x70D0, 0x38A4,
                      0xDED9, 0xE3F6, 0x7470, 0x79F1, 0xF3E7, 0xCF9F, 0x3F7F, 0xFFFF,
                      0x0707, 0x0301, 0x31F8, 0xF8FC, 0xF810, 0x0000, 0x0000, 0x0103,
                      0x070F, 0x1F3F, 0x7FFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF,
                      0xFFFF, 0xFFFF, 0xFFFF, 0x7F7F, 0x3F1F, 0x3F7F, 0xFFFF, 0xFFFF], 0x400)
  # Draw Routine Starting at 0x200.  Set PC to 0x200
  args.state.cpu.set([0xA400, 0x6000, 0x6100, 0xD01F, 0x6110, 0xD01F, 0x6008, 0xD01F,
                      0x6030, 0xD01F, 0x6038, 0xD01F, 0x6100, 0xD01F, 0xA410, 0x6008,
                      0x6100, 0xD01F, 0xA420, 0x6010, 0x6100, 0xD01F, 0xA430, 0x6110,
                      0xD01F, 0xA440, 0x6018, 0x6100, 0xD01F, 0xA450, 0x6110, 0xD01F,
                      0xA460, 0x6020, 0x6100, 0xD01F, 0xA470, 0x6110, 0xD01F, 0xA480,
                      0x6028, 0x6100, 0xD01F, 0xA490, 0x6110, 0xD01F, 0xA4A0, 0x6030,
                      0x6100, 0xD01F, 0x1264], 0x200)

  args.state.display.xorpixel(rand(64), rand(32), true, args.state.display.next_buffer)
end

def tick args
  if args.state.tick_count == 0
    initialize args
  end
  args.state.rs.tick args
  args.state.s.tick args
  
  args.outputs.primitives << {x:0, y:0, w:1280, h:720, path:"sprites/console.png"}.sprite!
  args.outputs.primitives << args.state.controls.render
  args.outputs.primitives << args.state.display.screen
  args.outputs.primitives << args.state.rs
  args.outputs.primitives << args.state.s

  args.inputs.keyboard.keys[:down].each do |key|
    args.state.keyboard.keydown key
  end

  args.inputs.keyboard.keys[:up].each do |key|
    args.state.keyboard.keyup key
  end

  if args.inputs.keyboard.key_down.r
    #args.state.run = !args.state.run
    args.state.rs.click(args)
  end

  if args.inputs.keyboard.key_down.s or args.state.run or args.state.rs.status == 1 or args.state.s.status == 1
    args.state.cpu.tick args.state.keyboard
  end
  if args.inputs.keyboard.key_down.q
    $gtk.request_quit
  end
  if args.inputs.keyboard.key_down.m
    args.state.cpu.debug = !args.state.cpu.debug
  end  
end

def junk args
   if args.inputs.keyboard.key_down.j
    args.state.display.swap()
  end

  if args.inputs.keyboard.key_held.s
    # args.state.display.xorpixel(rand(64), rand(32), true, args.state.display.next_buffer)
    # args.state.display.writebyte(rand(56), rand(32), 0b10101010, 0)
    sprite = [36, 102, 255, 126, 60, 24]
    args.state.display.writesprite(rand(56), rand(27), sprite, 0)
  end
  
  if args.inputs.keyboard.key_down.k
    args.state.display.clear(args.state.display.current_buffer)
  end

  if args.inputs.keyboard.key_down.a
    args.state.display.clear
  end
end
