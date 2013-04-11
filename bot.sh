#!/bin/sh
 
nick="blb$$"
channel=gymka
server=irc.freenode.net
config=/tmp/irclog
 
[ -n "$1" ] && channel=$1
[ -n "$2" ] && server=$2
config="${config}_${channel}"
 
echo "NICK $nick" > $config
echo "USER $nick +i * :$0" >> $config
echo "JOIN #$channel" >> $config

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
 
trap "rm -f $config;exit 0" INT TERM EXIT
 
tail -f $config | nc $server 6667 | while read MESSAGE
do
  case "$MESSAGE" in
    PING*) echo "PONG${MESSAGE#PING}" >> $config;;
    *!test*) echo "${MESSAGE}"|sed "s/.*PRIVMSG #.*:\!wiki \(.*\)/\1/" ;;
    *!rss*) rss ;;
    *PRIVMSG*) echo "${MESSAGE}" ;;
    
    *) echo "${MESSAGE}";;
  esac
done
