class cpu
  def initialize display
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
  end

  def vf
    @register[15]    
  end

  def vf=(arg)
    @register[15] = arg
  end

  def step
    
  end

  def readbyte address
    @memory[address].to_s(16).rjust(2,"0")
  end

  def fetch
    opcode = readbyte(@pc) + readbyte(@pc + 1)
    @pc += 2
  end

  def decode opcode
    op = opcode[0]
    case op
    when "0"
      if opcode[1] != "0" # SYS NNN: Call System Routine NNN
      # Execute Call Statment
      elsif opcode = "00E0" # CLS: Clear Screen
        @display.clear()
      elsif opcode = "00EE" # RTN: Return from Subroutine
        @pc = @stack[@sp]
        @sp -= 1
      end
    when "1" # JMP NNN: Jump to address NNN
      address = opcode[1,3].to_i
      @pc = address
    when "2" # CALL NNN: Go to subroutine at address NNN
      @sp += 1
      @stack[@sp] = @pc
      address = opcode[1,3].to_i
      @pc = address
    when "3" # SE Vx, kk: Skip Next If Register X Equals Value KK
      reg = opcode[1,1].to_i
      val = opcode[2,2].to_i
      if @register[reg] == val
        @pc += 2
      end
    when "4" # SNE Vx, kk: kip Next If Register X Not Equals Value KK
      reg = opcode[1,1].to_i
      val = opcode[2,2].to_i
      if @register[reg] != val
        @pc += 2
      end
    when "5" # SE Vx, Vy: Skip Next If Register X Equals Register Y
      regx = opcode[1,1].to_i
      regy = opcode[2,1]/to_i
      if @register[regx] == @register[regy]
        @pc += 2
      end
    when "6" # LD Vx, kk: Load Value kk into Register X
      reg = opcode[1,1].to_i
      val = opcode[2,2].to_i
      if @register[reg] != val
        @pc += 2
      end        
    end
  end
  
end
