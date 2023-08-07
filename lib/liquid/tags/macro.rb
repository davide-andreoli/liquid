require_relative '../macro_parser'
require_relative '../macros'

class Macro < Liquid::Block
    """
        The Macro TAG.
    """
    def initialize(tag_name, markup, tokens)
        """
            The initialize uses the Macro parser to receive a list of tokens, the first of which is the macro name, the rest the arguments.
        """
       super
       @macro_tokens = Liquid::MacroParser.new(markup).parse_macro_creation
       @macro_name = @macro_tokens.shift[0].to_sym
       @macro_arguments = @macro_tokens
    end

    def render(context)
    """
        In the render function there is not actual rendering, but the macro is added to the Macros list variable.
    """
        @macro_string = super
        for index in 0..@macro_arguments.count - 1
            replacement = '{$ $' + index.to_s + ' $}'
            @macro_string = @macro_string.gsub(/\{\$\s+#{@macro_arguments.keys[index].to_s}\s+\$\}/, replacement)    
        end
        Liquid::Macros.add_macro(@macro_name, @macro_arguments, @macro_string)
    end
end
  
Liquid::Template.register_tag('macro', Macro)



# ruby -I test test/integration/macro_tests.rb
# ruby -I test test/unit/tags/call_macro_tag_unit_test.rb
# ruby -I test test/unit/tags/macro_tag_unit_test.rb
