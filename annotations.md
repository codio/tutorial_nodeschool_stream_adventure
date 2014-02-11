@annotation:tour beep_boop
#1. Beep Boop
Just to make sure everything is working, just write a `program.js` that outputs
the string "beep boop" with a `console.log()`.

@annotation:tour meet_pipe
#2. Meet Pipe
##Challenge
You will get a file as the first argument to your program `(process.argv[2])`.

Use [`fs.createReadStream()`](http://nodejs.org/api/fs.html#fs_fs_createreadstream_path_options) to pipe the given file to `process.stdout`. 

`fs.createReadStream()` takes a file as an argument and returns a readable stream that you can call `.pipe()` on. Here's a readable stream that pipes its data to `process.stderr`:

    var fs = require('fs');
    fs.createReadStream('data.txt').pipe(process.stderr);

Your program is basically the same idea, but instead of `'data.txt'`, the filename comes from `process.argv[2]` and you should pipe to stdout, not stderr.


@annotation:tour input_output
#3. Input Output
##Challenge
Take data from `process.stdin` and pipe it to `process.stdout`.

With `.pipe()`. `process.stdin.pipe()` to be exact.

Don't overthink this.


@annotation:tour transform
#4. Transform
##Challenge
Convert data from `process.stdin` to upper-case data on `process.stdout` using the [`through`](https://npmjs.org/package/through) module.

##Explanation
Make sure to `npm install through` in the directory where your solution file lives.

`through(write, end)` returns a readable/writable stream and given `write` and `end` functions, both of which are optional.

When you call `src.pipe(dst)` on some stream `dst` created with `through()`, the `write(buf)` function will be called when data from `src` is available. 

When `src` is done sending data, the `end()` function is called. Inside the `write` and `end` callbacks, `this` is set to the through stream returned by `through()` so you can just call `this.queue()` inside the callbacks to transform data.

When you specify a falsy value for the `write` argument, this function is used to pass input data directly through to the output unmodified:

    function write (buf) { this.queue(buf) }
 
The `this.queue(null)` tells the consuming stream to not expect any more data.

The default `end` function is just:

    function end () { this.queue(null) }

For example, here is a program that fires the `write(buf)` and `end()` callbacks by calling `.write()` and `.end()` manually:

    var through = require('through');
    var tr = through(write, end);
    tr.write('beep\n');
    tr.write('boop\n');
    tr.end();
    
    function write (buf) { console.dir(buf) }
    function end () { console.log('__END__') }

Instead of calling `console.dir(buf)`, your code should use `this.queue()` in your `write()` function to output upper-cased data.

Don't forget to feed data into your stream from stdin and output data from stdout, which should look something like:

    process.stdin.pipe(tr).pipe(process.stdout);

Note that the chunks you will get from `process.stdin` are Buffers, not strings. You can call `buf.toString()` on a Buffer to get a string and strings can do `.toUpperCase()`.


@annotation:tour lines
#5. Lines
##Challenge
Instead of transforming every line as in the previous "INPUT OUTPUT" example, for this challenge, convert even-numbered lines to upper-case and odd-numbered lines to lower-case. Consider the first line to be odd-numbered. For example given this input:

    One
    Two
    Three
    Four

Your program should output:

    one
    TWO
    three
    FOUR

##Explanation
Make sure to `npm install split through` in the directory where your solution file lives.

You can use the [`split`](https://npmjs.org/package/split) module to split input by newlines. For example:

    var split = require('split');
    process.stdin
        .pipe(split())
        .pipe(through(function (line) {
            console.dir(line.toString());
        }))
    ;

Will buffer and split chunks on newlines before you get them. For example, for the `split.js` we just wrote we will get separate events for each line even though the data probably all arrives on the same chunk:

    $ echo -e 'one\ntwo\nthree' | node split.js
    'one'
    'two'
    'three'

Your own program should use `split` in this way, but you should transform the input and pipe the output through to `process.stdout`.


@annotation:tour concat
#6. Concat
##Challenge
You will be given text on process.stdin. Buffer the text and reverse it using the [`concat-stream`](https://npmjs.org/package/concat-stream) module before writing it to stdout.

##Explanation
Make sure to `npm install concat-stream` in the directory where your solution file is located.

`concat-stream` is a write stream that you can pass a callback to to get the complete contents of a stream as a single buffer. Here's an example that uses concat to buffer POST content in order to JSON.parse() the submitted data:

    var concat = require('concat-stream');
    var http = require('http');
    
    var server = http.createServer(function (req, res) {
        if (req.method === 'POST') {
            req.pipe(concat(function (body) {
                var obj = JSON.parse(body);
                res.end(Object.keys(obj).join('\n'));
            }));
        }
        else res.end();
    });
    server.listen(5000);

In your adventure you'll only need to buffer input with `concat()` from process.stdin.


@annotation:tour http_server
#7. HTTP Server
##Challenge
In this challenge, write an http server that uses a through stream to write back the request stream as upper-cased response data for POST requests.

##Explanation
Make sure to `npm install through` in the directory where your solution file lives.

Streams aren't just for text files and stdin/stdout. Did you know that http request and response objects from node core's [`http.createServer()`](http://nodejs.org/api/http.html#http_http_createserver_requestlistener) handler are also streams?

For example, we can stream a file to the response object:

    var http = require('http');
    var fs = require('fs');
    var server = http.createServer(function (req, res) {
        fs.createReadStream('file.txt').pipe(res);
    });
    server.listen(process.argv[2]);

This is great because our server can response immediately without buffering everything in memory first.

We can also stream a request to populate a file with data:

    var http = require('http');
    var fs = require('fs');
    var server = http.createServer(function (req, res) {
        if (req.method === 'POST') {
            req.pipe(fs.createWriteStream('post.txt'));
        }
        res.end('beep boop\n');
    });
    server.listen(process.argv[2]);

You can test this post server with curl:

    $ node server.js 8000 &
    $ echo hack the planet | curl -d@- http://localhost:8000
    beep boop
    $ cat post.txt
    hack the planet

Your http server should listen on the port given at `process.argv[2]` and convert the POST request written to it to upper-case using the same approach as the TRANSFORM example.

As a refresher, here's an example with the default through callbacks explicitly defined:

    var through = require('through')
    process.stdin.pipe(through(write, end)).pipe(process.stdout);
    
    function write (buf) { this.queue(buf) }
    function end () { this.queue(null)

Do that, but send upper-case data in your http server in response to POST data.


@annotation:tour http_client
#8. HTTP Client
##Challenge
Send an HTTP POST request to `http://localhost:8000` and pipe `process.stdin` into it. Pipe the response stream to process.stdout.

##Explanation
Make sure to [`npm install request`](https://npmjs.org/package/request) in the directory where your solution file lives.

Here's an example of how to use the `request` module to send a GET request, piping the result to stdout:

    var request = require('request');
    request('http://beep.boop:80/').pipe(process.stdout);

To make a POST request, just call `request.post()` instead of `request()`:

    var request = require('request');
    var r = request.post('http://beep.boop:80/');
    
The `r` object that you get back from `request.post()` is a readable+writable stream so you can pipe a readable stream into it (`src.pipe(r)`) and you can pipe it to a writable stream (`r.pipe(dst)`).

You can even chain both steps together: `src.pipe(r).pipe(dst);`

For your code, src will be process.stdin and dst will be `process.stdout`.


@annotation:tour websockets
#9. Websockets
##Challenge
In this adventure, write some browser code that uses the [websocket-stream module](https://npmjs.org/package/websocket-stream) to print the string "hello\n".

##Explanation
Make sure to `npm install websocket-stream` in the directory where your solution file lives.

Your solution file will be compiled with browserify and the verify script will prompt you to open `http://localhost:8000` in a browser to verify your solution.

To open a stream with websocket-stream on localhost:8000, just write:

    var ws = require('websocket-stream');
    var stream = ws('ws://localhost:8000');
   
Then write the string "hello\n" to the stream and end the stream.

The readme for websocket-stream has more info if you're curious about how to write the server side code: [https://github.com/maxogden/websocket-stream](https://github.com/maxogden/websocket-stream)


@annotation:tour html_stream
#10. HTML Stream
##Challenge
Your program will get some html written to stdin. Convert all the inner html to upper-case for elements with a class name of "loud".

You can use [`trumpet`](https://npmjs.org/package/trumpet) and [`through`](https://npmjs.org/package/through) to solve this adventure.

##Explanation
Make sure to `npm install trumpet through` in the directory where your solution file lives.

With `trumpet` you can create a transform stream from a css selector:

    var trumpet = require('trumpet');
    var fs = require('fs');
    var tr = trumpet();
    fs.createReadStream('input.html').pipe(tr);
    
    var stream = tr.select('.beep').createStream();

Now `stream` outputs all the inner html content at `'.beep'` and the data you write to `stream` will appear as the new inner html content.

@annotation:tour duplexer
#11. Duplexer
##Challenge
Write a program that exports a function that spawns a process from a `cmd` string and an `args` array and returns a single duplex stream joining together
the stdin and stdout of the spawned process:

    var spawn = require('child_process').spawn;
    
    module.exports = function (cmd, args) {
        // spawn the process and return a single stream
        // joining together the stdin and stdout here
    };

There is a very handy module you can use here: duplexer. The duplexer module exports a single function `duplexer(writable, readable)` that joins together a
writable stream and readable stream into a single, readable/writable duplex stream.

If you use duplexer, make sure to `npm install duplexer` in the directory where your solution file is located.



@annotation:tour duplexer_redux
#12. Duplexer Redux
##Challenge
In this example, you will be given a readable stream, `counter`, as the first argument to your program:

    module.exports = function (counter) {
        // return a duplex stream to capture countries on the writable side
        // and pass through `counter` on the readable side
    };

Return a duplex stream with the `counter` as the readable side. You will be written objects with a 2-character `country` field as input, such as these:
 
    {"short":"OH","name":"Ohio","country":"US"}
    {"name":"West Lothian","country":"GB","region":"Scotland"}
    {"short":"NSW","name":"New South Wales","country":"AU"}

Create an object to keep a count of all the countries in the input. Once the input ends, call `counter.setCounts()` with your country counts.

The `duplexer` module will again be very handy in this example.

If you use duplexer, make sure to `npm install duplexer` in the directory where your solution file is located.


@annotation:tour combiner
#13. Combiner
##Challenge
Write a module that returns a readable/writable stream using the `stream-combiner` module. You can use this code to start with:

    var combine = require('stream-combiner')
    
    module.exports = function () {
        return combine(
            // read newline-separated json,
            // group books into genres,
            // then gzip the output
        )
    }
 
Your stream will be written a newline-separated JSON list of science fiction genres and books. All the books after a `"type":"genre"` row belong in that
genre until the next `"type":"genre"` comes along in the output.

    {"type":"genre","name":"cyberpunk"}
    {"type":"book","name":"Neuromancer"}
    {"type":"book","name":"Snow Crash"}
    {"type":"genre","name":"space opera"}
    {"type":"book","name":"A Deepness in the Sky"}
    {"type":"book","name":"Void"}
    
Your program should generate a newline-separated list of JSON lines of genres, each with a `"books"` array containing all the books in that genre. The input
above would yield the output:

    {"name":"cyberpunk","books":["Neuromancer","Snow Crash"]}
    {"name":"space opera","books":["A Deepness in the SKy","Void"]}

Your stream should take this list of JSON lines and gzip it with `zlib.createGzip()`.

* HINTS *

The `stream-combiner` module creates a pipeline from a list of streams, returning a single stream that exposes the first stream as the writable side and
the last stream as the readable side like the `duplexer` module, but with an arbitrary number of streams in between. Unlike the `duplexer` module, each
stream is piped to the next. For example:

    var combine = require('stream-combiner');
    var stream = combine(a, b, c, d);
    
will internally do `a.pipe(b).pipe(c).pipe(d)` but the `stream` returned by `combine()` has its writable side hooked into `a` and its readable side hooked
into `d`.

As in the previous LINES adventure, the `split` module is very handy here. You can put a split stream directly into the stream-combiner pipeline.

If you end up using `split` and `stream-combiner`, make sure to install them into the directory where your solution file resides by doing:

    npm install stream-combiner split




@annotation:tour crypt
#14. Crypt
##Challenge
Your module will be given a passphrase on `process.argv[2]` and `aes256` encrypted data will be written to stdin.

Simply decrypt the data and stream the result to `process.stdout`.

##Explanation
You can use the [`crypto.createDecipher()`](http://nodejs.org/api/crypto.html#crypto_crypto_createdecipher_algorithm_password) api from node core to solve this challenge. Here's an example:

    var crypto = require('crypto');
    var stream = crypto.createDecipher('RC4', 'robots');
    stream.pipe(process.stdout);
    stream.write(Buffer([ 135, 197, 164, 92, 129, 90, 215, 63, 92 ]));
    stream.end();

Instead of calling `.write()` yourself, just pipe stdin into your decrypter.


@annotation:tour secretz
#15. Secretz
##Challenge
An encrypted, gzipped tar file will be piped in on process.stdin. To beat this challenge, for each file in the tar input, print a hex-encoded md5 hash of the file contents followed by a single space followed by the filename, then a newline.

You will receive the cipher name as `process.argv[2]` and the cipher passphrase as `process.argv[3]`. You can pass these arguments directly through to [`crypto.createDecipher()`](http://nodejs.org/api/crypto.html#crypto_crypto_createdecipher_algorithm_password).

##Explanation
Make sure to `npm install tar through` in the directory where your solution
file lives.

The built-in [zlib library](http://nodejs.org/api/zlib.html#zlib_zlib) you get when you `require('zlib')` has a [`zlib.createGunzip()`](http://nodejs.org/api/zlib.html#zlib_zlib_creategunzip_options) that returns a stream for gunzipping.

The [`tar`](https://www.npmjs.org/package/tar) module from npm has a `tar.Parse()` function that emits `'entry'` events for each file in the tar input. Each `entry` object is a readable stream of the file contents from the archive and:

`entry.type` is the kind of file ('File', 'Directory', etc)
`entry.path` is the file path

Using the tar module looks like:

    var tar = require('tar');
    var parser = tar.Parse();
    parser.on('entry', function (e) {
        console.dir(e);
    });
    var fs = require('fs');
    fs.createReadStream('file.tar').pipe(parser);

Use `crypto.createHash('md5', { encoding: 'hex' })` to generate a stream that 
outputs a hex md5 hash for the content written to it.







