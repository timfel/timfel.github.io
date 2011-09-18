title: Debugging on steroids - what Ruby should learn from Smalltalk

## A prototype of Seaside-like debugging in Ruby

### The premise

I have used Smalltalk and the [Seaside](http://seaside.st)
web-framework for some time before [Konstantin](http://rkh.im)
introduced me to Ruby. I've come to use Ruby for most of my scripting
needs, but what I've always preferred about Smalltalk is the tool
integration: because you're working with a live system, you have
access to all these objects you write code for, to play with and see
how they behave whenever you want to.

So in Seaside, when you break your application, you get a stacktrace
page not unlike the pages in Rails, Sinatra, or Rack. However, in
addition to the links for framework and full traces, you have a link
to *debug* the thing directly. Simply at the point where it has thrown
the error. And then resume it. As if nothing ever happened.

In Rails, when you break your application, you try to figure out
what's wrong from the trace and by looking at the code. Then you
change the code and hope the Rails reloader works (and that you cannot
always rely on, see Konstantin's [post](http://rkh.im/code-reloading)
on the matter). In Sinatra or Rack apps, you'll usually have to
restart your app. This means waiting for the server to come up and the
request to be handled again. Even if it's just a second or two ... it
does add up.

Also, it's bloody annoying.

### Here comes Everybody...

's favorite Ruby implementation [MagLev](http://ruby.gemstone.com)!
MagLev is a Ruby implementation build on the excellent, mature, and
battle-tested Gemstone/S Smalltalk product. Ruby classes and methods
on MagLev are almost indistinguishable from Smalltalk methods and
classes, and most of the core classes are simply shared between the
implementations.

Since I've recently started an internship with Gemstone (now owned by
VMware) in Beaverton, OR, I have the opportunity to try and provide a
bridge for some of that Smalltalk goodness to reach the Ruby world!

First thing I added enough reflection to the Ruby core classes (mostly
Thread and Method) to allow writing a debugger in pure Ruby.

* This means being able to inspect, change, step through, and restart
frames.
* This means stopping, copying, saving, and restarting Threads,
all in pure Ruby. 
* This also means having an API to change methods and classes,
in-process, and have them write back to the file-system to keep it
consistent with the process' contents.

### Later, that same day

Being well equipped with **Awesome Reflective Powers**&trade; now, I
wrote an error handling Rack middleware for inclusion in any Rails,
Rack and Sinatra app, and whipped up a very simple, web-based debugger
that can connect to a running process and, well, debug it.

I presented the demo in the video below at the
[pdx.rb](http://pdxruby.org) meeting in September. So what's going on
here? First, I'm using an old Sinatra app which I've added a bug
to. This bug triggers the Rack middleware to save a continuation of
the thread and present a (very, very simple) error page explaining
what you can do from there. That page has a link to resume the thread
that handled the connection. If you click it, without actually
debugging, the thread just continues and shows the Sinatra error page
as it would without the middleware.

We, however, having installed MagLev's
[Webtools](http://www.github.com/MagLev/webtools), can connect to the
other process, find the right thread and look at the stack. We can
quickly find the last frame that executes some of our code: the class
method **Bithug::User.find**.

Because we're dealing with an actual, living and breathing thread
object saved to the stone repository, we can send messages to it to
look at the arguments and locals of a method. We can see that *self*
is the Bithug::User class, and that the *Db* constant that was
involved in the error is a *KeyValueDictionary*. We can also find out
that the value the method selects from the Db is non-existent. After
noticing our mistake (*self.class.name* should really be *self.name*,
because we're already on the class side) we can edit the code and save
it, thereby

* changing the code in process,
* writing it back to the file system,
* and instructing the thread to reload and re-execute that frame

The thread is still suspended and in a persistent state. But if we go
back to our application now and tell it to resume the request, it will
prepare the thread for execution and run it - and we can see our app
load. The error is fixed!
  

<iframe width="425" height="349"
	src="http://www.youtube.com/embed/LvipqMIHkO8?hl=en&fs=1"
	frameborder="0" allowfullscreen>
</iframe>

### Why this is cool

Just using plain old Ruby, we can debug an application, we can inspect
and change it *while it is running*.  We don't have to restart the
process, we don't even have to restart the request, it's all in the
thread, persisted to the repository.

The actual application doesn't need to expose all these things,
either. The thread was saved to the stone repository anyway, we can
fire up a VM on a completely different machine, pull the thread from
the stone and debug there! So even production, no error will ever need
to go undebugged, because *you can keep every error around for later
inspection*! No more trying to reproduce what's on your production
system - triggering the error just once is enough to step through it
again and again and again and again. 

This is one of the many advantages of having a malleable Smalltalk
stack and real object persistence built into your VM!

Other use-cases come to mind. Remember, all this is accessible using
pure Ruby.

You might want to handle other extraordinary cases in your application
by simply persisting a continuation of the interesting state, so you
can look at it later.

Or whenever you look at a method wondering what's going on, you can
just pull up a thread *from your life app* and see what kinds of
arguments you might get, and what the state of your application might
look like in this method.

## Soon, at a Ruby implementation near you

I am currently working on providing and documenting enough API for
people to do all these things with their Ruby apps. I hope some of
this will show Rubyists that having an extraordinarily dynamic
language doesn't mean you can't have great tools as well...
