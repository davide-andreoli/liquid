# frozen_string_literal: true

require 'test_helper'

class MacroBlockUnitTest < Minitest::Test

  def test_macro_assignment_and_call
    macro_definition = Liquid::Template.parse('{% macro hello name age %}Hello World. Your name is {$ name $} and you are {$ age $} years old.{% endmacro %}')
    macro_definition.render
    macro_call = Liquid::Template.parse('{% call_macro hello Davide 5 %}')
    assert_equal("Hello World. Your name is Davide and you are 5 years old.", macro_call.render)
  end

  def test_macro_assignment_alternative_syntax_and_call
    macro_definition = Liquid::Template.parse('{% macro hello(name, age) %}Hello World. Your name is {$ name $} and you are {$ age $} years old.{% endmacro %}')
    macro_definition.render
    macro_call = Liquid::Template.parse('{% call_macro hello Davide 5 %}')
    assert_equal("Hello World. Your name is Davide and you are 5 years old.", macro_call.render)
  end

  def test_macro_assignment_and_call_alternative_syntax
    macro_definition = Liquid::Template.parse('{% macro hello name age %}Hello World. Your name is {$ name $} and you are {$ age $} years old.{% endmacro %}')
    macro_definition.render
    macro_call = Liquid::Template.parse('{% call_macro hello(Davide, 5) %}')
    assert_equal("Hello World. Your name is Davide and you are 5 years old.", macro_call.render)
  end


  def test_macro_assignment_and_call_with_spaces
    macro_definition = Liquid::Template.parse('{% macro hello name age %}Hello World. Your name is {$ name $} and you are {$ age $} years old.{% endmacro %}')
    macro_definition.render
    macro_call = Liquid::Template.parse('{% call_macro hello("Davide Andreoli", 5) %}')
    assert_equal("Hello World. Your name is Davide Andreoli and you are 5 years old.", macro_call.render)
  end

  def test_macro_assignment_and_call_with_default_argument
    macro_definition = Liquid::Template.parse('{% macro hello(name, age=18) %}Hello World. Your name is {$ name $} and you are {$ age $} years old.{% endmacro %}')
    macro_definition.render
    macro_call = Liquid::Template.parse('{% call_macro hello Davide %}')
    assert_equal("Hello World. Your name is Davide and you are 18 years old.", macro_call.render)
  end

  def test_macro_assignment_and_call_with_overwritten_default_argument
    macro_definition = Liquid::Template.parse('{% macro hello(name, age=18) %}Hello World. Your name is {$ name $} and you are {$ age $} years old.{% endmacro %}')
    macro_definition.render
    macro_call = Liquid::Template.parse('{% call_macro hello Davide age=5 %}')
    assert_equal("Hello World. Your name is Davide and you are 5 years old.", macro_call.render)
  end

  def test_macro_assignment_and_call_with_two_named_argument
    macro_definition = Liquid::Template.parse('{% macro hello(name, age=18, dogs=2) %}Hello World. Your name is {$ name $}, you are {$ age $} years old and you have {$ dogs $} dogs.{% endmacro %}')
    macro_definition.render
    macro_call = Liquid::Template.parse('{% call_macro hello Davide dogs=4 age=25%}')
    assert_equal("Hello World. Your name is Davide, you are 25 years old and you have 4 dogs.", macro_call.render)
  end

end