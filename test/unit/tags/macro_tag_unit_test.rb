require 'test_helper'

class CallMacroTagUnitTest < Minitest::Test

    def test_macro_assignment_with_wrong_order
        exception = assert_raises(Liquid::MacroDefaultsShouldGoLastError) {Liquid::Template.parse('{% macro hello(name="Davide", age) %}Hello World. Your name is {$ name $} and you are {$ age $} years old.{% endmacro %}')}
        assert_equal(Liquid::MacroDefaultsShouldGoLastError, exception.class)
    end
end