# Possible way to implement this
# When the macro block is called the macro is added in a dictionary as a key value pair where
# the key is the name of the macro
# the value is the string of the macro, with the replacement parameters as $0, $1, $2, etc
# to call the macro one would have to use the callmacro tag, which would then
# render the correct macro replacing the tokens with regex

class Macros
    @@macros_list = {}
    public
    def self.add_macro(macro_name, macro_string)
        @@macros_list[macro_name.to_sym] = macro_string
        puts "Adding"
        puts @@macros_list
    end
    def self.macros_list
        @@macros_list
    end
    def self.read_macro(macro_name)
        puts "Reading"
        puts @@macros_list[macro_name.to_sym]
    end

end
       

class Macro < Liquid::Block
    def initialize(tag_name, markup, tokens)
       super
       @macro_name = markup.to_s.split(" ")[0].to_sym
       puts tag_name
       puts markup
    end

    def render(context)
      @macro_string = super
      Macros.add_macro(@macro_name, @macro_string)
    end
end
  
Liquid::Template.register_tag('macro', Macro)

class CallMacro < Liquid::Tag
    def initialize(tag_name, markup, tokens)
       super
       @macro_name = markup.to_sym
    end
  
    def render(context)
        puts Macros.read_macro("hello")
    end
  end
  
Liquid::Template.register_tag('callmacro', CallMacro)


