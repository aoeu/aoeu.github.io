index.html : llog.md
	blackfriday-tool -page llog.md > index.html
	lynx index.html

clean :
	rm index.html

publish :
	git push origin master
