"""
    To-Do:
        - parse named arguments when calling a macro
"""
class Macros
    """
        This class is used to store user defined macros.
    """
    @@macros_list = {}

    public

    def self.add_macro(macro_name, macro_arguments, macro_string)
        """
            This function takes the macro name, macro argument and macro string to the macro list.
            A macro is represented as an hash with this structure:
            :macro_name : {
                :body : 'macro_string'
                :arguments : {
                    :argument_name : 'argument_default_value'
                }
            }
        """
        @@macros_list[macro_name.to_sym] = {}
        @@macros_list[macro_name.to_sym][:body] = macro_string
        @@macros_list[macro_name.to_sym][:arguments] = macro_arguments
    end

    def self.macros_list
        """
            The getter for the macros list.
        """
        @@macros_list
    end

    def self.read_macro(macro_name, macro_arguments)
        """
        This functions accepts a macro name and list of arguments, and call the macro replacing the arguments values.
        The macro_arguments argument is an hash of the structure:
            :argument_name -> 'argument_value'
        where :argument_name can be the argument name when a named argument is used, or $x where positional arguments are used.
        """
        # Checks if the macro exists
        if @@macros_list.key?(macro_name)
            # Reads the macro string from the macros list
            macro_string = @@macros_list[macro_name.to_sym][:body]
            # Iterate over the arguments in the macro call
            # TO-DO: iterate over the items themselves
            for index in 0..macro_arguments.count - 1
                # Check if the argument is a positional one
                if macro_arguments.keys[index].match?(/\$[0-9]*/)
                    # Replaces all the $x occurences inside the macro string with the corresponding value
                    macro_string = macro_string.gsub(/\{\$\s+\$#{index}\s+\$\}/, macro_arguments.values[index])
                else
                    # Replace all the $x occurences inside the macro string with the corresponding value
                    # $x is calculated based on the index of the argument in the macro definition
                    macro_string = macro_string.gsub(/\{\$\s+\$#{@@macros_list[macro_name.to_sym][:arguments].keys.index(macro_arguments.keys[index])}\s+\$\}/, macro_arguments.values[index])
                end
            end
            # Checks if the received arguments list is exhaustive (e.g. all arguments have been passed)
            if macro_arguments.count != @@macros_list[macro_name.to_sym][:arguments].count
                # If not, it iterates over the remaining arguments and replace the default value
                for index in macro_arguments.count..@@macros_list[macro_name.to_sym][:arguments].count - 1
                    macro_string = macro_string.gsub(/\{\$\s+\$#{index}\s+\$\}/, @@macros_list[macro_name.to_sym][:arguments].values[index])
                end
            end
            macro_string
        else
            raise Liquid::MacroNotDefinedError
        end
    end
end

class MacroParser
    """
        This class is used to parse macros.
    """
    def initialize(string_to_parse)
        """
            The class is initialized by stripping whitespaces from the string and setting the reading position to 0.
        """
        @string_to_parse = string_to_parse.rstrip.lstrip.chars
        @reading_position = 0
    end

    def next
        """
            This function return the current character and advance the reading position.
        """
        current_reading_position = @reading_position
        @reading_position = @reading_position + 1
        @string_to_parse[current_reading_position]
    end

    def peek
        """
            This function return the current character.
        """
        @string_to_parse[@reading_position]
    end

    def end_of_file
        """
            This function returns true if the end of file is reached.
        """
        @reading_position == @string_to_parse.count
    end

    def is_alphanumeric()
        """
            This function returns true if the current character is an alphanumeric.
        """
        self.peek.match?(/\w/)
    end

    def is_whitespace()
        """
            This function returns true if the current character is a whitespace.
        """
        self.peek.match?(/\s/)
    end

    def is_quotes()
        """
            This function returns true if the current character is a quote.
        """
        self.peek.match?(/["']/)
    end

    def is_parenthesis()
        """
            This function returns true if the current character is a round parenthesis.
        """
        self.peek.match?(/[()]/)
    end

    def is_assignment()
        """
            This function returns true if the current character is an equal sign.
        """
        self.peek.match?(/=/)
    end

    def read_string
        """
            This function reads a string, starting from a quote character and ending with the same quote character.
        """
        # Acquire starting quote
        starting_quote = self.next
        token = ""
        while ! self.end_of_file do
            # Check if it is a quote character
            if self.is_quotes == false
                # If it is not a quote character, add it to the token string
                token = token + self.next
            else
                # Check if the quote is equal to the starting quote
                if self.peek == starting_quote
                    break
                else
                    token = token + self.next
                end
            end
        end
        # Advance to the next position, as the loop broke at the quote position
        self.next
        token
    end

    def read_token(skip_spaces = true)
        """
        This function reads a token.
        """
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
        """
            This function returns true if the current token is an assignment.
        """
        current_reading_position = @reading_position
        parsed_space = false
        result = false
        while ! self.end_of_file do
            # Checks if the character is alphanumeric and spaces have not already been parsed
            if self.is_alphanumeric == true && parsed_space == false
                self.next
            elsif self.is_whitespace == true
                parsed_space = true
                self.next
            else
                break
            end
        end
        # If the character is an assignment, then the token is an assignment token
        if ! self.end_of_file && self.is_assignment
            result = true
        end
        @reading_position = current_reading_position
        result
    end

    def read_assignment
        """
            This function reads an assignment and returns an array containing the variable name in the first position, and value in the second.
        """
        variable_name = ""
        variable_value = ""
        # read the variable name
        # TO-DO: use function read token
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
        # TO-DO use a for loop, this will skip only one space
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
        """
            This function is used to parse the macro creations syntax.
            It return a hash of arguments in the form :argument_name -> argument value.
        """
        list = {}
        read_assignment = false
        while ! self.end_of_file do
            # Check if the token is an assignment token, which means an argument with a default value
            if self.is_assignment_token == true
                token = self.read_assignment
                list[token[0].to_sym] = token[1]
                read_assignment = true
            elsif self.is_alphanumeric == true
                # Checks if an assignment is already been read, becasue default arguments should go last
                if read_assignment
                    raise Liquid::MacroDefaultsShouldGoLastError
                else
                    # Add
                    list[self.read_token.to_sym] = nil
                end
            else
                self.next
            end
        end
        list
    end

    def parse_macro_call
        """
            This function is used to parse the macro call syntax.
            It returns an array containing the macro name and a hash of arguments in the form :argument_name -> argument value.
        """
        list = {}
        macro_name = ""
        read_macro_name = false
        read_assignment = false
        while ! self.end_of_file do
            # Checks to see if the token is an assingment token
            if self.is_assignment_token == true
                token = self.read_assignment
                list[token[0].to_sym] = token[1]
                read_assignment = true
            elsif self.is_alphanumeric == true
                # Checks if macro name has already been parsed, if not parse it
                if ! read_macro_name
                    macro_name = self.read_token
                    read_macro_name = true
                else
                    # Parse the positional argument in the form :$n -> value
                    list[("$" + (list.keys.count).to_s).to_sym] = self.read_token
                end
                
            elsif self.is_quotes == true
                # Parse the positional argument in the form :$n -> value
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
    """
        The Macro TAG.
    """
    def initialize(tag_name, markup, tokens)
        """
            The initialize uses the Macro parser to receive a list of tokens, the first of which is the macro name, the rest the arguments.
        """
       super
       @macro_tokens = MacroParser.new(markup).parse_macro_creation
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
        Macros.add_macro(@macro_name, @macro_arguments, @macro_string)
    end
end
  
Liquid::Template.register_tag('macro', Macro)

class CallMacro < Liquid::Tag
    def initialize(tag_name, markup, tokens)
        """
        The initialize uses the Macro parser to receive a list of tokens, the first of which is the macro name, the rest the arguments.
        """
       super
       # TO-DO parse_macro_call called two times --> change to one
       @macro_tokens = MacroParser.new(markup).parse_macro_call[1]
       @macro_name = MacroParser.new(markup).parse_macro_call[0].to_sym
       # Strip quotes
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
# ruby -I test test/unit/tags/macro_tag_unit_test.rb
