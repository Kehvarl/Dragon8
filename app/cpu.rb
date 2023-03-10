class CPU
  attr_accessor :debug, :ticks_per_frame, :register, :i, :pc, :memory, :sp, :stack, :delay, :sound
  def initialize display
    @debug = false
    @ticks_per_frame = 1
    @display = display
    @register = []
    @i = 0
    @pc = 0
    @memory = []
    (0..4096).each do
      @memory << 0      
    end
    @sp = 0
    @stack = []
    (0..48).each do
      @stack << 0
    end
    @symbol = {}
    @delay = 0
    @sound = 0
    @keydown = nil
    @keycapture = false
    @keytarget = 0
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
      a = op[0,2]
      b = op[2,2]
      @memory[addr] = a.to_i(16)
      @memory[addr+1] = b.to_i(16)
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
    
    (0..@ticks_per_frame).each do
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

  def readbyte address
    @memory[address].to_s(16).rjust(2,"0")
  end

  def readregister reg
    @register[reg].to_s(16).rjust(2, "0")
  end

  def fetch
    opcode = readbyte(@pc) + readbyte(@pc + 1)
    @pc += 2
    if @pc > 4096
      @pc = 0
    end
    opcode
  end

  def decode opcode
    debug_msg = ""
    op = opcode[0]
    case op
    when "0"
      if opcode[1] != "0" # SYS NNN: Call System Routine NNN
      # Execute Call Statment
      elsif opcode == "00e0" # CLS: Clear Screen
        debug_msg += "Clearing Screen\n"
        @display.clear()
      elsif opcode == "00ee" # RTN: Return from Subroutine
        @pc = @stack[@sp]
        @sp -= 1
        debug_msg += "Return to #{@pc}\n"
      end
    when "1" # JMP NNN: Jump to address NNN
      address = opcode[1,3].to_i(16)
      debug_msg += "JMP To #{address.to_s(16).rjust(4, "0")}\n"
      @pc = address
    when "2" # CALL NNN: Go to subroutine at address NNN
      @sp += 1
      @stack[@sp] = @pc
      address = opcode[1,3].to_i(16)
      @pc = address
      debug_msg ++ "CALL #{address}\n"
    when "3" # SE Vx, kk: Skip Next If Register X Equals Value KK
      reg = opcode[1,1].to_i(16)
      val = opcode[2,2].to_i(16)
      if @register[reg] == val
        @pc += 2
      end
      debug_msg += "SE Vx #{@register[reg]} == #{val}\n"
    when "4" # SNE Vx, kk: kip Next If Register X Not Equals Value KK
      reg = opcode[1,1].to_i(16)
      val = opcode[2,2].to_i(16)
      if @register[reg] != val
        @pc += 2
      end
      debug_msg += "SNE Vx #{@register[reg]} != @{val}\n"
    when "5" # SE Vx, Vy: Skip Next If Register X Equals Register Y
      regx = opcode[1,1].to_i(16)
      regy = opcode[2,1].to_i(16)
      if @register[regx] == @register[regy]
        @pc += 2
      end
      debug_msg += "SE Vx #{@register[regx]} == Vy#{@register[regy]}\n"
    when "6" # LD Vx, kk: Load Value kk into Register X
      reg = opcode[1,1].to_i(16)
      val = opcode[2,2].to_i(16)
      debug_msg += "LD V#{reg} = 0x#{opcode[2,2]} : #{val}\n"
      @register[reg] = val
    when "7" # ADD Vx, kk: Add KK to Register X, store in Register X
      reg = opcode[1,1].to_i(16)
      val = opcode[2,2].to_i(16)
      if @register[reg] + val > 255
        val -= 255
        @register[15] = 1
      end
      @register[reg] += val
      debug_msg += "ADD V#{reg}, #{val}\n"
    when "8" # Register X,Y functions
      regx = opcode[1,1].to_i(16)
      regy = opcode[2,1].to_i(16)
      operation = opcode[3,1].to_i
      case operation
      when "0" # LD Vx, Vy: Load Value from Register Y into Register X
        debug_msg += "LD V#{regx}, V#{regy} (#{@register[regy]})\n"
        @register[regx] = @register[regy]
      when "1" # OR Vx, Vy: Register X OR Register Y, store in Register X
        debug_msg += "OR V#{regx} (#{@register[regx]}), V#{regy} (#{@register[regy]}): #{@register[regx] | @register[regy]}\n"
        @register[regx] = @register[regx] | @register[regy]        
      when "2" # AND Vx, Vy: Register X AND Register Y, store in Register X
        debug_msg += "AND V#{regx} (#{@register[regx]}), V#{regy} (#{@register[regy]}): #{@register[regx] & @register[regy]}\n"
        @register[regx] = @register[regx] & @register[regy]        
      when "3" # XOR Vx, Vy: Register X XOR Register Y, store in Register X
        debug_msg += "XOR V#{regx} (#{@register[regx]}), V#{regy} (#{@register[regy]}): #{@register[regx] ^ @register[regy]}\n"
        @register[regx] = @register[regx] ^ @register[regy]
      when "4" # ADD Vx, Vy: Register X XOR Register Y, store in Register X, Carry in Vf
        debug_msg += "ADD V#{regx} (#{@register[regx]}), V#{regy} (#{@register[regy]}): #{@register[regx] + @register[regy]}\n"
        sum = @register[regx] + @register[regy]
        if sum > 255
          sum -= 255
          @register[15] = 1
        end
        @register[regx] = sum
      when "5" # SUB Vx, Vy: Register X - Register Y, store in Register X
        debug_msg += "SUB V#{regx} (#{@register[regx]}), V#{regy} (#{@register[regy]}): #{@register[regx] - @register[regy]}\n"
        if @register[regx] > @register[regy]
          @register[15] = 1
        else
          @register[15] = 0
          @register[regx] += 256
        end
        @register[regx] = @register[regx] - @register[regy]
      when "6" # SHR Vx, {Vy}: If Register X is odd, VF = 1.  Register X = Register X /2
        debug_msg += "SHR V#{regx} (#{@register[regx]})\n"
        @register[15] = @register[regx] & 1
        @register[regx] = @register[regx] / 2
      when "7" # SUBN Vx, Vy: Register Y - Register X, store in Register X
        debug_msg += "SUBN  V#{regy} (#{@register[regx]}), V#{regy} (#{@register[regy]}): #{@register[regy] - @register[regx]}\n"
        if @register[regy] > @register[regx]
          @register[15] = 1
        else
          @register[15] = 0
          @register[regy] += 256
        end
        @register[regx] = @register[regy] - @register[regx]
      when "e" # SHL Vx, {Vy}: If Regester X MSB It Set, VF = 1.  Register X = Register X*2
        debug_msg ++ "SHL V#{regx} (#{@register[regx]})\n"
        @register[15] = @register[regx] & 128
        @register[regx] = @register[regx] * 2        
      end
    when "9" # SNE Vx, Vy: Skip Next If Register X Not Equal To Register Y
      regx = opcode[1,1].to_i(16)
      regy = opcode[2,1].to_i(16)
      if @register[regx] != @register[regy]
        @pc += 2
      end
      debug_msg += "SNE V#{regx} (#{@register[regx]}), V#{regy} (#{@register[regy]})\n"
    when "a" # LD I, Addr: Load value Addr into Register I
      @i = opcode[1,3].to_i(16)
      debug_msg += "LD I,  #{@i.to_s(16).rjust(4, "0")}\n"
    when "b" # JMP V0 NNN: Jump to address V0 + NNN
      address = opcode[1,3].to_i(16)
      @pc = address + @register[0]
    when "c" # RND byte AND kk: Set Register X to a Random number (0-255) and AND with KK
      regx = opcode[1,1].to_i(16)
      const = opcode[2,2].to_i(16)
      byte = rand(256) & const
      @register[regx] = byte
      debug_msg += "RND and #{const} (#{byte.to_s(16).rjust(4, "0")}\n"
    when "d" # DRW Vx, Vy, N: Draw an N-byte Sprite from memory location stored in I at
      # Coordinate: Vx, Vy
      regx = opcode[1,1].to_i(16)
      regy = opcode[2,1].to_i(16)
      n    = opcode[3,1].to_i(16) -1
      sprite = []
      (0..n).each do |offset| 
        sprite << readbyte(@i + offset).to_i(16)
      end
      debug_msg += "DRW V#{regx}, V#{regy}, #{n}: (#{@register[regx]}, #{@register[regy]}), #{@i.to_s(16).rjust(4, "0")})\n"
      if @display.writesprite(@register[regx], @register[regy], sprite, 0)
        @register[15] = 1
      else
        @register[15] = 0
      end
    when "e" # Keyboard Commands
      regx = opcode[1,1].to_i(16)
      operation = opcode[2,2]
      case operation
      when "9e" # SKP Vx: Skip next operation if Key Vx is held
        if @keydown == @register[regx]
          @pc += 2
        end
      when "a1" # SKNP Vx: Skip next operation if Key Vx is not held
        if @keydown != @register[regx]
          @pc += 2
        end
      end
    when "f" # Timer Commands
      regx = opcode[1,1].to_i(16)
      operation = opcode[2,2]
      case operation
      when "07" # LD Vx, DT: Load the value from the Delay Timer into  Register X
        @register[regx] = @delay
      when "0a" # LD Vx, K: Load pressed key into Register X
        @keycapture = true
        @keytarget = regx
      when "15" # LD DS, Vx: Load the value from Register X into the Delay Timer
        @delay = @register[regx]
      when "18" # LD ST, Vx: Load the value from Register X into the Sound Timer
        @sound = @register[regx]
      when "1e" # Add I, Vx: Add the value from Register X to the value in I. Store in I
        if @i + @register[regx] > 255
          @i -= 255
          @register[15] = 1
        end
        @i += @register[regx]
      when "29" # LD F, Vx: Load address of sprite for value Vx into I
        @i = @symbol[@register[regx]]
      when "33" # LD B, Vx: Load the BCD Representation of value in Register X into memory
        val = @resgister[regx].to_s(10).rjust(2, "0")
        @memory[@i] = val[0].to_i(10)
        @memory[@i+1] = val[1].to_i(10)
        @memory[@i+2] = val[2].to_i(10)
      when "55" # LD [I], Vx: Store the values in Registers 0 through X in memory
        (0..regx).each do |reg|
          @memory[@i + reg] = @register[reg]
        end
      when "65" # LD Vx, [I]: Load the values from I..I+x into Registers 0 to X
        (0..regx).each do |reg|
          @register[reg] = @memory[@i + reg]
        end        
      end
    end
    debug_msg
  end
end
