#!/bin/bash
. ./config.txt

trl () {
echo "PRIVMSG #$channel" :"supratau, dirbu" >> $config
filehtml=file_$(echo $RANDOM).html
trlhtml=trl_$(echo $RANDOM).html
trl2html=trl2_$(echo $RANDOM).html
fffhtml=fff_$(echo $RANDOM).html
ttt=ttt_$(echo $RANDOM)
urltxt=url_$(echo $RANDOM).txt
kodastxt=kodas_$(echo $RANDOM).txt
torrent_url="$1"
IMDBNR="$2"
imdb_url="http://www.imdb.com/title/tt$IMDBNR"
wget -U "Mozilla/5.0 (X11; Linux x86_64; rv:19.0) Gecko/20100101 Firefox/19.0" -e robots=off -O ${filehtml} $imdb_url
desc=$(sed -n 's/<meta name="description" content="\(.*\)" \/>/\1/p' ${filehtml})
title=$(sed -n "s/<meta property='og:title' content=\"\(.*\)(.*/\1/p" ${filehtml})

#jei serialas tai imam paskutinio sezono metus, jei filmas išleidimo datą
reld=$(sed -n '/<h4 class="inline">Year:<\/h4>/,/<\/a>/p' ${filehtml} | sed -n "s/.*\([0-9]\{4\}\)<\/a>/\1/p")
if [[ "$reld" == "" ]] 
	then
		reld=$(grep "<title>.*</title>" ${filehtml} | sed -n "s/\([0-9]\{4\}\).*/\1/p" | sed -n "s/.*\([0-9]\{4\}\).*/\1/p")
fi

genr=$(sed -n '/<h4 class="inline">Genres:<\/h4>/,/<\/div>/p' ${filehtml}|sed -n 's@<a href="/genre/.* >\(.*\)<.*@\1,@p' | sed "s/<.*>//;s/|//")
genree=$(echo $genr|sed "s/,$//")
genre=$(isverst_kategorija "$genree")
country=$(sed -n '/<h4 class="inline">Country:<\/h4>/,/<\/div>/p' ${filehtml}|sed -n "s/<a href=\"\/country\/.*\" itemprop='url'>\(.*\)<\/a>/ \1/p"|tr '\n' ','|sed 's/,$//;s/^ //'|sed "s/<\/span>//g"|sed "s/, ,/,/g")
creators=$(sed -n '/<h4 class="inline">Creator.*:<\/h4>/,/<\/div>/p' ${filehtml}|sed -n "s/.*<a href=\"\/name\/.*\" itemprop='url'>\(.*\)<\/a>/ \1/p"|tr '\n' ','|sed 's/,$//;s/^ //'|sed "s/<\/span>//g"|sed "s/<span .*\">//"|sed "s/, ,/,/g")
director=$(sed -n '/<h4 class="inline">Director:<\/h4>/,/<\/div>/p' ${filehtml}|sed -n "s/<a href=\"\/name\/.*\" itemprop='url'>\(.*\)<\/a>/ \1/p"|tr '\n' ','|sed 's/,$//;s/^ //'|sed "s/<\/span>//g"|sed "s/, ,/,/g")
cast=$(sed -n '/<table class="cast_list">/,/<\/table>/p' ${filehtml} | \
sed -n "s/.*itemprop=[\"']name[\"']>\(.*\)/ \1/p"|tr '\n' ','|sed 's/,$//;s/^ //;s/<\/span>//g')

##################################################
#                                                                Torrent.ai                                                             #
#                                                  Pavadinimas ir viršelis                                                   #
##################################################

wget  -U "Mozilla/5.0 (X11; Linux x86_64; rv:19.0) Gecko/20100101 Firefox/19.0" -e robots=off -O ${trlhtml} $torrent_url
name=$(sed -n 's/\t//g;s/<div class=\"pavadinimas\">\(.*\)<\/div>/\1/p' ${trlhtml})
#viršelį paima tik tada jei įdėjo botas, plain text formatu
cover=$(sed -n 's/\t//g;/<div class=\"pavadinimas\">/,/Kita informacija:/p' ${trlhtml} |sed -n 's/<img src="\(.*\)" w.*/\1/p')
wget  -U "Mozilla/5.0 (X11; Linux x86_64; rv:19.0) Gecko/20100101 Firefox/19.0" -e robots=off -O ${trl2html} --post-data="imgUrl=${cover}" http://trl.lt/upload.php
cover_url=$(sed -n 's/.*Tiesioginė nuoroda:.*value=\"\(http:\/\/.*\)\" onclick=.*/\1/p' ${trl2html})

##################################################
#                                                                seeders.lt                                                            #
#                                                 Audio/Video info ir ekranvaizdžiai                             #
##################################################

wget  -U "Mozilla/5.0 (X11; Linux x86_64; rv:19.0) Gecko/20100101 Firefox/19.0" -e robots=off -O ${fffhtml} "http://www.seeders.lt/browse.php?incldead=1&search=${name}&sort=1&type=desc&page=0"
pirmas_rezultatas=$(grep -m 1 -o "<td align='left' class='info'><a href=.*>" ${fffhtml} |\
sed -n "s/.*info'><a href='\(.*\)'><b>.*/http:\/\/seeders\.lt\/\1/p")
wget  -U "Mozilla/5.0 (X11; Linux x86_64; rv:19.0) Gecko/20100101 Firefox/19.0" -e robots=off -O ${fffhtml} $pirmas_rezultatas
pictures=$(grep "<a target=\"_blank\" href=.*fastpic" ${fffhtml}|sed 's/<\/a>/\n/g'|\
sed -n 's/<a target=\"_blank\" href=\".*src="\(http:\/\/i.*\.fastpic.*\)\" alt.*/\1/p'|\
sed 's@/thumb/@/big/@'|sed 's/\.jpeg/\.png/')
video_info=$(sed -n '/Video info:/,/<a target=/p' ${fffhtml} |sed -n '/^<b>.*<br/p'|sed 's/<.\{0,6\}>//g')
durationi=$(echo $video_info|sed -n 's/.*Duration: \(.*\) S.*/\1/p')
audioi=$(echo $video_info|sed -n 's/.*Audio: \(.*\) V.*/\1/p')
videoi=$(echo $video_info|sed 's/Audio:.*\(V\)/\1/;s/Duration:.*$//')

declare -a pics=($pictures)

for i in ${pics[@]}
do 
	wget  -U "Mozilla/5.0 (X11; Linux x86_64; rv:19.0) Gecko/20100101 Firefox/19.0" -e robots=off -O ${ttt} --post-data="imgUrl=$i" http://trl.lt/upload.php
	sed -n 's/.*Tiesioginė nuoroda:.*value=\"\(http:\/\/.*\)\" onclick=.*/\1/p' < ${ttt} >>${urltxt}
	sleep 0.5 #dėl visa ko, kad nelaikytų bot'u:)
done

ss1=$(sed -n "1p" ${urltxt})
ss2=$(sed -n "2p" ${urltxt})
ss3=$(sed -n "3p" ${urltxt})
ss4=$(sed -n "4p" ${urltxt})


##################################################
#                                                                Kodo generavimas                                           #
##################################################


sed "s@Pavadinimas_sel@${title}@" ./kodas.txt > ${kodastxt}
sed -i "s@virselio_url\.png@${cover_url}@g" ${kodastxt}
sed -i "s@sukurimo_metai@${reld}@" ${kodastxt}
sed -i "s@salies_name@${country}@" ${kodastxt}
sed -i "s@zanrasss@${genre}@" ${kodastxt}
sed -i "s@aktoriu_sarasas@${cast}@" ${kodastxt}
sed -i "s@trukme_laikas@${durationi}@" ${kodastxt}
sed -i "s@kokybes_sel@${quality}@" ${kodastxt}
sed -i "s@imdb_nr@${IMDBNR}@g" ${kodastxt}
sed -i "s@video_duomenai@${videoi}@" ${kodastxt}
sed -i "s@garso_duomenai@${audioi}@" ${kodastxt}
sed -i "s@kalbos_sel@${kalba}@" ${kodastxt}
sed -i "s@ss1\.png@${ss1}@g" ${kodastxt}
sed -i "s@ss2\.png@${ss2}@g" ${kodastxt}
sed -i "s@ss3\.png@${ss3}@g" ${kodastxt}
sed -i "s@ss4\.png@${ss4}@g" ${kodastxt}

if [[ "$vsample" == "1" ]] 
then
	sed -i 's@sample_vieta@<b>Video sample:</b> <font color="red"><b>Viduje!</b></font>@' ${kodastxt}
else 
	sed -i "s/sample_vieta//" ${kodastxt}
fi

if [[ "${director}" != "" ]] #jei serialas tai rašo "kūrėjai", jei filmas "režisierius"
	then
		sed -i "s@rezisierius_sel@<div class=\"pavadb\">Režisierius(-iai):<span> ${director}</span></div>@" ${kodastxt}
elif [[ "${creators}" != "" ]]
	then
		sed -i "s@rezisierius_sel@<div class=\"pavadb\">Kūrėjas(-ai):<span> ${creators}</span></div>@" ${kodastxt}
else 
		sed -i "s/rezisierius_sel//" ${kodastxt}
fi

if [[ "${DESCR}" != "" ]]
then
	sed -i "s@aprasymo_sel@${DESCR}@" ${kodastxt}
else
	sed -i "s@aprasymo_sel@${desc}@" ${kodastxt}
fi

if [[ "${youtube_trailer}" != "" ]]
then
	sed -i "s@youtube_dalis@<div class=\"description\" id=\"rounded-corners\"><div class=\"header\" id=\"rounded-corners\">Video anonsas:</div><div id=\"centrasVid\"><object><param name=\"movie\" value=\"http://www.youtube.com/v/${youtube_trailer}\"><param name=\"wmode\" value=\"transparent\"><embed src=\"http://www.youtube.com/v/${youtube_trailer}\" type=\"application/x-shockwave-flash\" wmode=\"transparent\"></object></div></div>@" ${kodastxt}
else 
	sed -i "s@youtube_dalis@@" ${kodastxt}
fi
dat=$(wget -qO- --post-data "text=$(cat ${kodastxt})" "http://paste.akmc.lt/api/create")
echo "PRIVMSG #$channel" :$dat >> $config

rm $tempcat $filehtml $trlhtml $trl2html $fffhtml $ttt $urltxt $kodastxt
}

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
    *!trl*) trl $(echo ${MESSAGE}|sed "s/.*PRIVMSG #.*:\![a-z,0-9]*\(.*\)$/\1/;s/%0D//") ;;
    *) echo "${MESSAGE}";;
  esac
done

