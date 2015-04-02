# Hello there, stranger.

## About
This is a log of things I learn, experiment with, or think about.
There isn't an intended audience.

## 20150401 - 1427927658
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
- `w3m https://aoeu.github.io'

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

