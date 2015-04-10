date: 2010-06-18
title: First week of RubySOC

First week of Ruby Summer of Code is over an I have started coding
on extending JRuby with C extension support.

After I had already looked at wmeissner's jruby/cext the week before
and got it to run with his help, I used the first week of rsoc to
import the project into the main JRuby repository (forked on timfel/jruby).
I looked at mkmf support initially and quickly got annoyed with the way
I had to run the jruby-cext examples:

[old\_cext\_run.sh](//gist.github.com/599036)

So I started working on runtime resolution of library paths to loose the
JVM argument and be able to ship the cext jnilib in the jruby-complete.jar.
Right now, the cext jnilib is searched in the jruby.home and, if that is
within a Jar, extracted to a temporary directory.
I applied the same logic to c extension resolution, so running with cexts
looks now like any other jruby run:

[new\_cext\_run.sh](//gist.github.com/599036)

The second thing I worked on was Kernel.require support. In JRuby, the
LoadService class is responsible for resolution of require paths at
runtime and various other classes like ExternalScript and JarredScript
are used to do the actual loading.
I added a CExtension class which enabled me to require C extensions directly.
Before, 'require' in MyTest.rb looked like this:

[old\_require.rb](//gist.github.com/599036)

Now, this has shrunk to:

[new\_require.rb](//gist.github.com/599036)

