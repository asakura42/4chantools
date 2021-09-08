# 4chandl
simple but powerful 4chan downloader script. Requires `jq`. If you're average shell enjoyer, send me PR or issue with no-jq workaround.

Usage:
```
FFOLDER=folder FBOARDS=jp,a FKEYWORDS=japan,doujinshi FSTOPKEYWORDS=' ' sh ./4dl.sh -a
or
sh ./4dl.sh https://boards.4channel.org/a/thread/1234567889/

where FFOLDER is optional directory to download (or FDIR, which is top directory),
FBOARDS is list of boards from download, FKEYWORDS is list of keywords,
FSTOPKEYWORDS is stop words for filter shit (both FKEYWORDS and FSTOPKEYWORDS may be ' ')
-a is for download all files, not only pictures
```
