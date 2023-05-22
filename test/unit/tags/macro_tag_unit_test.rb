# frozen_string_literal: true

require 'test_helper'

class IfTagUnitTest < Minitest::Test
  def test_if_nodelist
    template = Liquid::Template.parse('{% macro hello name age %}Hello World. Your name is {$ name $} and you are {$ age $} years old.{% endmacro %}')
    template.render
    template2 = Liquid::Template.parse('{% callmacro hello Davide 5 %}')
    puts template2.render
  end
end