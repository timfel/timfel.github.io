date: 2015-04-10
title: RSqueak/VM - A research VM for Squeak/Smalltalk

## RSqueak/VM - A research VM for Squeak/Smalltalk

For the past few years, [we](https://github.com/HPI-SWA-Lab/RSqueak)
have been quietly working on RSqueak/VM, an RPython-based VM for
[Squeak/Smalltalk](http://www.squeak.org). The VM is still under
development, mostly in short bursts and pushes, but is beginning to be
useable and shows promising results.

RSqueak/VM grew out of the
[SpyVM](http://dx.doi.org/10.1007/978-3-540-89275-5_7) work done by
[Carl Friedrich Bolz](https://twitter.com/cfbolz),
[Adrian Kuhn](https://twitter.com/akuhn),
[Adrian Lienhard](https://twitter.com/adrianlienhard), Nicholas
D. Matsakis, [Oscar Nierstrasz](https://twitter.com/onierstrasz),
[Lukas Renggli](https://twitter.com/renggli), Armin Rigo, and Toon
Verwaest, but has since been extended by Lars Wassermann,
[Anton Gulenko](https://twitter.com/anton_gulenko),
[Tobias Pape](https://twitter.com/krono), and myself.

We have done many interesting experiments with RSqueak/VM, including
using
[STM](http://morepypy.blogspot.de/2014/08/a-field-test-of-software-transactional.html),
[strategies](http://morepypy.blogspot.de/2011/10/more-compact-lists-with-list-strategies.html),
and most recently we have attempted to get performance up to run as
many primitives as possible in pure Smalltalk, including such
primitives used for large integer arithmetic, string operations,
TrueType font rendering, bézier curves, display compositing, and
more. We are not quite there yet for an alpha release, but a
[set of benchmarks](http://smalltalkhub.com/#!/~StefanMarr/SMark) we
ran today show that we are getting close :)

![SMark](/public/images/rsqueak-smark.png)
