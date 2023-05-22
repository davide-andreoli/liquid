# frozen_string_literal: true

require 'test_helper'

class MacroBlockUnitTest < Minitest::Test
  def test_macro_assignment_and_call
    macro_definition = Liquid::Template.parse('{% macro hello name age %}Hello World. Your name is {$ name $} and you are {$ age $} years old.{% endmacro %}')
    macro_definition.render
    macro_call = Liquid::Template.parse('{% call_macro hello Davide 5 %}')
    assert_equal("Hello World. Your name is Davide and you are 5 years old.", macro_call.render)
  end
end