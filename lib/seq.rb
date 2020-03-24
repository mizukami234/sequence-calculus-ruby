require 'prop'
require 'tree'

class Seq
  attr_reader :left, :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def eval_bool(assign)
    !left.all? { |p| p.eval_bool(assign) } || right.any? { |p| p.eval_bool(assign) }
  end

  def resolve_tree
    if (index = right.index { |p| p.type === :and })
      # 1a
      prop = right[index]
      r1 = right.clone
      r2 = right.clone
      r1[index] = prop.left
      r2[index] = prop.right
      Tree.new(self, 'and-R', self.class.new(left, r1).resolve_tree, self.class.new(left, r2).resolve_tree)
    elsif (index = left.index { |p| p.type === :and })
      # 1b
      prop = left[index]
      l = left.clone
      l.slice! index
      l.insert index, prop.left, prop.right
      Tree.new(self, 'and-L', self.class.new(l, right).resolve_tree)
    elsif (index = right.index { |p| p.type === :or })
      # 2a
      prop = right[index]
      r = right.clone
      r.slice! index
      r.insert index, prop.left, prop.right
      Tree.new(self, 'or-R', self.class.new(left, r).resolve_tree)
    elsif (index = left.index { |p| p.type === :or })
      # 2b
      prop = left[index]
      l1 = left.clone
      l2 = left.clone
      l1[index] = prop.left
      l2[index] = prop.right
      Tree.new(self, 'or-L', self.class.new(l1, right).resolve_tree, self.class.new(l2, right).resolve_tree)
    elsif (index = right.index { |p| p.type === :imply })
      # 3a
      prop = right[index]
      l = left.clone
      r = right.clone
      l.unshift prop.left
      r[index] = prop.right
      Tree.new(self, 'imp-R', self.class.new(l, r).resolve_tree)
    elsif (index = left.index { |p| p.type === :imply })
      # 3b
      prop = left[index]
      l1 = left.clone
      r1 = right.clone
      l1.slice! index
      r1.push prop.left
      l2 = left.clone
      l2[index] = prop.right
      Tree.new(self, 'imp-L', self.class.new(l1, r1).resolve_tree, self.class.new(l2, right).resolve_tree)
    elsif (index = right.index { |p| p.type === :not })
      # 4a
      prop = right[index]
      l = left.clone
      r = right.clone
      l.unshift prop.inner
      r.slice! index
      Tree.new(self, 'not-R', self.class.new(l, r).resolve_tree)
    elsif (index = left.index { |p| p.type === :not })
      # 4b
      prop = left[index]
      l = left.clone
      r = right.clone
      l.slice! index
      r.push prop.inner
      Tree.new(self, 'not-L', self.class.new(l, r).resolve_tree)
    else
      Tree.new(self, nil)
    end
  end

  def valid?
    resolve_tree.valid?
  end

  def str_valid?
    left_strs = left.map(&:str).uniq.to_set
    right.any? do |r|
      left_strs.member? r.str
    end
  end  

  def to_s
    "#{left.map(&:to_s).join(', ')} => #{right.map(&:to_s).join(', ')}"
  end
end
