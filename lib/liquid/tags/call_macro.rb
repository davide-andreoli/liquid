require_relative '../macro_parser'
require_relative '../macros'

class CallMacro < Liquid::Tag
    def initialize(tag_name, markup, tokens)
        """
        The initialize uses the Macro parser to receive a list of tokens, the first of which is the macro name, the rest the arguments.
        """
       super
       @macro_tokens = Liquid::MacroParser.new(markup).parse_macro_call
       @macro_name = @macro_tokens.shift.to_sym
       @macro_tokens = @macro_tokens[0]
       print(@macro_name)
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