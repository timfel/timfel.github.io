date: 2015-09-25
title: PhD Thesis Progress

## Babelsberg

I am writing my dissertation on [Babelsberg](https://github.com/babelsberg/), a
family of language experiments and that implement a design for adding constraint
solving and automatically maintained assertions to ordinary object-oriented
languages. You know how you sometimes write `assert
some.code.that.calls(stuff)`. And if your assertion fails, you crash? In
Babelsberg, you can write `always some.code.that.calls(stuff)`, and rather than
crashing directly, the system will attempt to "heal" the program state to make
the assertion pass (if it doesn't already). This works great more often than you
would think, and sometimes it even completely frees you from writing the code to
establish a correct state in the first place! Just let the system deal with it -
a Sudoku solver? No problem, I know what a valid solution should look like, I
can just `always` that. Load balancing for video streaming, automatic repair of
partially downloaded image data, layouting. We've found a number of interesting
applications.

<iframe src="https://dl.dropboxusercontent.com/u/26242153/phdthesis/index.html"
       width="100%"
       height="1600px"
       style="border: none; overflow: hidden" />
