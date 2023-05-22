require 'test_helper'

class CallMacroTagUnitTest < Minitest::Test

  def test_not_existing_macro_call
    macro_call = Liquid::Template.parse('{% callmacro this_macro_does_not_exists Davide 5 %}')
    assert_equal("Liquid error: Liquid::MacroNotDefinedError", macro_call.render)
  end
end