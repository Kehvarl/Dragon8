def initialize args
  args.state.display ||=  Display.new({margin_bottom:256})


  args.state.display.xorpixel(rand(64), rand(32), true, args.state.display.next_buffer)
end

def tick args
  if args.state.tick_count == 0
    initialize args
  end
  args.outputs.primitives << {x:0, y:0, w:1280, h:720, r:128, g:128, b:128}.solid! 
  args.outputs.primitives << args.state.display.screen

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
