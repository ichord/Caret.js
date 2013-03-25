jquery.caret
============

Get caret postion of offset from inputor

Usage
=====

```javascript

// Get caret position
$('#inputor').caret('position'); // => {left: 15, top: 30, height: 20}

// Get caret offset
$('#inputor').caret('offset'); // => {left: 300, top: 400, height: 20}

// more

// Get caret position from first char in inputor.
$('#inputor').caret('pos'); // => 15

// Set caret position from first char in inputor.
$('#inputor').caret('pos', 15);

```
