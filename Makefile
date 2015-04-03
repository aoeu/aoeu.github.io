index.html : llog.md
	./tools/blackfriday -page llog.md > index.html
	w3m index.html

clean :
	rm index.html

publish :
	git push origin master
