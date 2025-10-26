class Keyboard
  attr_accessor :current, :buffer
  def initialize
    @current = nil
    @buffer = []
    @allowed_keys = [
      '0', '1', '2', '3', '4', '5', '6', '7',
      '8','9', 'A', 'B', 'C', 'D', 'E', 'F']
  end

  def tick args
    if args.inputs.keyboard.key_down.char
      keydown args.inputs.keyboard.key_down.char.upcase
    elsif args.inputs.keyboard.key_up
      keyup @current
    end
  end

  def keydown key
    if @allowed_keys.include?(key)
      @current = key
    end
  end

  def keyup key
    if @allowed_keys.include?(key)
      @current = nil
      @buffer << key
    end
  end

  def clear
    @buffer = []    
  end
  
end
