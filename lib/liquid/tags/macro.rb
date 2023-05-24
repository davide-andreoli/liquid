class Macros
    @@macros_list = {}
    public
    def self.add_macro(macro_name, macro_string)
        @@macros_list[macro_name.to_sym] = macro_string
    end
    def self.macros_list
        @@macros_list
    end
    def self.read_macro(macro_name, macro_arguments)
        if @@macros_list.key?(macro_name)
            macro_string = @@macros_list[macro_name.to_sym]
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
       @macro_tokens = MacroParser.new(markup)
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
       @macro_tokens = markup.gsub(/[,()]/, ' ').gsub(/\s+/, ' ').scan(/[^\s"']+|"[^"]*"/)
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


