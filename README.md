Instant pair programming, just add web!
=======================================

PairJS is basically a supercharged, live collaborative editing equivalent of `python -m SimpleHTTPServer`. You pick a directory and it will not only serve up static files as a web server, but also give you and anyone else on your network access to edit those files via the handsome [Ace editor](http://ace.ajax.org). Better still, all that editing can happen concurrently, with no messy locks or conflicts, thanks to the unfathomable voodoo of [ShareJS](http://sharejs.org).

All files are saved back to your disk when they're edited so you can share something you're working on with a friend or coworker, edit it collaboratively, and then just `git commit` (or whatever) the files when you're done. Open one window to edit some html and another for a live-updating view of the result. Open two editors and argue with yourself. Go crazy! The world is your highly concurrent oyster.

I like your buzzwords, how can I get some of them?
--------------------------------------------------

Assuming you have [nodejs](http://nodejs.org) installed, just run this:

```shell
$ npm install pairjs
```

And once the slobbering dependency behemoth is satisfied, do this:

```shell
$ cd WHEREVER_I_WANT_GOSH
$ pairjs
```

Then go here: [http://localhost:8000/](http://localhost:8000/)


A brief note because I'll feel bad if you wreck all your files
--------------------------------------------------------------

Hey, don't wreck all your files!

A longer note because the first one wasn't very useful
------------------------------------------------------

There is currently no auth. Edits are limited to the directory you provide, but giving someone access to write arbitrary data to in a place you care about is inherently dangerous. There are no backups, so you should only use this in directories that are under source control or full of files that you never liked anyway. Your files will be accessible to anyone who can connect to your ip, so, y'know, if you see a guy with a handlebar moustache and devious eyes giving you that "I'm stealing your database passwords right out of your config file" grin from the other side of your favourite coffeeshop, don't come to me all like "you didn't tell me this would happen". Yes I did! Just then!

