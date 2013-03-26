jquery.caret
============

Get caret postion or offset from inputor

This is the core function that working in [At.js](http://ichord.github.com/At.js).  
Now, It just become an simple jquery plugin so that everybody can use it.  
And, of course, **At.js** is using this plugin too.

Usage
=====

```javascript

// Get caret position
$('#inputor').caret('position'); // => {left: 15, top: 30, height: 20}

// Get caret offset
$('#inputor').caret('offset'); // => {left: 300, top: 400, height: 20}

var fixPos = 20

// Get position of the 20th char in the inputor.
$('#inputor').caret('position', fixPos);

// Get offset of the 20th char
$('#inputor').caret('offset', fixPos);

// more

// Get caret position from first char in inputor.
$('#inputor').caret('pos'); // => 15

// Set caret position from first char in inputor.
$('#inputor').caret('pos', 15);

```
