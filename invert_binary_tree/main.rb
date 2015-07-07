#!/Users/yangtheman/.rvm/rubies/ruby-2.1.2/bin/ruby
require 'awesome_print'
require_relative 'invert_binary_tree'

node1 = Node.new(value: '1')
node3 = Node.new(value: '3')
node2 = Node.new(value: '2', left: node1, right: node3)
node6 = Node.new(value: '6')
node9 = Node.new(value: '9')
node7 = Node.new(value: '7', left: node6, right: node9)
node4 = Node.new(value: '4', left: node2, right: node7)

InvertBinaryTree.print_nodes(node4)
inverted = InvertBinaryTree.invert(node4)
puts "@"*30
InvertBinaryTree.print_nodes(inverted)
