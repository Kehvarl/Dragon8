require 'app/vm/cpu.rb'
require 'app/vm/display.rb'
require 'app/vm/keyboard.rb'
require 'app/ui/controls.rb'


def initialize args
  args.state.state = :main
  args.state.run = false
  args.state.display =  Display.new({margin_right: 128, margin_bottom:256})
  args.state.controls = Controls.new()
  args.state.rs = RunStop.new()
  args.state.s = Step.new()
  args.state.r = ROM_Load.new()
  args.state.color_picker = Color_Picker.new({x: 1184, y: 633, w: 64, h: 32})
  args.state.keyboard = Keyboard.new()
  args.state.cpu = CPU.new(args.state.display)
  contents = args.gtk.read_file "data/roms/drlogo.rom"
  args.state.cpu.set(contents.to_s.unpack('n*'), 0x200)

  args.state.ritest = RomIcon.new({})

  args.state.rom = nil

end

def draw_console args
  args.outputs.primitives << {x:0, y:0, w:1280, h:720, path:"sprites/console.png"}.sprite!
  args.outputs.primitives << args.state.controls.render
  args.outputs.primitives << args.state.display.screen
  args.outputs.primitives << args.state.rs
  args.outputs.primitives << args.state.s
  args.outputs.primitives << args.state.r
  args.outputs.primitives << args.state.color_picker.render
  args.outputs.primitives << args.state.ritest.render
end

def handle_keys args
    args.inputs.keyboard.keys[:down].each do |key|
    args.state.keyboard.keydown key
  end

  args.inputs.keyboard.keys[:up].each do |key|
    args.state.keyboard.keyup key
  end

  if args.inputs.keyboard.key_down.p
    args.state.r.click args
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

  if args.inputs.keyboard.key_down.b
    args.state.display.clear
    args.state.cpu.pc = 0x200
    if args.state.state == :running
      args.state.rs.click(args)
    end
    args.state.state = :initialize

  end

  if args.inputs.keyboard.key_down.m
    args.state.cpu.debug = !args.state.cpu.debug
  end
end


def main_tick args
  args.state.rs.tick args
  args.state.s.tick args
  args.state.r.tick args
  args.state.color_picker.tick args
  args.state.display.recolor args.state.color_picker.get_colors

  if args.state.rs.status == 1
    args.state.state = :running
  end

  if args.state.s.status == 1
    args.state.state = :step
  end

  if args.state.r.status == 1
    args.state.state = :rom_pick
  end
end

def rom_load_tick args
  if args.state.rom == nil
    args.state.rom = RomPicker2.new(args)
  end

  args.state.rom.tick args

  if args.state.rom.close_select
      contents = args.gtk.read_file "data/roms/#{args.state.rom.selected_file}"

      args.state.cpu.set(contents.to_s.unpack('n*'), 0x200)
  end

  if args.state.rom.close_quit or args.state.rom.close_select
    args.state.rom = nil
    args.state.state = :main
  end
end

def tick args
  if args.state.tick_count == 0
    initialize args
    args.state.state = :main
  end

  draw_console args

  case args.state.state
  when :initialize
    initialize args

  when :rom_pick
    rom_load_tick args

  when :running
    args.state.cpu.tick args.state.keyboard
    main_tick args
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
