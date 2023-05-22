# Macros in Liquid... why?
In the last weeks I've been working with Looker a lot, and I find myself having to copy past the same logic in different views changing maybe only some arguments, which makes it very difficult to maintain the code and change all the occurences of the same logic in all the places when I have to implement an improvement.

I did some research and I discovered that macros were not included in Liquid, and Shopify's team was againts them because it would increase complexity of templates, worsen new code readability and make template edits very difficult ([see this issue if you want to read more about it](https://github.com/Shopify/liquid/issues/580)). 

To be honest, their stance made a lot of sense in their use case, however after a while they decided to include the {% render %} tag, which basically works as a macro would work ([see this pull request if yoou want to read more about it](https://github.com/Shopify/liquid/pull/1122)).

So why develop another macro tag if something similar to it is already available?

Long story short, there are four reasons:
1. I read about the render tag after I alrady began developing my version, so I wanted to finish what I was working on
2. The render implementation does not allow for default values, which is something I'm interested in looking at
3. From the Looker IDE there is no way of creating a dedicated .liquid file, so this implementation does not depend on a custom .liquid file, but allows for the creation of inline macros
4. It is a good Ruby exercise :smile:

Finally, I should mention that all this work is done with a very limited Ruby knowledge, and with only Looker implementation in mind (which basically means that I expect to work with SQL code, although I'll try to keep things general).

# How do they work?
## The {% macro %} block
Exactly like in other templating languages (e.g.: Jinja) you can define a macro using the macro block.
The macro arguments should be referenced inside the block using {$ $} tags.
```liquid
{% macro hello_world name %}
    Hello World. My name is {$ name $}.
{% endmacro %}
```
Under the hood when the macro tag is rendered, nothing is printed to the screen but the macro is added to a macro list, which can then be later called with arguments using a dedicated tag.
Macros can also be defined using parenthesis, meaning that the following code would have the same result as before.
```liquid
{% macro hello_world(name) %}
    Hello World. My name is {$ name $}.
{% endmacro %}
```
## The {% call_macro %} tag
Macros defined with the {% macro %} block can be then callend with the {% call_macro %} tag.
```liquid
{% call_macro hello_world Davide %}
```
Would render as:
```
Hello World. My name is Davide.
```
As for the macro definition, the macro call can be done using parenthesis as well (this is obviously not linked to the way the macro has been defined).

# Limitations
- Default arguments are not supported
- Array inputs are not supported
- Not much flexibility for errors as of right now

# How would this work in Looker

Macros could be defined at the model level to be used in all views and explores defined in that model.


