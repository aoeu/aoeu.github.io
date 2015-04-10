# Hello there, stranger.

## About
This is a log of things I learn, experiment with, or think about.
There isn't an intended audience.


## 1428707143 - 20150410

I resurrected some years-old code based in d3, which has resulted 
in pursuit of time-series data in a couple specific domains.

The fun part, however, is colors. Lots of colors!!

I ported and rewrote some older golang code that calculates 
colors in HSL format and dumps them on a web page for previewing:

```
$ ./gencolors -num 7 -preview 
```
<div style='text-align: center; width: 64px; height: 64px; display: inline-block; background-color: #f20c42;'>#f20c42</div>

<div style='text-align: center; width: 64px; height: 64px; display: inline-block; background-color: #f2d107;'>#f2d107</div>

<div style='text-align: center; width: 64px; height: 64px; display: inline-block; background-color: #4ef2cc;'>#4ef2cc</div>

<div style='text-align: center; width: 64px; height: 64px; display: inline-block; background-color: #0cf28f;'>#0cf28f</div>

<div style='text-align: center; width: 64px; height: 64px; display: inline-block; background-color: #0c8ff2;'>#0c8ff2</div>

<div style='text-align: center; width: 64px; height: 64px; display: inline-block; background-color: #4e0cf2;'>#4e0cf2</div>

<div style='text-align: center; width: 64px; height: 64px; display: inline-block; background-color: #f20cd1;'>#f20cd1</div>
	

This lead to some digging around with how the python `colorsys` module
is implemented, and how to escape potentially unsafe CSS or HTML in 
Go's html/template package. (Hint: supply a function map to the 
template before executing.) 

The resulting colors themselves are pretty useless. 
Colors with marginally different hue settings in HSL 
can have very little perceivable difference, and the 
algorithms don't consider persons with color-blindness.
They look kind of pretty on a web page, though.

I found some stock color sets ("alphabets") from a couple research articles 
that look more promising. I'll add these into the library as well as 
constants. There's not really a goal for the library other than to 
document what I'm learning as I go, and maybe provide usage for someone
else since it is open source.

## 1428497189 - 20150408

I accidentally filled up my Chromebook hard drive pulling down docker 
(with the intention of trying out the golang mobile stuff for android).
I couldn't log into my main user account anymore!!

I ended up getting in through the Guest log in, opening crosh in the browser,
and purging some bigger directories... one of them being the emacs source 
( ~600mB ) and another being android-studio ( > ~700mB ).  Not surprisingly, 
android-studio binaries are bigger than the entire emacs git repository. 
Both directories are huge. +1 for line editors.

