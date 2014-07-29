date: 2010-11-10
title: Ruby Summer of Code Wrap-Up

In the first quarter of this year I applied for a Ruby Summer of Code project,
proposing to work on support for Ruby C extensions on JRuby. JRuby has for some
time been faster than 1.8 an in in most cases as fast as 1.9 for running Ruby
code. But C extensions have been unusable on JRuby, although
[Wayne Meissner](http://www.twitter.com/wmeissner) has written a
proof-of-concept for loading C code into the JRuby runtime.

## Why C Extensions?
MRI 1.8 has been widely critizised (often outside the Ruby community), for
being slow. However, the interpreter is written in a way that allows to tap
into its structures very easily and Ruby has for some time offered a way to
link extensions in C using mkmf.rb, which is part of the standard library.  
Processing intensive tasks or interfaces to tried'n'tested C libraries could
thus be written without the overhead imposed by an unnecessary abstraction.

When alternative Implementations like Rubinius and JRuby came along, people
tried to position a new Ruby FFI as the successor to C extensions, because an
FFI API could be supported much easier on different VMs.  
I personally feel that FFI will never fully replace C extensions, because it
tries to abstract from a low-level concept without being able to hide many of
the low-level details. Quite often it is just much easier to simply write and
compile a C extension, than to write C code and try to adapt its structures in
an FFI wrapper library. Ruby is simply not very comfortable, if you have to
think about things like pointer sizes in your wrapper code.

Widespread adoption of FFI is still not happening, and maybe further away now
that Rubinius' support for native C extensions is pretty much complete for most
use cases.  
Thus, the situation for people wanting to:

* Deploy Ruby on Windows easily
* Use Java libraries
* Deploy in a war-file
* …

is, that they have to stay away from C extensions no matter what.

For some extensions, like Nokogiri, EM or OpenSSL, this has lead to pure-Java
ports, while other libraries have been _fast enough_ as pure Ruby code on JRuby.
However, multiple versions of extensions are a pain to maintain, especially
when they rely on other libraries, like RMagick does on ImageMagick or Nokogiri
on libxml. In such cases, people have tried re-writing those libraries in
Java, which not only makes maintenance even harder, but compatibility becomes
an issue, too. Nokogiri-jruby had for some time a lot of problems which came
from the Java XML implementation simply not being up to par with libxml.

## So, How Does This Work On JRuby?
My Summer of Code pretty much consisted of integrating Wayne's groundwork with
JRuby and its LoadService, which I will briefly explain here, and then trying to
get the C-API Rubyspecs passing and trying to work every Gem that somebody
seemed to care about.

### Requiring Files On JRuby
Rubys require logic is fairly complex, as proven by a ~450 LOC size of _basic_
require specs. JRuby's is even more complex, as require must also work for
.class and .jar files, and not only consider the filesystem, but also the JVM
classpath and thus jar file contents.

I learned how to hack the JRuby loading by debugging and stepping through the
LoadService class in JRuby using Eclipse. A good entry point to break in there
is the `smartLoad` method, which receives a the require String as it is passed
down from Ruby. Then, JRuby goes uses a number of `Searcher` classes to try to
find a load candidate. There is a script searcher, a classloader searcher, and
now an extension searcher, too. Each one of those tries different paths and
different file extensions to find a match, and there are quite a few things done
"under the hood".  
For example, regardless of the platform, you can always require 'something.so'
to load an extension. The `ExtensionSearcher` on JRuby will then try to find a
jar file or a file with the platform specific shared object file-extension.

When a match is found, it is loaded by a method appropriate for its type: Ruby
scripts are loaded by evaluating into the current runtime, C extensions are
loaded into the process memory and its `Init_*` methods are called. To still be
able to deploy JRuby applications in a single Jar, extensions are extracted to
the default `java.io.tmpdir` (which you can pass as JVM parameter) and loaded
from there. This is because Java's `System.loadLibrary` relies on the
underlying operating system to actually load the shared object into the process,
and that will only work if the library is in the actual filesystem.

There are a few restrictions when using extensions on JRuby. For example,
multiple Runtimes will not work, as we can only dynamically link a library to
the JVM once. Since we cannot know wether a given extension is thread-safe or
if it has global state, we can't simply re-use the already loaded library and
expose it to another Runtime. Currently, we will throw an error if one attempts
to load a C extension twice - which means Rakefiles won't work if they load
a C extension and then try spawning a sub-process. JRuby's `system()`, magic
will detect the launch of another Ruby command and just create a new Runtime
in the same JVM. If you want to support JRuby in this case, you can do the
following:
              if RUBY_PLATFORM =~ /java/
        require 'jruby'
        JRuby.runtime.instance_config.run_ruby_in_process = false  
    end
### Running C Code In JRuby - Pieces Of Advice
In order for extensions to work, we had to implement as much of the Ruby C API
as is possible to support on JRuby. In most cases, where the C methods are
simply implementations of STL functionality in C (things like `rb_ary_push`,
`rb_str_cat`, `rb_str_new`, …) we can just upcall to Java and have JRuby
run the Ruby code for this. You can imagine that this is quite slow, but it is
safe, and easily supported. Eventually, we can speed those calls up by caching
call targets and methods, too.

More difficult are most macros. Things like `RSTRING_PTR`
or `RARRAY` expose internal structs of MRI, which we cannot support directly.
On JRuby, once you use such a macro, the objects you are accessing are added
to a synchronization list and upon __each__ switch Java -> C -> Java the
contents of the object are copied downwards and upwards; until the object is
eventually garbage collected. We are copying _all_ active objects, because
we cannot know if a reference in form of a variable to the content pointers
remains in use.

Something we currently do not support at all, or only in a very limited way, are macros
and methods which rely on or deal with MRI's AST (e.g. the `NODE(x)` macro),
its threading model (`thread_critical = true` won't work), file descriptors
(changing an fd's access might not work reliably) and stack layout (functions
like `rb_each` and `rb_iterate` don't work for arbitrary data structures).

So people, if you're building C extensions, and want them to work on JRuby,
avoid methods that could make assumptions about any of the areas above.
If you want your extensions to work faster on JRuby, avoid structs and
struct-macros: use accessor methods instead. If you need read-only access the
contents of a string as a char array, make sure those Ruby objects are GC'd
soon enough, for example by using `rb_str_cstr(x)`.  
Finally, if you want some code to be specific for JRuby, `#ifdef JRUBY` will help
you decide what you are compiling for (this works with `RUBINIUS`, too).

Generally, C extensions on JRuby will never be fast. Never as fast as on MRI,
and never as fast as plain Ruby code on JRuby. As extensions go:
  
C Extension < FFI < Java callout < Java Extension
  
I have seen actual speedups only in extensions that do a lot of work in a
single call. [Ryan Tomayko](http://github.com/rtomayko/rdiscount)'s RDiscount
gem is a good example. There's only a single call down, the hard work is done 
in C, and the String will probably be garbage collected pretty soon in Ruby
land (see also my [micro-benchmark](/2010/08/benchmarking-rdiscount);
just don't interpret too much into it).

