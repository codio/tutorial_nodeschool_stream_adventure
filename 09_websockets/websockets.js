// @annotation:tour websockets
// 
// <-- click the blue icon in the gutter 
//     for instructions on this lesson
// 
// The README.md file contains complete instructions
// for using these tutorials.
// Then just start coding away in this file
var ws = require('websocket-stream');
var stream = ws('ws://localhost:3000');
stream.end('hello\n');

