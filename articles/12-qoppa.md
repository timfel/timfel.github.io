date: 2012-08-27
title: Qoppa: a language to learn about Fexpr's

## Qoppa: a language to learn about Fexpr's

Recently, I gave a talk at [Fun Club
Berlin](http://www.meetup.com/thefunclub/) about Fexpr's. I had only
recently heard about those and worked myself through a
[blogpost](http://mainisusuallyafunction.blogspot.de/2012/04/scheme-without-special-forms.html)
describing a minimal language, *Qoppa*, that uses only Fexpr's and has
no other sepcial forms. The author then built a library on top of
Qoppa that implemented enough of Scheme to implement Qoppa on top of
that again.

To do is to understand, so I implemented a Qoppa AST interpreter with
Scheme syntax on top of [PyPy]
[PyPy](http://doc.pypy.org/en/latest/coding-guide.html), using the
parser and much of the object model (as much as there is) from
lang-scheme. You can find the [code on
GitHub](https://github.com/timfel/qoppy), if you're interested. I'm
going to talk about my experiences with PyPy in a later post, so
suffice it to say that the generated binary is reasonably fast, even
though I haven't really thought about optimizing anything.

So, if you're interested in the *What* and *Why* of Fexprs, go read
Keegan McAllister's
[blogpost](http://mainisusuallyafunction.blogspot.de/2012/04/scheme-without-special-forms.html)
and look also at his Scheme implementation on
[GitHub](https://github.com/kmcallister/qoppa). I described some of
his explanations in my talk, and the screenshots of the "slides" I had
are also
[available](https://github.com/timfel/qoppy/raw/fexpr-presentation/presentation_to_pdf.pdf).
