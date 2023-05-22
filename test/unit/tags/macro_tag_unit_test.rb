# frozen_string_literal: true

require 'test_helper'

class IfTagUnitTest < Minitest::Test
  def test_if_nodelist
    template = Liquid::Template.parse('{% macro hello func %}Hello World.{% endmacro %}')
    template.render
    template2 = Liquid::Template.parse('{% callmacro hello %}')
    template2.render
  end
end