// @annotation:tour http_client
// 
// <-- click the blue icon in the gutter 
//     for instructions on this lesson
// 
// The README.md file contains complete instructions
// for using these tutorials.
// Then just start coding away in this file

var request = require('request');
var r = request.post('http://localhost:8000');
process.stdin.pipe(r).pipe(process.stdout);
