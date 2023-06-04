def initialize args
  args.state.run ||= false
  args.state.display ||=  Display.new({margin_right: 128, margin_bottom:256})
  args.state.controls ||= Controls.new()
  args.state.rs = RunStop.new()
  args.state.s = Step.new()
  args.state.keyboard ||= Keyboard.new()
  args.state.cpu ||= CPU.new(args.state.display)
  contents = args.gtk.read_file "data/roms/drlogo.rom"
  args.state.cpu.set(contents.to_s.unpack('n*'), 0x200)


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

  if args.inputs.keyboard.key_held.p
    rom =  RomPicker.new(args)
    args.outputs.primitives << rom.render
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
