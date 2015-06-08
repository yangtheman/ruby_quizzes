#!/Users/yangtheman/.rvm/rubies/ruby-2.1.2/bin/ruby

class Entity

  attr_reader :name, :relationships

  def initialize(name)
    @name = name
    @relationships = {}
  end

  def create_relationship(kind, entity)
    @relationships[kind] = entity
  end

  def other_with_relationship(kind)
    @relationships[kind]
  end

  def has_relationship?(kind, entity)
    @relationships[kind] == entity
  end

  def belongs_to_kind?(entity, kind, any=nil)
    parent_entity = @relationships[kind]
    return false if parent_entity.nil?
    if any
      parent_entity == entity ? true : parent_entity.belongs_to?(entity)
    else
      parent_entity == entity ? true : parent_entity.belongs_to?(entity, kind)
    end
  end

  def belongs_to?(entity, kind=nil)
    if kind
      belongs_to_kind?(entity, kind)
    else
      belongs_to_kind?(entity, 'all', true) || belongs_to_kind?(entity, 'some', true)
    end
  end

  def member_of_kind?(entity, kind)
    child_entity = entity.relationships[kind]
    return false if child_entity.nil?
    child_entity == self ? true : child_entity.member_of?(entity)
  end

  def member_of?(entity)
    member_of_kind?(entity, 'all') || member_of_kind?(entity, 'some')
  end

end

class Entities

  attr_reader :all

  def initialize
    @all = {}
  end

  def create_entity(kind:, subject:, noun:)
    return "I know." if does_subject_belong_to_noun?(subject, noun, kind)
    return "Sorry, that contradicts what I already know." if does_subject_belong_to_noun?(noun, subject, kind)

    subject_entity = find_or_create_entity(subject)
    noun_entity = find_or_create_entity(noun)

    subject_entity.create_relationship(kind, noun_entity)

    return "OK."
  end

  def answer_entity(kind:, subject:, noun:)
    return "I do not know anything about #{subject}" unless find_entity(subject)

    answer = "I do not know"

    if kind == 'all' || kind == 'some' || kind == 'no'
      if does_subject_belong_to_noun?(subject, noun, kind)
        answer = "Yes, #{kind} #{subject} are #{noun}."
      elsif does_subject_belong_to_noun?(subject, noun, 'no')
        answer = "No, not all #{subject} are #{noun}."
      end
    elsif kind == 'any'
      if does_subject_belong_to_noun?(subject, noun) || is_subject_member_of_noun?(subject, noun)
        answer = "Yes, some #{subject} are #{noun}"
      else
      end
    end

    answer
  end

  def describe_entity(subject:)
    entity = find_entity(subject)
    other_entity_names = all.keys - [subject]

    other_entity_names.inject([]) do |descriptions, noun|
      answer = if does_subject_belong_to_noun?(subject, noun, 'all')
        "All #{subject} are #{noun}"
      elsif does_subject_belong_to_noun?(subject, noun, 'some')
        "Some #{subject} are #{noun}"
      elsif does_subject_belong_to_noun?(subject, noun)
        "Some #{subject} are #{noun}"
      elsif does_subject_belong_to_noun?(noun, subject, 'no')
        "No #{subject} are #{noun}"
      elsif is_subject_member_of_noun?(subject, noun)
        "Some #{subject} are #{noun}"
      end
      descriptions << answer
    end
  end

  private

  def does_subject_belong_to_noun?(subject, noun, kind=nil)
    subject_entity = find_entity(subject)
    noun_entity = find_entity(noun)
    if subject_entity && noun_entity
      subject_entity.belongs_to?(noun_entity, kind)
    else
      false
    end
  end

  def is_subject_member_of_noun?(subject, noun)
    subject_entity = find_entity(subject)
    noun_entity = find_entity(noun)
    if subject_entity && noun_entity
      subject_entity.member_of?(noun_entity)
    else
      false
    end
  end

  def find_or_create_entity(key)
    find_entity(key) || all[key] = Entity.new(key)
  end

  def find_entity(key)
    all[key]
  end

end

class Question

  DEFAULT_ANSWER = "Illegal format of question."

  attr_reader :question, :entities

  def initialize(question, entities)
    @question = question
    @entities = entities
  end

  def answer
    if question =~ /^(All|Some|No).*are.*\./
      create_entity
    elsif question =~ /^Are\s(any|all|no).*\?/
      answer_entity
    elsif question =~ /^Describe.*/
      describe_entity
    else
      DEFAULT_ANSWER
    end
  end

  def create_entity
    matches = /^(All|Some|No)(.*)are(.*)\./.match(question)
    return DEFAULT_ANSWER if matches.size != 4
    entities.create_entity(kind: matches[1].downcase, subject: matches[2].strip, noun: matches[3].strip)
  end

  def answer_entity
    matches = /^Are\s(any|all|no)\s([\S]+)\s(.*)\?/.match(question)
    return DEFAULT_ANSWER if matches.size != 4
    entities.answer_entity(kind: matches[1].downcase, subject: matches[2].strip, noun: matches[3].strip)
  end

  def describe_entity
    matches = /^Describe\s(.*)\./.match(question)
    return DEFAULT_ANSWER if matches.size != 2
    entities.describe_entity(subject: matches[1].downcase)
  end

end

class App

  attr_reader :entities

  def initialize(entities)
    @entities = entities
  end

  def interact
    loop do
      print "> "
      question = gets.chomp
      parse_question(question)
    end
  end

  def parse_question(question)
    answer = Question.new(question, entities).answer
    puts answer
  end

end

App.new(Entities.new).interact
