def initialize args
  args.state.run ||= false
  args.state.display ||=  Display.new({margin_right: 128, margin_bottom:256})
  args.state.controls ||= RunStop.new()
  args.state.rs = Control.new({})
  args.state.keyboard ||= Keyboard.new()
  args.state.cpu ||= CPU.new(args.state.display)
  args.state.cpu.set(['00e0', 'a22a', '600c', '6108', 'd01f', '7009', 'a239', 'd01f', 'a248', '7008', 'd01f', '7004', 'a257', 'd01f', '7008', 'a266', 'd01f', '7008', 'a275', 'd01f', '1228', 'ff00', 'ff00', '3c00', '3c00', '3c00', '3c00', 'ff00', 'ffff', '00ff', '0038', '003f', '003f', '0038', '00ff', '00ff', '8000', 'e000', 'e000', '8000', '8000', 'e000', 'e000', '80f8', '00fc', '003e', '003f', '003b', '0039', '00f8', '00f8', '0300', '0700', '0f00', 'bf00', 'fb00', 'f300', 'e300', '43e0', '00e0', '0080', '0080', '0080', '0080', '00e0', '00e0'], 0x200)


  args.state.display.xorpixel(rand(64), rand(32), true, args.state.display.next_buffer)
end

def tick args
  if args.state.tick_count == 0
    initialize args
  end
  args.state.rs.tick args
  
  args.outputs.primitives << {x:0, y:0, w:1280, h:720, r:128, g:128, b:128}.solid!
  args.outputs.primitives << args.state.controls.render
  args.outputs.primitives << args.state.display.screen
  args.outputs.primitives << args.state.rs

  args.inputs.keyboard.keys[:down].each do |key|
    args.state.keyboard.keydown key
  end

  args.inputs.keyboard.keys[:up].each do |key|
    args.state.keyboard.keyup key
  end

  if args.inputs.keyboard.key_down.r
    args.state.run = !args.state.run
  end

  if args.inputs.keyboard.key_down.s or args.state.run or args.state.rs.status == 1
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
