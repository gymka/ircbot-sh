#!/bin/bash
. ./config.txt

rss () {
	wget -q -O ~rss1.txt 'http://www.delfi.lt/rss/feeds/daily.xml' 
	stream=$(grep title ~rss1.txt | sed -n 's/.*<title><!\[CDATA\[\(.*\)\]\]><\/title>.*/\1/p'|sed 1,2d|sed -n "1,4p")
	IFS='
	';
	for line in $stream
		do
			echo "PRIVMSG #$channel" :$line >> $config
		done
	rm ~rss1.txt
}

get_msg () {
	echo "PRIVMSG #$channel" :$(echo "$1"|sed "s/.*PRIVMSG #.*:\![a-z,0-9]* \(.*\)$/\1/")
}

get_nick () {
	echo "$(echo "${1}"|sed "s/^:\(.*\)!~.*/\1/")" 
}

 
trap "rm -f $config;exit 0" INT TERM EXIT
 
tail -f $config | nc $server 6667 | while read MESSAGE
do
  case "$MESSAGE" in
    PING*) echo "PONG${MESSAGE#PING}" >> $config;;
    *!test*) echo $(get_msg "${MESSAGE}") >> $config ;;
    *!rss*) rss ;; 
    *!kill*) echo "PART #channel"  >> $config ;;
    *) echo "${MESSAGE}";;
  esac
done
