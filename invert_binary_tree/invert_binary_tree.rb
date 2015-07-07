class Node

  attr_reader :value
  attr_accessor :left, :right

  def initialize(opts={})
    @left = opts[:left]
    @right = opts[:right]
    @value = opts[:value]
  end

  def leaf_node?
    right == nil && left == nil
  end

end


class InvertBinaryTree

  def self.invert(tree)
    inverted = Node.new(value: tree.value)
    invert_branches(tree, inverted)
    inverted
  end

  def self.invert_branches(tree, inverted)
    
    inverted.left = Node.new(value: tree.right.value)
    inverted.right = Node.new(value: tree.left.value)

    return if tree.right.leaf_node? || tree.left.leaf_node?

    invert_branches(tree.right, inverted.left)
    invert_branches(tree.left, inverted.right)
  end

  def self.print_nodes(tree)
    puts tree.value

    print_nodes(tree.left) if tree.left
    print_nodes(tree.right) if tree.right
  end

end
