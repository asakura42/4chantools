# 4chandl
simple but powerful 4chan downloader script

Usage:
```
FFOLDER=folder FBOARDS=jp,a FKEYWORDS=japan,doujinshi FSTOPKEYWORDS=hentai sh ./4dl.sh -a

where FFOLDER is optional directory to download (or FDIR, which is top directory),
FBOARDS is list of boards from download, FKEYWORDS is list of keywords,
FSTOPKEYWORDS is stop words for filter shit (both FKEYWORDS and FSTOPKEYWORDS may be empty)
-a is for download all files, not only pictures
```
