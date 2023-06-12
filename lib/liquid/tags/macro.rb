"""
To parse named arguments:
- write a function to peek a token, and check if it contains an assignment operator
- write a function to parse the assignment: everything before the equal sign is the name of the variable, everything after the value
"""


class Macros
    @@macros_list = {}
    public
    def self.add_macro(macro_name, macro_arguments, macro_string)
        @@macros_list[macro_name.to_sym] = {}
        @@macros_list[macro_name.to_sym][:body] = macro_string
        @@macros_list[macro_name.to_sym][:arguments] = macro_arguments
    end
    def self.macros_list
        @@macros_list
    end
    def self.read_macro(macro_name, macro_arguments)
        if @@macros_list.key?(macro_name)
            macro_string = @@macros_list[macro_name.to_sym][:body]
            for index in 0..macro_arguments.count - 1
                macro_string = macro_string.gsub(/\{\$\s+\$#{index}\s+\$\}/, macro_arguments.values[index])
            end
            macro_string
        else
            raise Liquid::MacroNotDefinedError
        end
    end
end

class MacroParser
    def initialize(string_to_parse)
        @string_to_parse = string_to_parse.rstrip.lstrip.chars
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

    def is_assignment_token
        current_reading_position = @reading_position
        result = false
        while ! self.end_of_file do
            if self.is_alphanumeric == true
                self.next
            elsif self.is_whitespace == true
                self.next
            else
                break
            end
        end
        if ! self.end_of_file && self.is_assignment
            result = true
        end
        @reading_position = current_reading_position
        result
    end

    def read_assignment
        variable_name = ""
        variable_value = ""
        while ! self.end_of_file do
            if self.is_alphanumeric == true
                variable_name = variable_name + self.next
            elsif self.is_whitespace
                self.next
            elsif self.is_assignment
                break
            else
                break
            end
        end
        self.next # skip the equal sign
        if self.is_whitespace == true
            self.next
        elsif is_alphanumeric == true
            variable_value = self.read_token
        elsif self.is_quotes == true
            variable_value = self.read_string
        end
        array = [variable_name, variable_value]
        array
    end

    def parse_macro_creation
        list = {}
        while ! self.end_of_file do
            if self.is_assignment_token == true
                token = self.read_assignment
                list[token[0].to_sym] = token[1]
            elsif self.is_alphanumeric == true
                list[self.read_token.to_sym] = nil
            else
                self.next
            end
        end
        list
    end

    def parse_macro_call
        list = {}
        macro_name = ""
        read_macro_name = false
        while ! self.end_of_file do
            if self.is_alphanumeric == true
                if ! read_macro_name
                    macro_name = self.read_token
                    read_macro_name = true
                else
                    list[("$" + (list.keys.count).to_s).to_sym] = self.read_token
                end
                
            elsif self.is_quotes == true
                list[("$" + (list.keys.count).to_s).to_sym] = self.read_string
            else
                self.next
            end
        end
        array = [macro_name, list]
        array
    end
end
  
class Macro < Liquid::Block
    def initialize(tag_name, markup, tokens)
       super
       @macro_tokens = MacroParser.new(markup).parse_macro_creation
       @macro_name = @macro_tokens.shift[0].to_sym
       @macro_arguments = @macro_tokens
    end

    def render(context)
      @macro_string = super
      for index in 0..@macro_arguments.count - 1
        replacement = '{$ $' + index.to_s + ' $}'
        @macro_string = @macro_string.gsub(/\{\$\s+#{@macro_arguments.keys[index].to_s}\s+\$\}/, replacement)    
      end
      Macros.add_macro(@macro_name, @macro_arguments, @macro_string)
    end
end
  
Liquid::Template.register_tag('macro', Macro)

class CallMacro < Liquid::Tag
    def initialize(tag_name, markup, tokens)
       super
       @macro_tokens = MacroParser.new(markup).parse_macro_call[1]
       @macro_name = MacroParser.new(markup).parse_macro_call[0].to_sym
       for index in 0..@macro_tokens.count - 1
            @macro_tokens.keys[index] = @macro_tokens.keys[index].to_s.delete_prefix('"').delete_suffix('"')
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