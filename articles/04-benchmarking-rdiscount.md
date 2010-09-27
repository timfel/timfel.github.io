date: 2010-08-14
title: Benchmarking RDiscount

The last benchmarks I posted, running Thin, were rather unfair 
against Rubinius (as Evan has pointed out). Time has passed 
in which I have been busy getting more specs to pass (only 8 failures 
and 2 errors are left) and I have found another gem with a benchmarking 
script for me  to run ;) The RDiscount gem which implements Markdown in C.

I just ran `rake build benchmark` on Ree (2010.02), Rubinius (1.0.1 20100603) 
and the JRuby cext branch and got these numbers:

<table>
  <tr><thead>JRuby</thead></tr>
  <tr>
    <td><strong>BlueCloth:</strong></td>
    <td>07.433000s total time</td>
    <td>00.074330s average</td>
  </tr>
  <tr>
    <td><strong>RDiscount:</strong></td>
    <td>00.124000s total time</td>
    <td>00.001240s average</td>
  </tr>
  <tr>
    <td><strong>Maruku:</strong></td>
    <td>11.619000s total time</td>
    <td>00.116190s average</td>
  </tr>
</table>
</br>
<table>
  <tr><thead>Ree</thead></tr>
  <tr>
    <td><strong>BlueCloth:</strong></td>
    <td>08.029169s total time</td>
    <td>00.080292s average</td>
  </tr>
  <tr>
    <td><strong>RDiscount:</strong></td>
    <td>00.046740s total time</td>
    <td>00.000467s average</td>
  </tr>
  <tr>
    <td><strong>Maruku:</strong></td>
    <td>06.500247s total time</td>
    <td>00.065002s average</td>
  </tr>
</table>
</br>

<table>
  <tr><thead>Rubinius</thead></tr>
  <tr>
    <td><strong>BlueCloth:</strong></td>
    <td>00.062746s total time</td>
    <td>00.000627s average</td>
  </tr>
  <tr>
    <td><strong>RDiscount:</strong></td>
    <td>00.056345s total time</td>
    <td>00.000563s average</td>
  </tr>
  <tr>
    <td><strong>Maruku:</strong></td>
    <td>21.178625s total time</td>
    <td>00.211786s average</td>
  </tr>
</table>
</br>

It's clear how Ree is fastest with the C extension, but Rbx is not much behind.
And even though JRuby's cext implementation seems to be around 3 times slower 
for RDiscount than the other implementations, it's still almost 60times faster than BlueCloth and around 90times
faster than Maruku (compared to 1/171/139 on Ree and 1/1/375 on Rbx for RDiscount/BlueCloth/Maruku).

Also note how Ree is the only one where Maruku is actually fast and also how __bloody fast__ BlueCloth runs on __Rubinius__!

So while the cext support for JRuby is comparatively slow, there are clearly cases where 
it might yield a performance gain.

