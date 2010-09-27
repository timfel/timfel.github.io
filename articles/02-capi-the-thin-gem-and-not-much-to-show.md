date: 2010-07-09
title: JRuby commit flag

Mid-term is almost upon and there are quite a few notable 
changes, but not much to show.

If have spent most of my time getting various gems to compile. 
Upon a request from konstantinhaase/rkh I looked into getting
the Thin webserver to run. After some tinkering it compiled and
ran. Benchmarks run, too, but print no numbers (they don't with
REE, either, at least for me). I tried running this very blog 
with Thin on JRuby, it won't process requests right now, though.
This is probably a problem with my rb_str* method implementations.
I am still looking into this.

Apart from that I have gotten the official C-Api specs to run. The 
changes needed are at timfel/rubyspec. Also, I have been given commit
access to the main repository at jruby.org. The cext branch is now 
the playground for Wayne Meissner and me. While Wayne is focussing on 
speed and synchronization, I am more focused on getting gems to run, 
no matter how. I don't expect any speed wonders from this C-Api anytime 
soon.

