module Liquid    
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
end