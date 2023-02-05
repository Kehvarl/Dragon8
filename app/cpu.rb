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
      if opcode[1] != "0"
      # Execute Call Statment
      elsif opcode = "00E0"
        @display.clear()
      elsif opcode = "00EE"
        @pc = @stack[@sp]
        @sp -= 1
      end
    when "1" # Jump
      address = opcode[1,3].to_i
      @pc = address
    when "2" # Call
      @sp += 1
      @stack[@sp] = @pc
      address = opcode[1,3].to_i
      @pc = address
    when "3" # Skip Next If Register Equals
      reg = opcode[1,1].to_i
      val = opcode[2,2].to_i
      if @register[reg] == val
        @pc += 2
      end
    end
  end
  
end
