class cpu
  def initialize args=nil
    @register = []
    @i = 0
    @pc = 0
    @ram = []
  end

  def vf
    @register[15]    
  end

  def vf=(arg)
    @register[15] = arg
  end
  
end
