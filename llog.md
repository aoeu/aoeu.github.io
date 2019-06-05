# Hello there, stranger.

## About
This is a log of things I learn, experiment with, or think about.

## [🔖](index.html#1559777525) 1559777525 - 20190605

### A Structured Query Language Story

A programmer used to optimize reports ("stored-procedures" in individual SQL files) for a finance company. A whole team of 4 used to write and maintain those SQL files and schema but were disbanded. After some years and years of random people spot-editing the SQL files without holistically understanding them or the schema, and this thing called "algorithmic trading" becoming more popular, the hundred or so stored-proceduces ("sprocs") could not finish running overnight.  So, the programmer would get dropped in to clean up particular reports when needed, having taken a databases elective in undergrad.

The slowdowns in performance were often caused by:

* `where` clauses with many `join` statements (over 4 or 5, approaching 10)
* `join` statements on table columns that were not indexed
* many subselect statements (sometimes nested) in `where` clauses

Some take-aways from optimizing lots of those sprocs were:

* It is hard to know exactly where things are slowing down until you look at the "execution plan" output of the database engine, and see what is paging, etc.
* Rethink the schema and table definitions. Sometimes new tables need to be created for data this is commonly joined together where clasues.
* If the same joins are happening in subsequent queries, do the query once and store results in a cache table (if you can't redefine the schema as per above).

All in all, the programmer learned that database implementation details are magic, but optimizing SQL is not.

## [🔖](index.html#1559320529) 1559320529 - 20190531

Comments are lies waiting to happen, but documentation is useful.

However, incorrect documentation can be useless, or arguably more harmful than not documentation at all.

Consider this documentation snippet from the AWS SNS Go SDK:

```
// Input for Publish action.
type PublishInput struct {

	// ...
	// This struct definition is abridged by aoeu, with prior fields omitted.
	// ...

	// Either TopicArn or EndpointArn, but not both.
	//
	// If you don't specify a value for the TargetArn parameter, you must specify
	// a value for the PhoneNumber or TopicArn parameters.
	TargetArn *string `type:"string"`

	// The topic you want to publish to.
	//
	// If you don't specify a value for the TopicArn parameter, you must specify
	// a value for the PhoneNumber or TargetArn parameters.
	TopicArn *string `type:"string"`
}
```

Either a "TopicArn" or an "EndpointArn," but not both.

As it turns out, "EndpointArn" isn't an actual field, and the comment probably meant to say,
"Either TopicArn or TargetArn must be set, but not both." But maybe the field sohuld be renamed
from "TargenArn" to "EndpointArn" because the rest of the file seems to refer to that value with
fields named "EndpointArn." 

So what we have here is documentation that incorrectly names the actual field it is documenting.
That isn't good, and actually led me to run around the API and file to see if I was missing something,
only to find I was misinformed by the documentation.

Documentation errors like this make programming harder, as does alternate solutions to the original problem,
such as maybe using one field for ARN (and having the SDK figure out what type of ARN it is), or a different
field used to specify what the ARN type is (let's say with `const`s for the types declared with `iota`)
while simultaneously having having one field for the ARN value).
Nevermind the total disregard to an extremely fundamental Go idiom of using consistent capitalizaton for acronyms.

All of this in combination makes coding for AWS with Go harder than it needs to be. 


## [🔖](index.html#1559146238) 1559146238 - 20190529


I have often heard people say that it is faster to do many similar edits to some lines of code by hand.
Maybe they will record a squence of keys (a macro) via their text editor to help increase speed.
I prefer to use regular expressions to make edits to existing code.


I reason that many people could do many similar edits faster than I can by hand, but I often make mistakes
when typing prose (and prose-like code), and then pay more time later at compile-time or run-time and have to go fix the mistakes.
Also, a person can get a lot faster at finding and editing text via regular expressions by actually using regular expressions to find and edit the text. The speed and the ability to stream-of-conciousness type a complex regular expression correctly will never be obtained without practice.  
  
I've even been asked to do edits like this in a programming interview in front of a real computer and editor, with the interviewer hinting at it is faster to make the edits by hand. That might be the case in one-off instances, or in an interview where it is easier to even typo a regular expression
  

With all of this in mind, I really like tiny, quick, regular-expression victories. The following is one that I did today, in seconds. (This write up took many times longer.)

Input:
```
	flag.StringVar(&args.inputFilepath, "in", "", "filepath to read report data from instead of SFTP download")
	flag.StringVar(&args.outputFilepath, "out", "", "filepath to write report data to from SFTP download")
	flag.BoolVar(&args.printSummary, "summarize", false, "Print output from main function that may be useful for debugging")
	flag.BoolVar(&args.writeToDB, "store", true, "Apply found restrictions on users to database")
	flag.BoolVar(&args.ignoreUnknownUsers, "dev", false, "Ignore unknown users on development server")
```

Regexp (first try, no backspacing):
```
	Edit .s/(flag.*)Var\(&args\.([a-zA-Z]+), (.*)/\2 = \1(\3/g
```

Output:
```
	inputFilepath = flag.String("in", "", "filepath to read report data from instead of SFTP download")
	outputFilepath = flag.String("out", "", "filepath to write report data to from SFTP download")
	printSummary = flag.Bool("summarize", false, "Print output from main function that may be useful for debugging")
	writeToDB = flag.Bool("store", true, "Apply found restrictions on users to database")
	ignoreUnknownUsers = flag.Bool("dev", false, "Ignore unknown users on development server")
```
## [🔖](index.html#1540425237) 1540425237 - 20181024

Today, in regular expressions, we observe how to change all of one type of questionable lambda syntax to another questionable lambda syntax:  

`$ rg '\([a-z]+\) \-> [a-z]' -l  | xargs sed -i '' -E 's/\(([a-z]+)\) -> ([a-z])/\1 -> \2/g'`

Changes text like  

	oneWayWouldBeBetter((foo) -> callback());  

to  

	oneWayWouldBeBetter(foo -> callback());  

for an entire project.

## [🔖](index.html#1540423346) 1540423346 - 20181024

I didn't realize there were no less than 3 different syntax for the same semantic of declaring a lambda in Java 8 (and above)  

`set(this::callback); // no args`   
`set(foo -> callback()); // one arg`  
`set((foo, bar) -> callback()); // two args`  

And we can also throw in some varying ways of doing the same things:  

`set(()->callback()); // no args`  
`set((Foo f, Bar b) -> callback()); // two args`  

...all as opposed to one way of doing it that handles all cases. Equally interesting as it is horrifying.  

By horrifying, I mean that a major ingredient of Good software engineering is consistency, and here we have all these little possible inconsistencies baked into one language feature, each a thing to possibly trip up muscle memory when typing, or the eyes of the reader.


## [🔖](index.html#1531345423) 1531345423 - 20180711

I was able to leverage git to find the name of a branch where I could vaguely remember when I wrote a bugfix, but not exactly what the bugfix was for, nor the name of the branch.  

I suddenly had a need for a bugfix I had written in the process of reviewing of someone else's code.  
(I needed to confirm that the solution I was going to suggest in the code review did indeed actually work.)  

The other person's code review was eventually closed, and I forgot about my bugfix branch, until the issue suddenly came up again, in another code review, by a different person!  

All I could remember is that I had sketched out a fix for this bug before, on some branch, toward the end of 2017.  
Fortunately, I name my branches in the format of `<github-username>.<type-of-change>.<name>`, i.e. `aoeu.bugfix.redundant-user-prompt`, so I was able to leverage `git for-each-ref` to:  

* print each git branch in the repo descending by commit date (via the `--sort` flag)
* print the name and most recent commit date of each branch the repo (via the `--format` flag)
* filter down to branches I wrote that were bugfixes in 2017 (via the `grep` command and my branch naming scheme)
* filter down to only the last branches committed to in late 2017 (via `head` command)


#### Sorting all git branches descending by last commit date and printing the branch name:
```
git for-each-ref --sort=-committerdate refs/heads --format '%(committerdate) %(refname)' | grep aoeu.bugfix | grep 2017 | head -20
```

## [🔖](index.html#1525816236) 1525816236 - 20180508

I could not install [vgo](https://research.swtch.com/vgo) as part of its [tour](https://research.swtch.com/vgo-tour), ironically because my system didn't meet the minimum version requirement of Go 1.10, and more specifically (and more ironically) because the Go 1.9 was a mere 4 days before a commit needed for `vgo`!  

```
$ go get -u golang.org/x/vgo

# golang.org/x/vgo/vendor/cmd/go/internal/modfetch/gitrepo
/opt/ir/src/golang.org/x/vgo/vendor/cmd/go/internal/modfetch/gitrepo/fetch.go:404:21: r.File[0].Modified undefined (type *zip.File has no field or method Modified)

$ go version
go version go1.9 darwin/amd64

$ cd $GOROOT; git log -1 --pretty='%cd %H %s'
Thu Aug 24 20:52:14 2017 +0000 c8aec4095e089ff6ac50d18e97c3f46561f14f48 [release-branch.go1.9] go1.9

$ git checkout master

$ git blame -L `egrep -n 'Modified\s+time.Time' $GOROOT/src/archive/zip/struct.go | cut -d: -f1`,+1 $GOROOT/src/archive/zip/struct.go
6e8894d5ffc (Joe Tsai 2017-08-28 12:07:58 -0700 119)    Modified     time.Time
```


## [🔖](index.html#1525813299) 1525813299 - 20180508

I was able to get a tiny, tiny code change merged into [gVisor](https://github.com/google/gvisor).

Taking reading David Walsh's [article](https://davidwalsh.name/conquering-impostor-syndrome) about conquering Imposter Syndrome, I decided to try achieving a "little win."  

Later the same day, I was reading documentation in the newly published [gVisor source code](https://github.com/google/gvisor) and saw a typo.  I had to use Gerrit at work for years, so after a bit of configuring I was able to create [a code review](https://gvisor-review.googlesource.com/c/gvisor/+/1820) that was later merged as a github [pull request](https://github.com/google/gvisor/commit/4394b31dbbe276440891de0d8ee66bc5209400f1).


## [🔖](index.html#1523383234) 1523383234 - 20180410

My trusty ASUS 10.1 inch Chromebook Flip has been a solid machine for writing golang code and [my command line tools](https://github.com/aoeu/gosh) on 30 minute train commute, and even DJing an entire hours-long set via crouton, XFCE, MIXXX, a FiiO USB DAC used simulatenously with the built-in audio card, and one of my MID controllers.  

The screen chassis is now taped together from all the rough weather it has withstood. I thought I'd try upgrading with:  

```
$amsung 12.3" QHD Touchscreen Chromebook-Plus  
$349.99  
Sold by W00t, Inc.  
Condition: Factory Reconditioned  
Screen Size: 12.3"  
```
  
I liked the USB-C ports, the stylus, the 4:3 screen ratio with really nice resolution and colors, and the all aluminum body.

[I didn't like](https://twitter.com/traverser/status/982617066388770816) the "phantom input" on the touch-screen, and apparently I wasn't the only one with this problem according to [10 pages of issues on the support forums](https://us.community.samsung.com/t5/Computers/Chromebook-plus-touchscree-issue/td-p/77098/page/4).  

So, back from whence it came. Holding and typing on my ASUS Flip again, it somehow feels more sturdy and nicer to type anyway, all while being more portable and cheaper. It'd just be nice to have some faster USB ports and more RAM....

## [🔖](index.html#1507682244) 1507682244 - 20171010

I was recently at a technology conference where there was [a talk](https://chris.banes.me/dcnyc17) on Android apps, [the Android status bar](https://duckduckgo.com/?q=android+status+bar&t=ffab&iar=images&iax=1&ia=images&iai=http%3A%2F%2Ftechviral.com%2Fwp-content%2Fuploads%2F2015%2F12%2FAdd-Network-Speed-indicator-in-Android-Status-Bar.jpg), "no bezel" smartphones (like the [PH-1](http://phandroid.com/2017/07/31/essential-phone-status-bar/)), and how these things collide into a user-facing problem for some Android apps.

The speaker cleary explained the "what" and the "why," but not a complete example of "how" for the solution.

The catalyst of the problem is when an Android app:  

* doesn't have an [app bar](https://developer.android.com/training/appbar/index.html).
* has a background-image (xor header image), that draws some fancy stuff behind a transparent status bar, and fills up the space where the app bar would normally be.
* has a custom app bar (made only from core widgets like LinearLayout, TextView, and ImageView, possibly due to difficulties with the API-provided [app bar](https://stackoverflow.com/search?q=app+bar+%5Bandroid%5D) / [action bar](https://stackoverflow.com/search?q=action+bar+%5Bandroid%5D) and what can go wrong with using Compat and Support libraries, but worthy of a disparate argument for simplicity).

The [explicitly discouraged soultion](https://photos.app.goo.gl/qZyZ9xwKFya602xs1) is to hard-code the size of the status bar in layout files, even as an identified dimenion used across multiple layout files:
```
> find . -name 'dimens.xml' | xargs grep status_bar

  <dimen name="status_bar_height">24dp</dimen>
  <dimen name="app_bar_height_plus_status_bar_height">80dp</dimen>
  <dimen name="header_photo_height_plus_status_bar_height">224dp</dimen>
  <dimen name="negative_status_bar_height">-24dp</dimen>

> # You aren't supposed to hardcode status bar values like this Android resource XML files.
```
The [recommended solution](https://photos.app.goo.gl/VYcHBZcUESYTTYYb2) is to obtain the status bar height at runtime and apply it to the relevant view. If you have to do that in Java, here is a complete example:

```
class TransparentStatusBarHaver extends Activity {

	@Nullable View viewThatSitsBelowTheTransparentStatusBar;

	public void onCreate(Bundle stuff) {
		super.onCreate(stuff);
		setContentView(R.layout.activity_with_transparent_status_bar);
		viewThatSitsBelowTheTransparentStatusBar = findViewById(R.id.view_that_sits_below_transparent_status_bar);
	}


	// Set heights that compensate for a transparent status bar 
	// in onPostCreate(...) instead of onCreate(...) since descendant activity classes 
	// get a chance to call setContentView(...) in their own onCreate(...) method.
	public void onPostCreate(Bundle stuff) {
		super.onPostCreate(stuff);
		if (viewThatSitsBelowTheTransparentStatusBar == null) {
			return;
		}
		ViewCompat.setOnApplyWindowInsetsListener(viewThatSitsBelowTheTransparentStatusBar,
				new android.support.v4.view.OnApplyWindowInsetsListener() {
					@Override
					public WindowInsetsCompat onApplyWindowInsets(
							View view,
							WindowInsetsCompat windowInsetsCompat) {
						int statusBarHeightInPixels = windowInsetsCompat.getSystemWindowInsetTop();
						int currentHeightOfViewInPixels = view.getLayoutParams().height;
						view.getLayoutParams().height = statusBarHeightInPixels + currentHeightOfViewInPixels;
						view.setLayoutParams(view.getLayoutParams());
						view.setPadding(
								view.getPaddingLeft(),
								statusBarHeightInPixels,
								view.getPaddingRight(),
								view.getPaddingBottom()
						);
						return windowInsetsCompat;
					}
				}
		);
	}

}
```

I was at the original talk, squinted through the Kotlin pseudo-code, looked up the docs myself, and wrote the above example, and it is **still** hard to understand the above code (or why it exists) at a glance.  
So this solution gives us the "how," but then obfuscates the "why" that was so well explained in the talk.

To help convey what is going on and why, I tried distilling the code by using named-methods and named-parameters to provide a little more clarity to the anonymous-classes, unexpectedly-named interfaces, and verbose Android API calls:

```
class TransparentStatusBarHaver extends Activity {

	@Nullable View viewThatSitsBelowTheTransparentStatusBar;

	public void onCreate(Bundle stuff) {
		super.onCreate(stuff);
		setContentView(R.layout.activity_with_transparent_status_bar);
		viewThatSitsBelowTheTransparentStatusBar = findViewById(R.id.view_that_sits_below_transparent_status_bar);
	}

	@Override
  	protected void onPostCreate(Bundle savedInstanceState) {
    		super.onPostCreate(savedInstanceState);
		StatusBarMeasurer.addHeightForTransparentStatusBar(viewThatSitsBelowTheTransparentStatusBar);
	}
}

public class StatusBarMeasurer implements OnApplyWindowInsetsListener {

	static public void addHeightForTransparentStatusBar(final View viewBelowStatusBar) {
		if (viewBelowStatusBar == null) {
			return;
		}
		ViewCompat.setOnApplyWindowInsetsListener(viewBelowStatusBar, new StatusBarMeasurer());
	}

	@Override
	public WindowInsetsCompat onApplyWindowInsets(View view, WindowInsetsCompat windowInsetsCompat) {
		onStatusBarMeasured(view, windowInsetsCompat);
		return windowInsetsCompat;
	}

	private void onStatusBarMeasured(View viewBelowStatusBar, WindowInsetsCompat windowInsetsCompat) {
		int statusBarHeightInPixels = windowInsetsCompat.getSystemWindowInsetTop());
		incrementHeight(viewBelowStatusBar, statusBarHeightInPixels);
		incrementTopPadding(viewBelowStatusBar, statusBarHeightInPixels);
	}

	public static void incrementHeight(View v, int additionalHeightInPixels) {
		int currentHeightInPixels = v.getLayoutParams().height;
		v.getLayoutParams().height = currentHeightInPixels + additionalHeightInPixels;
		v.setLayoutParams(v.getLayoutParams());
	}

	public static void incrementTopPadding(View v, int additionalPaddingInPixels) {
		v.setLayoutParams(v.getLayoutParams());
		v.setPadding(v.getPaddingLeft(), additionalPaddingInPixels, v.getPaddingRight(), v.getPaddingBottom());
	}
}

```

That's a bit easier for me to follow, but I do wonder:

* Why isn't there an Android API call that just returns the status bar height?
* Why does the programmer have to know about WindowInsets, support libraries, and WindowInsetsCompat shim-code to implement the suggested solution?
* Why is it so easy for programmers to get bit by Android, status bars, transparent status bar, and unexpected side-effects in the first place?

## [🔖](index.html#1496155760) 1496155760 - 20170530

I recently rediscovered [this helpful and entertaining flow-chart diagram, titled *git pretty*,](http://justinhileman.info/article/git-pretty/) that starts with: "So, you have a mess on your hands."

## [🔖](index.html#1487031425) 1487031425 - 20170213

[Heimdall](https://github.com/Benjamin-Dobell/Heimdall) has instructions to build with dependent libraries installed via [homebrew](https://brew.sh).
Heimdall can also be built with the the dependent libraries installed via [macports](https://www.macports.org), but with some [kludging](https://en.wikipedia.org/wiki/Kludge).

Assuming that macports installs libraries under '/opt/local/lib' (e.g. the default for macports):

```
$ git clone git@github.com:Benjamin-Dobell/Heimdall.git
$ cd Heimdall
$ tail OSX/README.txt | grep 'brew install' | sed 's/brew/port/g'
$ sudo port install libusb qt5 cmake
$ mkdir build
$ cd build
$ cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DQt5Widgets_DIR=`find /opt/local/lib -name 'Qt5Widgets'` ..
$ echo "A linker error will happen during `make` that looks like this:"
$ cat << EOF
[ 53%] Linking CXX executable ../bin/heimdall
ld: library not found for -lusb-1.0
clang: error: linker command failed with exit code 1 (use -v to see invocation)
make[2]: *** [bin/heimdall] Error 1
make[1]: *** [heimdall/CMakeFiles/heimdall.dir/all] Error 2
make: *** [all] Error 2
EOF
$ make
$ cat heimdall/CMakeFiles/heimdall.dir/link.txt | sed 's/\(-lusb-1.0\)/-L\/opt\/local\/lib \1/'
$ cd heimdall && /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/c++    -std=gnu++11 -O3 -DNDEBUG -Wl,-search_paths_first -Wl,-headerpad_max_install_names  CMakeFiles/heimdall.dir/source/Arguments.cpp.o CMakeFiles/heimdall.dir/source/BridgeManager.cpp.o CMakeFiles/heimdall.dir/source/ClosePcScreenAction.cpp.o CMakeFiles/heimdall.dir/source/DetectAction.cpp.o CMakeFiles/heimdall.dir/source/DownloadPitAction.cpp.o CMakeFiles/heimdall.dir/source/FlashAction.cpp.o CMakeFiles/heimdall.dir/source/HelpAction.cpp.o CMakeFiles/heimdall.dir/source/InfoAction.cpp.o CMakeFiles/heimdall.dir/source/Interface.cpp.o CMakeFiles/heimdall.dir/source/main.cpp.o CMakeFiles/heimdall.dir/source/PrintPitAction.cpp.o CMakeFiles/heimdall.dir/source/Utility.cpp.o CMakeFiles/heimdall.dir/source/VersionAction.cpp.o  -o ../bin/heimdall  ../libpit/libpit.a -L/opt/local/lib -lusb-1.0
$ ../bin/heimdall version
$ echo "Thus concludes the kludge." && \
cp ../bin/heimdall $SOME_DIRECTORY_IN_YOUR_PATH_WHERE_YOU_KEEP_BINARIES/heimdall
```

## [🔖](index.html#1486765292) 1486765292 - 20170210

Searching for edits of a file, by name, through a range of git commits:

```
#!/bin/sh
for arg in "$@"
do
case $arg in
	-for=*)
		filename="${arg#*=}"
	;;
	-from=*)
		startSHA="${arg#*=}"
	;;
	-to=*)
		endSHA="${arg#*=}"
	;;
esac
done
test '' = "$endSHA" && endSHA="HEAD"


for sha in `git log --pretty="%H" $startSHA..$endSHA` ; do git diff-tree --no-commit-id --name-only -r $sha | grep "$filename" && echo "$filename was editied in commit $sha"; done
```

Usage:
```
search-git-for-edits -of='some_image_file.png' -from=a93b5f746bdb1e0054dbb7e37fdfcd84a73d7f85 -to=HEAD
```

## [🔖](index.html#1486426704) 1486426704 - 20170206

Debugging animations within an Android app can be tricky, especially if there is a sufficient "callback casserole" of asynchronous server requests, click listeners, and animation listeners all swirled together.  

A trick that helped me debug how and when callback methods were getting called was just a one-liner log statement:

```
// Placed in various click-listener callbacks, asyncronous server request callbacks, and animation listener callbacks:
android.util.Log.e("aoeu", Log.getStackTraceForString(new Exception));
```

Monitored with:
```
adb logcat '*:E' | grep aoeu
```

While logging stack-traces doesn't provide knowledge of what data was being input into methods, it was extremely useful to see how, in real-time, various callbacks were calling eachother without putting log statements in each method or stopping the world with a debugger.


## [🔖](index.html#1485561815) 1485561815 - 20170127

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

## [🔖](index.html#1485388140) 1485388140 - 20170125

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

## [🔖](index.html#1437014448) 1437014448 - 20150715

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

## [🔖](index.html#1434415672) 1434415672 - 20150615

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

## [🔖](index.html#1433476141) 1433476141 - 20150604

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

## [🔖](index.html#1432908829) 1432908829 - 20150529

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
## [🔖](index.html#1429880922) 1429880922 - 20150424

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


## [🔖](index.html#1429620177) 1429620177 - 20150421

I spent a lot of the weekend resurrecting some older d3 code and building this thing:

- http://www.mcdem.us/climate/c02e.html
- http://github.com/aoeu/climate

The color experiments were for this.
d3 makes more sense than it used to, despite I haven't looked at it at all in the meanwhile.

It was suggested to add a slider, which I think is a good idea.


## [🔖](index.html#1428886299) 1428886299 - 20150412

I'm pulling some data sources I'll transform later for a project.
I'm naming target directories after *filenames* and paths from the source URIs.
e.g `~/user/repo/data/sources/example.com/path/to/archive.zip/` is a directory with files in it.
To reiterate, the `archive.zip` component is a *directory*, and not the actual
zip file. The contents of the directory are the extracted contents of the source zip file.

The idea is to have the directory be a self-documenting reference to the source file.
However, this feels like it is being clever, and not clear.
I also wonder what ill-affects it would have on an unsuspecting shell script.



## [🔖](index.html#1428778652) 1428778652 - 20150411

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
  

## [🔖](index.html#1428707143) 1428707143 - 20150410

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

## [🔖](index.html#1428497189) 1428497189 - 20150408

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

## [🔖](index.html#1428410883) 1428410883 - 20150407

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

## [🔖](index.html#1428025541) 1428025541 - 20150402

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

## [🔖](index.html#1427983169) 1427983169 - 20150402

I fell asleep while pulling down GCC on Arch on the Pi, but 
I was able to successfully compile a program using portmidi on the Pi
this morning.

I was also able to cross compile a program for ARM 6 / Arch on 
from a debian instance. I recompiled Go 1.5 with CGO enabled,
but I forgot that I also need some mechanism to cross compile 
the C for ARM 6 / Arch also! That's a project for later.

## [🔖](index.html#1427944190) 1427944190 - 20150401
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


## [🔖](index.html#1427927658) 1427927658 - 20150401
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

## [🔖](index.html#1421676983) 1421676983 - 20150119
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

