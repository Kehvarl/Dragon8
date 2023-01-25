def tick args
  args.state.display ||=  Display.new({})

  args.outputs.primitives << args.state.display.screen
end