I ended up getting more low-profile USB 3 drives to mitigate, which lead to
[some](https://twitter.com/tmcdemus/status/585490679339610113) 
[discussions](https://twitter.com/tmcdemus/status/585495257242021888) about
what filesystem to format the drives with.

I'll try one of the drives out as btrfs since that's supported in back-ports.
Chrome OS itself will not recognize that drive, but that might be a feature.

ext4 is the reasonable choice - it is supported out-of-the-box on 
any linux distro I can think of (and therefore is present on live-boot images).

## 1428410883 - 20150407

Over the weekend, I wrote a simple HTTP request header and body 
"echoer" in golang. I went through a couple refactors thanks
to Jay giving me some code review.

I may have found a bug in the standard libraries.

I ended up pulling down the Go source on another machine and doing
some experiments back and forth between the two.
I wanted to confirm that the problem wasn't from me running the program
on localhost. Something does seems wrong.

I think the next step would be searching around the code base
and see what else calls the relevant function... maybe the documentation
is wrong, or maybe my usage is wrong, or maybe there really is a bug
and this function should check for zero values and provide defaults
based on what it does next. 

## 1428025541 - 20150402

Today, I learned some security things over lunch with someone.
They were nice enough to answer a bunch of questions I had about 
that part of the field. It is less of a blackbox, at least.

In the evening, I paired with someone on crypto exercises in golang.
That was fun and relatively productive.
We found bugs in the exercise.

I shared with a person that is new to golang how to use interfaces 
and struct composition in Go with some code I wrote:

- [interface example](https://play.golang.org/p/5rQ7LgR3Wl)
- [struct composition example](http://play.golang.org/p/orGE20_VSk)

It seems like the person found it helpful.
That made me feel productive, and I can imagine what the language 
must look like if you're coming from python and not C / C++/ J*va.
It is nice to help dispell some of the things that confused me, too.

## 1427983169 - 20150402

I fell asleep while pulling down GCC on Arch on the Pi, but 
I was able to successfully compile a program using portmidi on the Pi
this morning.

I was also able to cross compile a program for ARM 6 / Arch on 
from a debian instance. I recompiled Go 1.5 with CGO enabled,
but I forgot that I also need some mechanism to cross compile 
the C for ARM 6 / Arch also! That's a project for later.

## 1427944190 - 20150401
I've learned and tweaked a few things.

- In vim, use `set shell=/bin/sh` to set a specific shell.
- In vim, `:r !./tools/timestamp` now creates a timestamp.
- I'm ditching pandoc for "blackfriday"
-- blackfriday does just markdown to HTML conversion (do one thing and one thing well) vs. pandoc, which converts many formats to many others.
-- blackfriday is written in Go, so I currently will be able to edit it more easily than pandoc, which is written in Haskell.
- I added a Makefile to make building a little easier.

blackfriday is also the first thing I built with Go 1.5 pre-release, using 
[Dave Cheney's instructions](http://dave.cheney.net/2015/03/03/cross-compilation-just-got-a-whole-lot-better-in-go-1-5)
as a reference.
I just compiled and bootstrapped Go 1.5 a bit ago.
The goal is to cross compile for ARM 6 so I can run some golang 
sound generating programs on the Raspberry Pi Arch Linux installation 
I set up last night.

Earlier tonigt, bcgraham and I also got some bug fixes 
and enhancements merged into 
http://github.com/aoeu/mta, and we can deployed to http://mta.today.
The result is pretty nice to use from `w3m` since the tables and
and everything get rendered correctly now.


## 1427927658 - 20150401
I moved the markdown file from the llog repository into a github pages repostiory.  
I've been thinking about doing something like this for a while - I gets lots of ideas of things to jot down and write, but I'd like the simplest possible mechanisms to author and publish.  

I've added some complexity by relying on pandoc to generate an HTML page file from the markdown, but this seems simpler than using some of the other popular tools out there.

All I did was:

- Create a repostiory on github called `aoeu.github.io`
- `git clone https://github.com/aoeu/aoeu.github.io.git`
- `git clone https://github.com/aoeu/llog.git`
- `git remote add master master`
- `git pull master master`
- `ls -a llog.md`
- `git remote rm master`
- `pandoc -s llog.md -o index.html`
- `git push origin master`
- `w3m https://aoeu.github.io`

I'd rather get something even simpler in place, but this setup will do for now.

## 1421676983 - 20150119
An idiom for logging to Standard Error and exiting with error status in golang:
- `log.Fatal("an error explanation")` will log to standard error and exit.
- You can remove the "timestamp" prefix of the log message with `log.SetFlags(0)`
- You can set a custom prefix with `log.SetPrefix(someString + ": ")`

Also, Go's `net/url.Parse` is just wrapping and calling `net/url.ParseRequestURI` and bypassing some of the latter's error checking.
(`ParseRequestURI` is intended for full URI's specifiying an encoding, etc.)

## 20141026
- Install crouton / i3
- Install java, newer than version 6. Try something like: 
-- `sudo apt-get install openjdk-7-jdk'
-- `sudo update-alternatives --config java`
- Download Android Studio: https://developer.android.com/sdk/installing/studio.html
- `tar xzvf android-studio-bundle-135.1339820-linux.tgz`
- `cd android-studio/bin; ./studio.sh`

Waiting for Java to insall, gradle to get dependencies, and Android Studio takes some time.

Other light amounts of magic I required:
Set X to run from regular users: ```
sudo ed /etc/X11/Xwrapper.config 
,s/console/anybody/
wq
```
For weird libstdc++6.so errors from `adb` : `sudo apt-get install lib32stdc++6 lib32z1 lib32z1-dev`



## 20141012
Today, I'm thinking about email hygeine. 
The idea here is to remove oneself from mailing lists or other uneccessary,
noisey messages. 

I haven't thought of a great way to do this yet programatically.

One possible algorithm or method:
- Open your mail box.
- Go through every message for a day (or part of day).
- Click unsubscribe on noisey, unecessary mail messages.

## 20140904 : 1409869214

### Today, I thought about primitive alternatives to `pbcopy`
If you're using OS X, you can move data from the terminal to the clipboard with 
the `pbcopy` command.  If you have X, you can use `xclip`.

A way that I like better is using temporary files:
- `date > /tmp/today.txt` Append some arbitrary data to a text file (instead of a clipboard).
- `vim some_file.txt` Edit an arbitrary file.
-  `:r /tmp/today.txt` Insert the data from the arbitary after the current cursorline.

Appending text may have been a more reasonable alternative:
`date >> some_file.txt`

### Today, I decided to start a blog in markdown, even if it is just local. 
I've decided to call it a "llog".

### Today, I firewalled a new server.
I mostly followed instructions here: https://www.linode.com/docs/security/securing-your-server
And then I skimmed some info from the arch wiki: https://wiki.archlinux.org/index.php/iptables

