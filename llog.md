# Hello there, stranger.

## About
This is a log of things I learn, experiment with, or think about.

## [•](index.html#1485561815) 1485561815 - 20170127

At the moment, certain computers have USB-C ports while many Android devices do not.  
In attempts to not carry around [USB-C](https://en.wikipedia.org/wiki/USB-C) to [USB-Micro-B ](https://en.wikipedia.org/wiki/USB#Mini_and_micro_connectors) converters, I thought that the [Android Debug Bridge](https://en.wikipedia.org/wiki/Android_software_development#ADB) tool might be a practical replacement when run in a [wireless mode](https://developer.android.com/studio/command-line/adb.html#wireless) that utilizes TCP/IP.  

I was wrong.  

The dance to boostrasp a computer to use Android Debug Bridge to communicate wirelessly to an Android device (starting out connected via a USB cable, but unplugged after) seemed straight-ahead enough.  
I found that arbitrary pauses in between `adb` commands were required in order to allow the Android Debug Bridge server to restart or reconfigure:

```
#!/bin/sh
adb usb && \
sleep 2 && \
test `adb devices | wc -l` -gt 1 && \
TCPIP_PORT=5555 && \
sleep 2 && \
adb tcpip $TCPIP_PORT && \
sleep 2 && \
DEVICE_IP=$(adb shell ip -f inet addr show wlan0 | grep inet | sed 's/^.*\([0-9]\{3\}\.[0-9]\{3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\)\/24.*$/\1/')  && \
adb connect $DEVICE_IP:$TCPIP_PORT
```

I then found that transferring a 21 megabyte file proved to be relatiely slow:

```
$ time adb install -r molasses.apk
[100%] /data/local/tmp/molasses.apk
    pkg: /data/local/tmp/molasses.apk
Success

real    3m40.721s
```

If doing the napkin-math correctly, that's a transfer rate of  approximately 0.763 megabits per second.  

That's also an order of magnitude (11 times) slower than installing the same file over USB:

```
$ adb usb
restarting in USB mode
$ time adb install -r molasses.apk
[100%] /data/local/tmp/molasses.apk
	pkg: /data/local/tmp/molasses.apk
Success

real	0m19.989s
```

Technically, the wireless router could be part of the slow-down, but I doubt it.  
So, why is `adb` over TCP/IP so slow?

## [•](index.html#1485388140) 1485388140 - 20170125

Today I learned that certain built-in shell commands, such as `echo` and `export`, [can be validly executed on the same line](http://www.grymoire.com/Unix/Sh.html#uh-14), without a semi-colon separating the statements.
I found some resulting commands I tried out did not result in what I expected.

```
sh-3.2$ NUMS=ONE
sh-3.2$ echo $NUMS
ONE
sh-3.2$ NUMS="$NUMS, TWO" export NUMS
sh-3.2$ echo $NUMS
ONE, TWO
sh-3.2$ NUMS="$NUMS, THREE" echo $NUMS
ONE, TWO
sh-3.2$ NUMS="$NUMS, THREE" export NUMS; echo $NUMS
ONE, TWO, THREE
sh-3.2$ NUMS="$NUMS, FOUR" echo $NUMS; export NUMS
ONE, TWO, THREE
sh-3.2$ echo $NUMS
ONE, TWO, THREE
sh-3.2$ NUMS="$NUMS, FOUR"; export NUMS
sh-3.2$ echo $NUMS
ONE, TWO, THREE, FOUR
```

Additionally, the PATH environment variable automatically exports when setting it to a new value within a shell script:

```
$ cat path.sh
#!/bin/sh

overridePATH() {
	PATH='export is not required.'
}

overridePATH
echo $PATH
$ ./path.sh
export is not required.
```

## [•](index.html#1437014448) 1437014448 - 20150715

I  wanted to install a gerrit server in order to do some code review for a friend, and thought an instance on a certain cloud hosting provider could be of service.

I ended up realizing that I was locked out of the server instance. I had ssh access disabled for the root user, so adding my public SSH key to the provider's admin panel proved to be useless.

The provider features a web-browser-based VNC console, but with some limitations. The web-browser-based console can not handle copy-paste commands from the user's machine. I wasn't about to type my entire public RSA key out by hand.  A workaround was needed: 


- Reset root password on the remote server instance via an email authentication tool on the provider's host administration web-application.
- Log in as the root user on the remote server instance via the provider's web-browser-based VNC console
- Change root password (as forced by the remote server instance)
- `# su - otheruser`
- `$ mkdir ~/.ssh`
- `$ chmod 700 ~/.ssh`
- On my local machine: `$ cat ~/.ssh/id_rsa.pub`
- Paste the contents of `id_rsa.pub` into a Github gist
- Copy the raw URL of the Github gist
- Paste the raw URL of the Github gist into http://tiny.cc`s web interface
- Give the tiny.cc URL a reasonable name to type, like http://tiny.cc/publickeyfoo
- In the hosting provider's web-browser-based VNC console: `$ wget -o ~/.ssh/authorized_keys http://tiny.cc/publickeyfoo`
- `$ chmod 600 ~/.ssh/authorized_keys`
- `$ exit` to return to the root user
- `# sudo echo "PermitRootLogin no" >> /etc/ssh/ssh_config`
- On my local machine, `$ ssh otheruser@example.com` (where example.com is the hostname for my remote server instance at the hosting provider).

... And back in action. This would have been easier if the web-browser based VNC console wasn't randomly inserting control keys or otherwise locking upwhen typing all the commands!

## [•](index.html#1434415672) 1434415672 - 20150615

While peer reviewing an article involving Git packfiles, 
I found interesting usage of SHA-1 hash values.

Git hashes a `.pack` packfile with SHA-1 and then uses the hash value for 3 things:

* The hash value is as a 20-byte trailer to the `.pack` file itself for later use as a checksum.
* The hash value is used within the file name of the `.pack` file.
* The hash value is used within the file name of the corresponding `.idx` file.

I thought the usage in filenames was interesting. 

I wrote a small shell script to demonstrate it all:

```

#!/bin/sh

main() {
	cd $1/.git/objects/pack
	hash_value_in_filename=`ls pack-*.pack | sed 's/pack-\(.*\).pack/\1/'`
	hash_value_in_file=`tail -c 20 pack-*.pack | hexdump -ve '1/1 "%.2x"'`
	hash_value_of_file=`cp pack-*.pack /tmp/$$.pack && \
		chmod u+w /tmp/$$.pack && \
		truncate --size=-20 /tmp/$$.pack && \
		sha1sum /tmp/$$.pack | cut -d' ' -f1 && \
		rm /tmp/$$.pack`

	echo "File names in Git pack:"
	if test $hash_value_of_file = $hash_value_in_filename ; then 
		ls -1 pack-${hash_value_in_file}.*
	fi 
	echo "$hash_value_in_file : SHA-1 hash value within the .pack file."
	echo "$hash_value_of_file : SHA-1 hash value of the .pack file (minus the 20 byte trailer that is the previous hash.)"
	echo "$hash_value_in_filename : SHA-1 hash value in the filename itself."
	cd - >/dev/null
}

exiterr() {
	echo "usage: $0 directory_of_a_git_repository"
	exit 1
}


if test $# -ne 1 ; then exiterr; fi

if test ! -d $1/.git ; then
	echo "No git repository found in \"$1\""
	exiterr
fi

if test ! -d $1/.git/objects/pack ; then
	echo "No pack directory found in git repostiory \"$1\", run with a different repository."
	exiterr
fi

main $@
```

## [•](index.html#1433476141) 1433476141 - 20150604

If attempting to compile and configure an Apple IIe / Apple IIGS emulator for demo-running purposes,
something like the shell-script below will get things going for Linux on x86_64 processors. 

h/t @DaveyPocket for mentioning demos and helping to compile and sort through the quirks of setting up the emulator.
 

```

#!/bin/sh

main() {
  installDependencies()  && \
  getKentsEmulatedGS() && \
  buildKentsEmulatedGS_x86-64 && \
  getROMs() && \
  configureKentsEmulatedGS && \
  runEmulatorWithSound()
} 

installDependencies() {
   sudo apt-get install -y build-essentials xorg-dev pulseaudio
}

getKentsEmulatedGS() {
  wget http://kegs.sourceforge.net/kegs.0.91.tar.gz
  tar xzvf kegs.0.91.tar.gz
}

buildKentsEmulatedGS_x86-64() {
  cd kegs.0.91
  rm vars; ln -s vars_x86linux vars
  sed --in-place '5s/march=.*$/march=amdfam10/'
  make
  cd ..
}

getROMs() {
  wget http://google-for-apple-ii-gs-rom_images.za/ftp.apple.asimov.net/emulators/rom_images/appleiigs_rom01.zip
  unzip appleiigs_rom01.zip 
  cp XGS.ROM ROM
  wget http://www.ninjaforce.com/downloads/NFCDemoDrive.zip
  unzip NFCDemoDrive.zip
}

configureKentsEmulatedGS() {
  sed --in-place '9s/^s7d1 = .*$/s7d1 = NFCDemoDrive.2mg/
}

runEmulatorWithSound() {
  padsp ./xkegs
}

runEmulatorWithoutSound() {
  ./xkegs --audio 0
}

```

## [•](index.html#1432908829) 1432908829 - 20150529

I've compiled plan9port again recently, and  ran into some errors caused by missing X libraries, both in Ubuntu and Debian. 

There were other errors on Debian Jessie, but a mutual error on Ubuntu Precise was that the library header file X11/IntrinsicP.h could not be found.

The entire compilation and installation process from a  Ubuntu Precise install would be something like the following, although I've not tested it and some steps may be missing: 

```
#!/bin/sh

main() {
    # repairPackageManagerState() # only if needed.
    installBuildTools()
    installPlan9PortDependencies()
    getAndCompileAndInstallPlan9Port()
}

repairPackageManagerState() {
    sudo dpkg --configure --pending
    sudo apt-get --fix-broken install
}

installBuildTools() {
    sudo apt-get install git
    sudo apt-get install build-essential
}

installPlan9PortDependencies() {
    sudo apt-get install libxt-dev libxext-devel
}

getAndCompileAndInstallPlan9Port() {
    cd $HOME
    git clone https://github.com/9fans/plan9port
    cd plan9port
    if test ./INSTALL ; then tail -2 install.log | sed 's/^\s\+//' >> $HOME/.profile ; fi
}

main()
```

This is also the first entry I've made with the [sam](http://man.cat-v.org/plan_9/1/sam) editor, and I could certainly stand to read over the manual page for it again.
## [•](index.html#1429880922) 1429880922 - 20150424

I'm reading about [init](https://en.wikipedia.org/wiki/Init) very quickly. 
It is the first process started at boot of a Un*x system, and runs
 as a daemon until shut down.

If one types `pstree | less` on some systems, one will see `init` as the root process.

Apparently, [systemd](https://en.wikipedia.org/wiki/Systemd) is the name of several things:
"systemd is not just the name of the init daemon but also refers to the entire software bundle around it"

That "software bundle" around it, according to Wikipedia is:
- A system and service manager. (Does that mean daemons?)
- A software platform. (Also vague.)
- The glue between applications and the kernel. 

It seems like a Bad Thing that there is lots of stuff that each do very different things,
 all under one name, or at a minimum, harder to understand and communicate about.


## [•](index.html#1429620177) 1429620177 - 20150421

I spent a lot of the weekend resurrecting some older d3 code and building this thing:

- http://www.mcdem.us/climate/c02e.html
- http://github.com/aoeu/climate

The color experiments were for this.
d3 makes more sense than it used to, despite I haven't looked at it at all in the meanwhile.

It was suggested to add a slider, which I think is a good idea.


## [•](index.html#1428886299) 1428886299 - 20150412

I'm pulling some data sources I'll transform later for a project.
I'm naming target directories after *filenames* and paths from the source URIs.
e.g `~/user/repo/data/sources/example.com/path/to/archive.zip/` is a directory with files in it.
To reiterate, the `archive.zip` component is a *directory*, and not the actual
zip file. The contents of the directory are the extracted contents of the source zip file.

The idea is to have the directory be a self-documenting reference to the source file.
However, this feels like it is being clever, and not clear.
I also wonder what ill-affects it would have on an unsuspecting shell script.



## [•](index.html#1428778652) 1428778652 - 20150411

Why is `origin` the idiomatic name for a remote repository in
 most (if not all) of the git workflows that I've seen?
 Naming the only remote repository the word `origin`
 implies that the remote is the true source of the code.
 Why isn't a *local* repository the true source of 
 the code? Why not have the remote just serve as a backup? 
 Why not have *many* backups, and name your remotes things
 like `github`, `bitbucket`, `my-raspberry-pi`, or
 `some-repo-alex-pulls-from`? 
 Why not push to all those remotes simultaneously, instead of one?
  

## [•](index.html#1428707143) 1428707143 - 20150410

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

## [•](index.html#1428497189) 1428497189 - 20150408

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

## [•](index.html#1428410883) 1428410883 - 20150407

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

## [•](index.html#1428025541) 1428025541 - 20150402

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

## [•](index.html#1427983169) 1427983169 - 20150402

I fell asleep while pulling down GCC on Arch on the Pi, but 
I was able to successfully compile a program using portmidi on the Pi
this morning.

I was also able to cross compile a program for ARM 6 / Arch on 
from a debian instance. I recompiled Go 1.5 with CGO enabled,
but I forgot that I also need some mechanism to cross compile 
the C for ARM 6 / Arch also! That's a project for later.

## [•](index.html#1427944190) 1427944190 - 20150401
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


## [•](index.html#1427927658) 1427927658 - 20150401
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

## [•](index.html#1421676983) 1421676983 - 20150119
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

