#!/bin/sh
page="${2:-/tmp/out.html}"
printf "%s\n%s\n" "<style type=\"text/css\">p{margin:0ex auto;} h1,h2,h3,h4{font-weight:normal}p+p{text-indent:2em;} body{background:#eef2ff none}img{display:block; max-width: 32em; padding:1em; margin: auto}h1{text-align:center;text-transform:uppercase}div#sr{width:38em; padding:8em; padding-top:2em;background-color:white; margin:auto; line-height:1.4;text-align:justify; font-family:monospace; hyphens:auto;}</style>" "<div id=\"sr\" class=\"page\">" > "$page"
curl -s "$1" | sed 's/</\n</g' | sed '1,/<div class="thread"/d' | sed '/^<hr>$/,$d' | sed "s|\"//|\"https://|g;s|\"/|\"https://boards.4channel.org/|g;s|\"#\(.*\)No.|\"$1#\1No.|g;s|<wbr>||g" | sed -n '/postInfoM mobile/{p; :a; N; /<\/div>/!ba; s/.*\n//}; p' | sed -n '/sideArrows/{p; :a; N; /<\/div>/!ba; s/.*\n//}; p' | sed -e '/sideArrows/,+1d' | sed -e '/postInfoM mobile/,+1d' >> "$page"
list=$(cat "$page" | grep -A1 fileThumb | grep -oP 'src="\K[^"]+')
while IFS= read -r line ; do
	b64=$(curl --progress-bar "$line" | base64 -w0)
	ext=$(echo "$line" | awk -F'.' '{print $NF}')
	sed -i "s|$line|data:image/$ext;base64,$b64|" "$page"
done <<< "$list"
