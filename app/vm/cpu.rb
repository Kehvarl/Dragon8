class CPU
  attr_accessor :debug, :ticks_per_frame, :register, :i, :pc, :memory, :sp, :stack, :delay, :sound
  def initialize display
    @debug = false
    @ticks_per_frame = 1
    @display = display
    @register = Array.new(16, 0)
    @i = 0
    @pc = 0
    @memory = Array.new(4096, 0)
    @sp = -1
    @stack = []
    (0..48).each do
      @stack << 0
    end
    @symbol = {}
    setup_font()
    @delay = 0
    @sound = 0
    @keydown = nil
    @keycapture = false
    @keytarget = 0
  end

  def setup_font
    [
     0xF0, 0x90, 0x90, 0x90, 0xF0, # 0
     0x20, 0x60, 0x20, 0x20, 0x70, # 1
     0xF0, 0x10, 0xF0, 0x80, 0xF0, # 2
     0xF0, 0x10, 0xF0, 0x10, 0xF0, # 3
     0x90, 0x90, 0xF0, 0x10, 0x10, # 4
     0xF0, 0x80, 0xF0, 0x10, 0xF0, # 5
     0xF0, 0x80, 0xF0, 0x90, 0xF0, # 6
     0xF0, 0x10, 0x20, 0x40, 0x40, # 7
     0xF0, 0x90, 0xF0, 0x90, 0xF0, # 8
     0xF0, 0x90, 0xF0, 0x10, 0xF0, # 9
     0xF0, 0x90, 0xF0, 0x90, 0x90, # A
     0xE0, 0x90, 0xE0, 0x90, 0xE0, # B
     0xF0, 0x80, 0x80, 0x80, 0xF0, # C
     0xE0, 0x90, 0x90, 0x90, 0xE0, # D
     0xF0, 0x80, 0xF0, 0x80, 0xF0, # E
     0xF0, 0x80, 0xF0, 0x80, 0x80  # F
    ].each_with_index { |b, i| @memory[0x50 + i] = b }
    0.upto(0xF) { |n| @symbol[n] = 0x50 + n * 5 }
  end

  def vf
    @register[15]
  end

  def vf=(arg)
    @register[15] = arg
  end

  def set pgm, start=0x200
    addr = start
    pgm.each do |op|
      a = (op & 0xff00) >> 8 # Read first byte, shift right to treat as 1 byte
      b = op & 0x00ff        # Read second byte
      @memory[addr] = a
      @memory[addr+1] = b
      addr += 2
    end
    @pc = start
  end

  def tick keyboard
    @keydown = keyboard.current
    if @keycapture == true
      @register[@keytarget] = @keydown
      return
    end

    if @delay > 0
      @delay -=1
    end
    if @sound > 0
      @sound -=1
    end

    @ticks_per_frame.times do
      debug_msg = step
      if @debug
        puts(debug_msg)
      end
    end
  end

  def step
    p = @pc
    op = fetch
    debug_msg = ""
    if @debug
      debug_msg += "#{p.to_s(16).rjust(4,"0")}: #{op}\n"
    end
    (debug_msg + decode(op))
  end

  def rv_decode rest
    reg = (rest & 0xf00) >> 8
    val = (rest & 0x0ff)
    [reg, val]
  end

  def rxry_decode rest
    regx = (rest & 0xf00) >> 8
    regy = (rest & 0x0f0) >> 4
    [regx, regy]
  end

  def fetch
    op1 = @memory[@pc] #readbyte(@pc)
    op2 = @memory[@pc +1] #readbyte(@pc + 1)
    @pc = (@pc + 2) & 4095
    ((op1 << 8) + op2)
  end

  def decode opcode
    debug_msg = ""
    op = (opcode & 0xf000) >> 12
    rest = (opcode & 0x0fff)
    opcode = opcode.to_s(16).rjust(4,'0')
    case op

    when 0x0
      if rest == 0 # SYS NNN: Call System Routine NNN
      # Execute Call Statment
      elsif rest == 0x0e0 # CLS: Clear Screen
        debug_msg += "Clearing Screen\n"
        @display.clear()
      elsif rest == 0x0ee # RTN: Return from Subroutine
        @pc = @stack[@sp]
        @sp -= 1
        debug_msg += "Return to #{@pc}\n"
      end

    when 0x1 # JMP NNN: Jump to address NNN
      address = rest
      debug_msg += "JMP To #{address.to_s(16).rjust(4, "0")}\n"
      @pc = address

    when 0x2 # CALL NNN: Go to subroutine at address NNN
      @sp += 1
      @stack[@sp] = @pc
      address = rest
      @pc = address
      debug_msg += "CALL #{address}\n"

    when 0x3 # SE Vx, kk: Skip Next If Register X Equals Value KK
      reg, val = rv_decode(rest)
      if @register[reg] == val
        @pc += 2
      end
      debug_msg += "SE Vx #{@register[reg]} == #{val}\n"

    when 0x4 # SNE Vx, kk: kip Next If Register X Not Equals Value KK
      reg, val = rv_decode(rest)
      if @register[reg] != val
        @pc += 2
      end
      debug_msg += "SNE Vx #{@register[reg]} != #{val}\n"

    when 0x5 # SE Vx, Vy: Skip Next If Register X Equals Register Y
      regx, regy = rxry_decode(rest)
      if @register[regx] == @register[regy]
        @pc += 2
      end
      debug_msg += "SE Vx #{@register[regx]} == Vy#{@register[regy]}\n"

    when 0x6 # LD Vx, kk: Load Value kk into Register X
      reg, val = rv_decode(rest)
      debug_msg += "LD V#{reg} = 0x#{opcode[2,2]} : #{val}\n"
      @register[reg] = val

    when 0x7 # ADD Vx, kk: Add KK to Register X, store in Register X
      reg, val = rv_decode(rest)
      if @register[reg] + val > 255
        val -= 256
        @register[15] = 1
      end
      @register[reg] += val
      debug_msg += "ADD V#{reg}, #{val}\n"

    when 0x8 # Register X,Y functions
      regx, regy = rxry_decode(rest)
      operation = rest & 0x00f
      case operation

      when 0x0 # LD Vx, Vy: Load Value from Register Y into Register X
        debug_msg += "LD V#{regx}, V#{regy} (#{@register[regy]})\n"
        @register[regx] = @register[regy]

      when 0x1 # OR Vx, Vy: Register X OR Register Y, store in Register X
        debug_msg += "OR V#{regx} (#{@register[regx]}), V#{regy} (#{@register[regy]}): #{@register[regx] | @register[regy]}\n"
        @register[regx] = @register[regx] | @register[regy]

      when 0x2 # AND Vx, Vy: Register X AND Register Y, store in Register X
        debug_msg += "AND V#{regx} (#{@register[regx]}), V#{regy} (#{@register[regy]}): #{@register[regx] & @register[regy]}\n"
        @register[regx] = @register[regx] & @register[regy]

      when 0x3 # XOR Vx, Vy: Register X XOR Register Y, store in Register X
        debug_msg += "XOR V#{regx} (#{@register[regx]}), V#{regy} (#{@register[regy]}): #{@register[regx] ^ @register[regy]}\n"
        @register[regx] = @register[regx] ^ @register[regy]

      when 0x4 # ADD Vx, Vy: Register X XOR Register Y, store in Register X, Carry in Vf
        debug_msg += "ADD V#{regx} (#{@register[regx]}), V#{regy} (#{@register[regy]}): #{@register[regx] + @register[regy]}\n"
        sum = @register[regx] + @register[regy]
        @register[15] = sum > 0xFF ? 1 : 0
        @register[regx] = sum & 0xFF

      when 0x5 # SUB Vx, Vy: Register X - Register Y, store in Register X
        debug_msg += "SUB V#{regx} (#{@register[regx]}), V#{regy} (#{@register[regy]}): #{@register[regx] - @register[regy]}\n"
        sum = @register[regx] + @register[regy]
        @register[15] = sum > 0xFF ? 1 : 0
        @register[regx] = sum & 0xFF

      when 0x6 # SHR Vx, {Vy}: If Register X is odd, VF = 1.  Register X = Register X /2
        debug_msg += "SHR V#{regx} (#{@register[regx]})\n"
        @register[15] = @register[regx] & 1
        @register[regx] = @register[regx] / 2

      when 0x7 # SUBN Vx, Vy: Register Y - Register X, store in Register X
        debug_msg += "SUBN  V#{regy} (#{@register[regx]}), V#{regy} (#{@register[regy]}): #{@register[regy] - @register[regx]}\n"
        sum = @register[regx] + @register[regy]
        @register[15] = sum > 0xFF ? 1 : 0
        @register[regx] = sum & 0xFF

      when 0xe # SHL Vx, {Vy}: If Regester X MSB It Set, VF = 1.  Register X = Register X*2
        debug_msg += "SHL V#{regx} (#{@register[regx]})\n"
        @register[15] = @register[regx] & 128
        @register[regx] = @register[regx] * 2
      end

    when 0x9 # SNE Vx, Vy: Skip Next If Register X Not Equal To Register Y
      regx, regy = rxry_decode(rest)
      if @register[regx] != @register[regy]
        @pc += 2
      end
      debug_msg += "SNE V#{regx} (#{@register[regx]}), V#{regy} (#{@register[regy]})\n"

    when 0xa # LD I, Addr: Load value Addr into Register I
      @i = rest
      debug_msg += "LD I,  #{@i.to_s(16).rjust(4, "0")}\n"

    when 0xb # JMP V0 NNN: Jump to address V0 + NNN
      address = rest
      @pc = address + @register[0]

    when 0xc # RND byte AND kk: Set Register X to a Random number (0-255) and AND with KK
      regx, const = rv_decode(rest)
      byte = rand(256) & const
      @register[regx] = byte
      debug_msg += "RND and #{const} (#{byte.to_s(16).rjust(4, "0")}\n"

    when 0xd # DRW Vx, Vy, N: Draw an N-byte Sprite from memory location stored in I at
      # Coordinate: Vx, Vy
      regx, regy = rxry_decode(rest)

      n = (rest & 0x00f)
      sprite = []
      (0...n).each do |offset|
        sprite << @memory[@i + offset]
      end
      debug_msg += "DRW V#{regx}, V#{regy}, #{n}: (#{@register[regx]}, #{@register[regy]}), #{@i.to_s(16).rjust(4, "0")})\n"
      if @display.writesprite(@register[regx], @register[regy], sprite, 0)
        @register[15] = 1
      else
        @register[15] = 0
      end

    when 0xe # Keyboard Commands
      regx = (rest & 0xf00) >> 8
      operation = rest & 0x0ff
      case operation
      when 0x9e # SKP Vx: Skip next operation if Key Vx is held
        if @keydown == @register[regx]
          @pc += 2
        end
      when 0xa1 # SKNP Vx: Skip next operation if Key Vx is not held
        if @keydown != @register[regx]
          @pc += 2
        end
      end

    when 0xf # Timer Commands
      regx = (rest & 0xf00) >> 8
      operation = rest & 0x0ff
      if @debug
        puts(operation.to_s(16))
        puts(@i.to_s(16))
        puts(regx.to_s(16))
        puts(@register[regx].to_s(16))
      end
      case operation
      when 0x07 # LD Vx, DT: Load the value from the Delay Timer into  Register X
        @register[regx] = @delay
      when 0x0a # LD Vx, K: Load pressed key into Register X
        @keycapture = true
        @keytarget = regx
      when 0x15 # LD DS, Vx: Load the value from Register X into the Delay Timer
        @delay = @register[regx]
      when 0x18 # LD ST, Vx: Load the value from Register X into the Sound Timer
        @sound = @register[regx]
      when 0x1e # Add I, Vx: Add the value from Register X to the value in I. Store in I
        # if @i + @register[regx] > 255
        #   @i -= 255
        #   @register[15] = 1
        # end
        @i += @register[regx]
      when 0x29 # LD F, Vx: Load address of sprite for value Vx into I
        @i = @symbol[@register[regx]]
      when 0x33 # LD B, Vx: Load the BCD Representation of value in Register X into memory
        val = @register[regx].to_s(10).rjust(3, "0")
        @memory[@i] = val[0].to_i(10)
        @memory[@i+1] = val[1].to_i(10)
        @memory[@i+2] = val[2].to_i(10)
      when 0x55 # LD [I], Vx: Store the values in Registers 0 through X in memory
        (0..regx).each do |reg|
          @memory[@i + reg] = @register[reg]
        end
      when 0x65 # LD Vx, [I]: Load the values from I..I+x into Registers 0 to X
        (0..regx).each do |reg|
          @register[reg] = @memory[@i + reg]
        end
      end
    end
    debug_msg
  end

  def serialize
    {
      debug: debug,
      ticks_per_frame: ticks_per_frame,
      register: register,
      i: i, pc: pc,
      memory: memory,
      sp: sp,
      stack: stack,
      delay: delay,
      sound: sound
    }
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end
end
