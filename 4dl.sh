#!/bin/sh
main () {
	board="${FBOARD:-wg}"
	keywords="${FKEYWORDS:-comfy,city,neon}"
	export topdir="${FDIR:-$HOME/Pictures/4chan}"
	export hashfile="${XDG_DATA_HOME:-$HOME/.local/share}/4picslist.txt"

	ext="| select(.ext == \".webp\" or .ext == \".png\" or .ext == \".jpg\")"
	case "$1" in
		-a|a|all|-all) unset ext
			shift ;;
	esac

	if [ -z $1 ] ; then
		keywords=$(echo "$keywords" | tr ',' '\n' | sed 's/^/contains("/;s/$/") or /' | tr -d '\n' | sed 's/ or $//')
		list=$(curl -Ls "https://a.4cdn.org/$board/catalog.json" | jq -r ".[] | .threads[] | select(.semantic_url | $keywords) | .no")
		printf "%s %s\n" "$(echo "$list" | wc -l)" "threads."
		sleep 1
	else
		board=$(echo "$1" | awk -F'/' '{print $4}')
		list=$(echo "$1" | awk -F'/' '{print $6}')
	fi
	
		for i in $list ; do
			json=$(curl -Ls "https://a.4cdn.org/$board/thread/$i.json")
			export name=$(echo "$json" | jq -r ".posts[] | select(.semantic_url) | \"$board-\(.semantic_url)\"")
			echo "$name"
			mkdir -p "$topdir/$name"
			echo "$json" | jq -r ".posts[] | select(.ext) $ext | \"https://i.4cdn.org/$board/\(.tim)\(.ext)\"" \
				| xargs -P 10 -I{} -d $'\n' \
				sh -c 'if ! grep -q $(basename {}) $hashfile ; then curl --create-dirs -LO --progress-bar --output-dir $topdir/$name {} ; basename {} >> $hashfile ; fi'
		done
}
case "$1" in
	-h|h|help|-help|--help) echo " FBOARD=jp FKEYWORDS=djt,doujinshi FDIR=$HOME/Pictures sh $(basename "$0") -a
 (print all vars optionally, default is comfy wallpapers from /wg/)

		or

 sh $(basename "$0") https://boards.4chan.org/b/thread/123456789
 Read script for full understanding." ;;
	*) main "$@" ;;
esac

