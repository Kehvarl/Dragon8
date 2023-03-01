class Keyboard
  attr_accessor :current, :buffer
  def initialize
    @current = nil
    @buffer = []    
  end

  def keypdown key
    @current = key
  end

  def keyup key
    @current = nil
    @buffer << key
  end

  def clear
    @buffer = []    
  end
  
end
