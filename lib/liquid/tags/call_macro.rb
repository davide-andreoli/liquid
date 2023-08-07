require_relative '../macro_parser'
require_relative '../macros'

class CallMacro < Liquid::Tag
    def initialize(tag_name, markup, tokens)
        """
        The initialize uses the Macro parser to receive a list of tokens, the first of which is the macro name, the rest the arguments.
        """
       super
       # TO-DO parse_macro_call called two times --> change to one
       @macro_tokens = Liquid::MacroParser.new(markup).parse_macro_call[1]
       @macro_name = Liquid::MacroParser.new(markup).parse_macro_call[0].to_sym
       # Strip quotes
       for index in 0..@macro_tokens.count - 1
            @macro_tokens.keys[index] = @macro_tokens.keys[index].to_s.delete_prefix('"').delete_suffix('"')
       end
       @macro_arguments = @macro_tokens
    end
  
    def render(context)
        Liquid::Macros.read_macro(@macro_name, @macro_arguments)
    end
end
  
Liquid::Template.register_tag('call_macro', CallMacro)