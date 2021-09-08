#!/bin/sh
main () {
	board="${FBOARDS:-wg,w}"
	keywords="${FKEYWORDS:-comfy,city,neon,retro,wave,outrun}"
	stopkeywords="${FSTOPKEYWORDS:-porn,hentai,nazi,fash,fasci}"
	folder="${FFOLDER}"
	export topdir="${FDIR:-$HOME/Pictures/4chan}"
	export hashfile="${XDG_DATA_HOME:-$HOME/.local/share}/4picslist.txt"

	ext="| select(.ext == \".webp\" or .ext == \".png\" or .ext == \".jpg\")"
	case "$1" in
		-a|a|-all|all) unset ext
			shift ;;
	esac

	if [ -z $1 ] ; then
		boards=$(echo "$board" | tr ',' '\n')
		keywords=$(echo "$keywords" | tr ',' '\n' | sed 's/^/contains("/;s/$/") or /' | tr -d '\n' | sed 's/ or $//')
		stopkeywords=$(echo "$stopkeywords" | tr ',' '\n' | sed 's/^/contains("/;s/$/") or /' | tr -d '\n' | sed 's/^/ | (select(.semantic_url | /;s/ or $/ | not))/')
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
		done
	unset list
	done
}
case "$1" in
	-h|h|help|-help|--help) echo " FFOLDER=folder FBOARDS=jp,a FKEYWORDS=japan,doujinshi FSTOPKEYWORDS=hentai sh $(basename "$0") -a
 (print all vars optionally, default is comfy wallpapers from /wg/)

		or

 sh $(basename "$0") https://boards.4chan.org/b/thread/123456789
 Read script for full understanding." ;;
	*) main "$@" ;;
esac
