index.html : llog.md
	./tools/blackfriday -page llog.md > index.html

clean :
	rm index.html
