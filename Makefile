index.html : llog.md
	pandoc -s llog.md -o index.html

clean :
	rm index.html
