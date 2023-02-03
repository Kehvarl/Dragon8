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
      if opcode[1] != "0"
        # Execute Call Statment
      elsif opcode = "00E0"
        @display.clear()
      elsif opcode = "00EE"
        # Return from subroutine
      end
    end
  end
  
end
