#!/bin/sh
main () {
	board="${FBOARDS:-wg,w}"
	keywords="${FKEYWORDS:-comfy,city,neon,retro,wave,outrun}"
	stopkeywords="${FSTOPKEYWORDS:-porn,hentai,nazi,fash,fasci}"
	folder="${FFOLDER}"
	download="${FDOWNLOAD}"
	export topdir="${FDIR:-$HOME/Pictures/4chan}"
	export hashfile="${XDG_DATA_HOME:-$HOME/.local/share}/4picslist.txt"

				dl () {
				export outputhtml="$2"
				printf "%s\n%s\n" "<style type=\"text/css\">p{margin:0ex auto;} \
					h1,h2,h3,h4{font-weight:normal}p+p{text-indent:2em;} \
					body{background:#eef2ff none}img{display:block; \
					max-width: 32em; padding:1em; \
					margin: auto}h1{text-align:center;text-transform:uppercase} \
					div#sr{width:38em; padding:8em; padding-top:2em;background-color:white; \
					margin:auto; line-height:1.4;text-align:justify; \
					font-family:monospace; hyphens:auto;}</style>" \
					"<div id=\"sr\" class=\"page\">" > "$outputhtml"
				curl -Ls "$1" | sed 's/</\n</g' | sed '1,/<div class="thread"/d' \
					| sed '/^<hr>$/,$d' | sed "s|\"//|\"https://|g;
						s|\"/|\"https://boards.4channel.org/|g;
						s|\"#\(.*\)No.|\"$1#\1No.|g;s|<wbr>||g" \
					| sed -n '/postInfoM mobile/{p; :a;
						N; /<\/div>/!ba; s/.*\n//}; p' \
					| sed -n '/sideArrows/{p; :a;
						N; /<\/div>/!ba; s/.*\n//}; p' \
					| sed -e '/sideArrows/,+1d' \
					| sed -e '/postInfoM mobile/,+1d' | tr -d '\n' | sed 's/</\n</g' >> "$outputhtml"
				piclist=$(cat "$outputhtml" | grep -A1 fileThumb | grep -oP 'src="\K[^"]+')
				echo "$piclist" | xargs -P 10 -I{} -d $'\n' sh -c 'b64=$(curl --progress-bar "{}" | base64 -w0) ; extension=$(echo "{}" | sed "s/^.*\.//") ; sed -i "s|{}|data:image/$extension;base64,$b64|" "$outputhtml"'
			}

	ext="| select(.ext == \".webp\" or .ext == \".png\" or .ext == \".jpg\")"
	case "$1" in
		-a|a|-all|all) unset ext
			shift ;;
	esac

	if [ -z $1 ] ; then
		boards=$(echo "$board" | tr ',' '\n')
		keywords=$(echo "$keywords" | tr ',' '\n' | sed 's/^/contains("/;s/$/") or /' | tr -d '\n' | sed 's/ or $//')
		if [ -z "$stopkeywords" ] ; then
			true
		else
			stopkeywords=$(echo "$stopkeywords" | tr ',' '\n' | sed 's/^/contains("/;s/$/") or /' | tr -d '\n' | sed 's/^/ | (select(.semantic_url | /;s/ or $/ | not))/')
		fi
	else
		boards=$(echo "$1" | awk -F'/' '{print $4}')
		list=$(echo "$1" | awk -F'/' '{print $6}')
	fi
	for b in $boards ; do
		if [ -z "$list" ] ; then
			list=$(curl -Ls "https://a.4cdn.org/$b/catalog.json" | jq -r ".[] | .threads[] | select(.semantic_url | $keywords) $stopkeywords | .no")
			printf "%s %s\n" "$(echo "$list" | sed '/^$/d' | wc -l)" "threads on $b board."
			sleep 1
		fi

		for i in $list ; do


			json=$(curl -Ls "https://a.4cdn.org/$b/thread/$i.json")
			export name=$(echo "$json" | jq -r ".posts[] | select(.semantic_url) | \"$b-\(.semantic_url)\"")
			echo "$name"
			mkdir -p "${folder:-$topdir/$name}"
			export ffolder="${folder:-$topdir/$name}"
			echo "$json" | jq -r ".posts[] | select(.ext) $ext | \"https://i.4cdn.org/$b/\(.tim)\(.ext)\"" \
				| xargs -P 10 -I{} -d $'\n' \
				sh -c 'if ! grep -q $(basename {}) $hashfile ; then curl --create-dirs -LO --progress-bar --output-dir $ffolder {} ; basename {} >> $hashfile ; fi'
			if [ ! -z "$download" ] ; then
				dl "https://boards.4channel.org/$b/thread/$i" "$ffolder/$i.html"
			fi
		done
	unset list
	done
}
case "$1" in
	-h|h|help|-help|--help) echo " FDOWNLOAD=y FFOLDER=folder FBOARDS=jp,a FKEYWORDS=japan,doujinshi FSTOPKEYWORDS=hentai sh $(basename "$0") -a
 (print all vars optionally, default is comfy wallpapers from /wg/)

		or

 sh $(basename "$0") https://boards.4chan.org/b/thread/123456789
 Read script for full understanding." ;;
	*) main "$@" ;;
esac
