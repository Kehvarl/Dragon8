def initialize args
  args.state.state = :initialize
  args.state.run ||= false
  args.state.display ||=  Display.new({margin_right: 128, margin_bottom:256})
  args.state.controls ||= Controls.new()
  args.state.rs = RunStop.new()
  args.state.s = Step.new()
  args.state.keyboard ||= Keyboard.new()
  args.state.cpu ||= CPU.new(args.state.display)
  contents = args.gtk.read_file "data/roms/IBM Logo.ch8"
  args.state.cpu.set(contents.to_s.unpack('n*'), 0x200)


  args.state.display.xorpixel(rand(64), rand(32), true, args.state.display.next_buffer)
end

def draw_console args
  args.outputs.primitives << {x:0, y:0, w:1280, h:720, path:"sprites/console.png"}.sprite!
  args.outputs.primitives << args.state.controls.render
  args.outputs.primitives << args.state.display.screen
  args.outputs.primitives << args.state.rs
  args.outputs.primitives << args.state.s
end

def handle_keys args
    args.inputs.keyboard.keys[:down].each do |key|
    args.state.keyboard.keydown key
  end

  args.inputs.keyboard.keys[:up].each do |key|
    args.state.keyboard.keyup key
  end

  if args.inputs.keyboard.key_down.p
    args.state.state = :rom_pick
  end

  if args.inputs.keyboard.key_down.r
    #args.state.run = !args.state.run
    args.state.rs.click(args)
    args.state.state = :running
  end

  if args.inputs.keyboard.key_down.s
    args.state.state = :step
  end
  
  if args.inputs.keyboard.key_down.q
    $gtk.request_quit
  end
  if args.inputs.keyboard.key_down.m
    args.state.cpu.debug = !args.state.cpu.debug
  end  
end

def rom_pick_tick args
  args.state.rom ||= RomPicker.new(args)

  draw_console args
  
  args.outputs.primitives << args.state.rom.render

  if args.inputs.keyboard.key_down.enter
    contents = args.gtk.read_file args.state.rom.selected_file
    args.state.cpu.set(contents.to_s.unpack('n*'), 0x200)
    args.state.rom = nil
    args.state.state = :main
  end

  if args.inputs.keyboard.down
    args.state.rom.select_down
  end

  if args.inputs.keyboard.up
    args.state.rom.select_up
  end
  
  if args.inputs.keyboard.key_down.q
    args.state.rom = nil
    args.state.state = :main
  end
end

def main_tick args
  args.state.rs.tick args
  args.state.s.tick args

  draw_console args
end

def tick args
  if args.state.tick_count == 0
    initialize args
    args.state.state = :main
  end


  case args.state.state
  when :rom_pick
    rom_pick_tick args

  when :running
    args.state.cpu.tick args.state.keyboard
    draw_console args
    handle_keys args

  when :step
    args.state.cpu.tick args.state.keyboard
    args.state.state = :main
    handle_keys args

  when :main
    main_tick args
    handle_keys args

  end
end
