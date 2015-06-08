#!/Users/yangtheman/.rvm/rubies/ruby-2.1.2/bin/ruby

class Node

  attr_reader :animal

  def initialize(animal: 'elephant')
    @animal = animal
    @question = nil
    @answer = nil
    @answer_node = nil
    @default_node = nil
  end

  def get_question
    @question || "Is it #{animal}?"
  end

  def next_node(answer)
    return nil if @question.nil?
    if answer == @answer
      @answer_node
    else
      @default_node
    end
  end

  def add_new_node(answer, question, new_animal)
    @question = question
    @answer = answer

    @default_node = Node.new(animal: animal)
    @answer_node = Node.new(animal: new_animal)
  end
end

class Game

  def initialize(node)
    @init_node = node
    @node = node
  end

  def get_question
    @node.get_question
  end

  def learn(node)
    puts "You win.  Help me learn from my mistake before you go..."
    puts "What animal were you thinking of?"
    new_animal = gets.chomp
    puts "Give me a question to distinguish #{new_animal} from #{node.animal}."
    question = gets.chomp
    puts "For #{new_animal}, what is the answer to your question?  (yes or no)?"
    answer = gets.chomp
    puts "Thanks."

    node.add_new_node(answer, question, new_animal)
  end

  def play
    puts "Think of an animal."

    while @node
      puts get_question
      answer = gets.chomp
      prev_node = @node
      @node = @node.next_node(answer)
    end

    if answer == 'y'
      puts "I win.  Pretty smart, aren't I?"
    else
      learn(prev_node)
    end

    ask_to_play_again
  end

  def ask_to_play_again
    puts "Play again?  (y or n)"
    play_again = gets.chomp
    if play_again == 'y'
      @node = @init_node
      play
    end
  end

end

Game.new(Node.new).play
