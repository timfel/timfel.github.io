date: 2010-09-26
title: A Redcar debugger interface

## Bringing some debugging to Redcar

### The Redcar
I have been using the excellent [Redcar editor](http://www.redcareditor.com) for about a year now,
and I must say I am very happy with this project and the pace it's moving forward at. Hardly
a day goes by where there is not some new, hot feature that makes coding easier in this project.

But the best part: this editor is written almost entirely in JRuby, which makes it a breeze to get into
the code and start hacking on it.

### Redcar-Debug
When working on C extension support for JRuby, I often find myself having to attach a Java debugger
and a GDB to the same process. For Java debugging, I used Eclipse, which comes with very handy features
like inspection and hot code reloading, but the thing I like most about the Eclipse debug perspective
is how it organizes the information about the process.

With GDB's commandline interface, I often found myself typing `bt`, `info locals`, `info args` at each
breakpoint, and returning back to Redcar for context.

Luckily, there are very good frontends for GDB, too, the most sophisticated I could find was the debugger
interface for [*Emacs*](http://www.emacswiki.org/emacs/GrandUnifiedDebugger), which offers me a layout
similar to the Eclipse debug perspective. The Emacs debugger interface even came with JDB support.
Hurray!

#### Why Redcar-debug?
I turns out, while I do like Emacs for *TeX* editing, I prefer programming in Redcar. Switching between
Redcar, Eclipse was bad enough, throwing Emacs into that was too much.

This is why I started [redcar-debug](http://github.com/timfel/redcar-debug), the *Grand Debugging Interface*
for Redcar which I have been using for a couple of months now for my JRuby debugging needs.

It currently includes modules for GDB, JDB, RDebug and Hijack support, and it shouldn't be too hard to add
other commandline-driven debuggers to it. And because you can describe a GUI for something best with pictures
I have some moving pictures for you, too:

<video src="/videos/redcar-debug-demo.mp4" controls="controls" width="600px">
Sorry. Your browser does not support the video tag.
Get a [decent](http://getfirefox.com) [browser](http://www.google.com/chrome)
</video>
_Update_
The video wasn't working for some people, so here's a plain [link](/videos/redcar-debug-demo.mp4)
