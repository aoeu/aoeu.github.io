index.html : llog.md
	blackfriday-tool -page llog.md > index.html
	test $(shell uname) = Darwin && open index.html || lynx index.html

entrytitles:
	sed -i '' 's/^## \([0-9]\{10\}\) - /## [•](index.html#\1) \1 - /' llog.md

clean :
	rm index.html

publication :
	git push $(shell git remote | head -1) master

dependencies :
	go get github.com/russross/blackfriday-tool
