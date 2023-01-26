def initialize args
  args.state.display ||=  Display.new({margin_bottom:256})


  args.state.display.setpixel(rand(64), rand(32), 255, 0, 0, args.state.display.next_buffer)
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
  
end
