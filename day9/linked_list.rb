class LinkedList
  def initialize
    @cursor = nil
  end

  def insert(value)
    new_el = LinkedListElement.new(value)
    if @cursor.nil?
      insert_first_element new_el
    else
      insert_additional_element new_el
    end
  end

  def insert_first_element(element)
    @cursor = element
    @cursor.next_element = @cursor
    @cursor.prev_element = @cursor
  end

  def insert_additional_element(e)
    e.next_element = @cursor
    e.prev_element = @cursor.prev_element
    e.prev_element.next_element = e
    e.next_element.prev_element = e
    @cursor = e
  end

  def remove
    return nil unless @cursor

    removed = @cursor.value

    if @cursor.next_element == @cursor
      @cursor = nil
    else
      @cursor.prev_element.next_element = @cursor.next_element
      @cursor.next_element.prev_element = @cursor.prev_element
      @cursor = @cursor.next_element
    end

    return removed
  end

  def rotate_forward(n)
    n.times do
      @cursor = @cursor.next_element
    end
  end

  def rotate_backward(n)
    n.times do
      @cursor = @cursor.prev_element
    end
  end

  def debug
    x = @cursor
    loop do
      print x.value
      print ' '
      x = x.next_element
      break if x == @cursor
    end
  end
end

private

class LinkedListElement
  attr_reader :value
  attr_accessor :next_element
  attr_accessor :prev_element

  def initialize(value)
    @value = value
  end
end
