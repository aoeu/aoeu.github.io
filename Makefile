index.html : llog.md
	blackfriday-tool -page llog.md > index.html
	test $(shell uname) = Darwin && open index.html || lynx index.html

clean :
	rm index.html

publish :
	git push origin master

dependencies :
	go get github.com/russross/blackfriday-tool
