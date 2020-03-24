class Tree
  attr_reader :goal, :rule, :subtrees

  def initialize(goal, rule, *subtrees)
    @goal = goal
    @rule = rule
    @subtrees = subtrees
  end

  def edges
    if subtrees.size == 0
      [goal]
    else
      subtrees.map(&:edges).flatten(1)
    end
  end

  def valid?
    edges.all? { |seq| seq.str_valid? }
  end

  def to_s(label = nil)
    subtree_strs =
      subtrees.each_with_index.map do |tree, index|
        tree.to_s(label ? "#{label}-#{index + 1}" : "#{index + 1}")
      end
    goal_str = "#{goal.to_s}".ljust(30)
    if rule
      goal_str += " by #{rule}".ljust(10)
    else
      goal_str += " is #{valid? ? 'true' : 'false'}".ljust(10)
    end
    goal_str += " [#{label || 'Goal'}]"
    (subtree_strs + [goal_str]).join("\n")
  end
end
