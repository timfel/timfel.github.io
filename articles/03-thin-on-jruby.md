date: 2010-07-13
title: Thin on JRuby

After much work from Wayne Meissner and myself I have
managed to get the Thin webserver running on JRuby. 
It actually loaded for a couple of weeks or so already,
but only recently stopped crashing when receiving a request. 
Today I have managed to get it to serve pages as well, so 
I guess it's time for some speed checking :)

The tests are just quickly done using ab and were run on REE 2010.02,
JRuby Head on the cext branch and Rubinius 1.0.0-20100514. I 
did 1000 requests at different concurrency levels and checked the 
average req/s. 

The numbers
-----------
<table cellspacing="10" width="75%">
<thead>
<td>concurrency</td>
<td>REE</td>
<td>JRuby</td>
<td>Rubinius</td>
</thead>
<tr><td>1</td><td>3102</td><td>298</td><td>214</td></tr>
<tr><td>11</td><td>3563</td><td>521</td><td>544</td></tr>
<tr><td>21</td><td>4836</td><td>584</td><td>754</td></tr>
<tr><td>31</td><td>3402</td><td>668</td><td>728</td></tr>
<tr><td>41</td><td>5056</td><td>686</td><td>486</td></tr>
<tr><td>51</td><td>4025</td><td>672</td><td>797</td></tr>
<tr><td>61</td><td>5427</td><td>1046</td><td>704</td></tr>
<tr><td>71</td><td>3874</td><td>1080</td><td>736</td></tr>
<tr><td>81</td><td>5249</td><td>947</td><td>685</td></tr>
<tr><td>91</td><td>3919</td><td>678</td><td>579</td></tr>
</table>

<br/>
As we can see, JRuby starts something like 15x slower than 
REE and only recovers to about 4 times slower with a concurrency 
of 71. It is generally faster than Rubinius, though. This is 
not a fair comparison, though, as JRuby has a Java implementation
of EventMachine.

Apart from that, overall coverage of the C API specs is getting 
better, too. Currently out of the 348 examples, 26 fail
and 110 throw errors. Failures are mostly incomplete implementations
of Ruby functions, errors are almost exclusively missing functions.
