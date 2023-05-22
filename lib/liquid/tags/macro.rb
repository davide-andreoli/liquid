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
       

class Macro < Liquid::Block
    def initialize(tag_name, markup, tokens)
       super
       @macro_tokens = markup.gsub(/[,()]/, ' ').gsub(/\s+/, ' ').split(' ')
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
       @macro_tokens = markup.gsub(/[,()]/, ' ').gsub(/\s+/, ' ').split(' ')
       @macro_name = @macro_tokens.shift.to_sym
       @macro_arguments = @macro_tokens
    end
  
    def render(context)
        Macros.read_macro(@macro_name, @macro_arguments)
    end
end
  
Liquid::Template.register_tag('call_macro', CallMacro)


