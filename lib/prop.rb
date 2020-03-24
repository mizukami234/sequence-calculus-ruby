class Prop
  attr_reader :type, :str, :left, :right, :inner

  def initialize(type, str: nil, left: nil, right: nil, inner: nil)
    @type = type
    @str = str
    @left = left
    @right = right
    @inner = inner
  end

  def eval_bool(assign = {})
    case @type
    when :str
      assign.fetch(str)
    when :and
      left.eval_bool(assign) && right.eval_bool(assign)
    when :or
      left.eval_bool(assign) || right.eval_bool(assign)
    when :imply
      !left.eval_bool(assign) || right.eval_bool(assign)
    when :not
      !inner.eval_bool(assign)
    end
  end

  def to_s(p1 = 0)
    s, p2 =
      case @type
      when :str
        [str, 4]
      when :and
        lstr = left.to_s(3)
        rstr = right.to_s(3)
        ["#{lstr} ∧ #{rstr}", 3]
      when :or
        lstr = left.to_s(2)
        rstr = right.to_s(2)
        ["#{lstr} ∨ #{rstr}", 2]
      when :imply
        lstr = left.to_s(1)
        rstr = right.to_s(1)
        ["#{lstr} → #{rstr}", 1]
      when :not
        instr = inner.to_s(4)
        ["¬#{instr}", 4]
      end
    if p2 < p1
      "(#{s})"
    else
      s
    end
  end

  class << self
    def str(str)
      new(:str, str: str)
    end

    def and(left, right)
      new(:and, left: left, right: right)
    end

    def or(left, right)
      new(:or, left: left, right: right)
    end

    def imply(left, right)
      new(:imply, left: left, right: right)
    end

    def not(inner)
      new(:not, inner: inner)
    end
  end
end
