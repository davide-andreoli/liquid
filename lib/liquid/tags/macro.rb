"""
To parse named arguments:
- write a function to peek a token, and check if it contains an assignment operator
- write a function to parse the assignment: everything before the equal sign is the name of the variable, everything after the value
- refactor the macro list to be contain an arguments object, which have a key conisting of the name of the variable and a default value as a value, or nil if no default value is givven

"""


class Macros
    @@macros_list = {}
    public
    def self.add_macro(macro_name, macro_string)
        @@macros_list[macro_name.to_sym] = {}
        @@macros_list[macro_name.to_sym][:body] = macro_string
    end
    def self.macros_list
        @@macros_list
    end
    def self.read_macro(macro_name, macro_arguments)
        if @@macros_list.key?(macro_name)
            macro_string = @@macros_list[macro_name.to_sym][:body]
            for index in 0..macro_arguments.count - 1
                macro_string = macro_string.gsub(/\{\$\s+\$#{index}\s+\$\}/, macro_arguments[index])
            end
            macro_string
        else
            raise Liquid::MacroNotDefinedError
        end
    end
end

class MacroParser
    def initialize(string_to_parse)
        @string_to_parse = string_to_parse.chars
        @reading_position = 0
    end

    def next
        current_reading_position = @reading_position
        @reading_position = @reading_position + 1
        @string_to_parse[current_reading_position]
    end

    def peek
        @string_to_parse[@reading_position]
    end

    def end_of_file
        @reading_position == @string_to_parse.count
    end

    def is_alphanumeric()
        self.peek.match?(/\w/)
    end

    def is_whitespace()
        self.peek.match?(/\s/)
    end

    def is_quotes()
        self.peek.match?(/["']/)
    end

    def is_parenthesis()
        self.peek.match?(/[()]/)
    end

    def is_assignment()
        self.peek.match?(/=/)
    end

    def read_string
        starting_quote = self.next
        token = ""
        while ! self.end_of_file do
            if self.is_quotes == false
                token = token + self.next
            else
                if self.peek == starting_quote
                    break
                else
                    token = token + self.next
                end
            end
        end
        self.next
        token
    end

    def read_token(skip_spaces = true)
        token = ""
        while ! self.end_of_file do
            if self.is_alphanumeric == true
                token = token + self.next
            elsif self.is_whitespace && skip_spaces == true
                break
            elsif self.is_whitespace && skip_spaces == false
                token = token + self.next
            else
                break
            end
        end
        token
    end

    def parse
        list = []
        while ! self.end_of_file do
            if self.is_alphanumeric == true
                list.append(self.read_token)
            elsif self.is_quotes == true
                list.append(self.read_string)
            else
                self.next
            end
        end
        list
    end
end
  
class Macro < Liquid::Block
    def initialize(tag_name, markup, tokens)
       super
       @macro_tokens = MacroParser.new(markup).parse
       @macro_name = @macro_tokens.shift.to_sym
       @macro_arguments = @macro_tokens
    end

    def render(context)
      @macro_string = super
      for index in 0..@macro_arguments.count - 1
        replacement = '{$ $' + index.to_s + ' $}'
        @macro_string = @macro_string.gsub(/\{\$\s+#{@macro_arguments[index]}\s+\$\}/, replacement)    
      end
      Macros.add_macro(@macro_name, @macro_string)
    end
end
  
Liquid::Template.register_tag('macro', Macro)

class CallMacro < Liquid::Tag
    def initialize(tag_name, markup, tokens)
       super
       @macro_tokens = MacroParser.new(markup).parse
       @macro_name = @macro_tokens.shift.to_sym
       for index in 0..@macro_tokens.count - 1
            @macro_tokens[index] = @macro_tokens[index].delete_prefix('"').delete_suffix('"')
       end
       @macro_arguments = @macro_tokens
    end
  
    def render(context)
        Macros.read_macro(@macro_name, @macro_arguments)
    end
end
  
Liquid::Template.register_tag('call_macro', CallMacro)

# ruby -I test test/integration/macro_tests.rb
# ruby -I test test/unit/tags/call_macro_tag_unit_test.rb
#commit