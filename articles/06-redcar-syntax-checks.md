date: 2010-10-23
title: Syntax Checking For Redcar

I spent the last couple of days thinking about how to implement syntax
checking for Redcar. [Konstantin Haase](http://rkh.im) and I discussed
using the [Melbourne](http://github.com/simplabs/melbourne) gem, which
is basically Rubinius' parser extracted into a gem. Melbourne is a C
extension which has been passing all specs for some time now on JRuby
master with cext support, so that seemed like a viable way to go.

Before I got started on my plan, however, I remembered that JRuby, like
MRI, supports the `-c` switch to just do Syntax checking. So I dug into
that a little and came up with a short script to run the JRuby parser
on a piece of code from within a JRuby process:

[ruby\_syntax\_checker.rb](//gist.github.com/639637)

From this I have now created two Redcar plugins: 
[redcar\_syntax\_check](http://github.com/timfel/redcar_syntax_check) which
offers some general features pertaining to syntax checking: an abstract checker
class, a syntax error class which knows how to annotate an edit view in Redcar
and a hook to run available syntax checkers after saving a file.  
To do this I had to add a few methods to Redcar's _edit\_view_ plugin, so currently
this runs only on master.

Using this plugin it is now fairly easy to offer syntax checking for any language:
All you have to do is inherit from `Redcar::SyntaxCheck::Checker` and implement your
custom syntax checking logic in the `check` method. If you discover syntax errors in
the given file, build instances of `Redcar::SyntaxCheck::Error` from them - `Error`'s
need only know which document they belong to, the line number and a message. Calling
`annotate` on them will then draw the annotation and a wiggly line at the error position.

Finally, tell Redcar which grammar's you support using the `supported_grammars` class
method and a list of grammar names in your `Checker` subclass' class body and you're done!

See [redcar\_syntax\_check\_ruby](http://github.com/timfel/redcar_syntax_check) for
an example of how to do it.

When all went well, you can just open a document, write some code and, upon saving, it
will automatically check the syntax and show you your errors:

![Syntax error in a Ruby file](/public/images/ruby-syntax-error.png)

&nbsp;

