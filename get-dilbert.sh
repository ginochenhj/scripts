#
# get-dilbert.sh License
#
# Copyright © 2016, Gino Chen HJ. All Rights Reserved.
#
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, 
# this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice, 
# this list of conditions and the following disclaimer 
# in the documentation and/or other materials provided with the distribution.
#
# 3. The name of the author may not be used to endorse or promote products 
# derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY Gino Chen HJ "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO 
# EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

# 
# Download Dilbert Comics strips from official site
# 
# You can run this script using bash/Cygwin on Windows
#

#!/bin/bash

URL_HTML_ROOT="http://dilbert.com/strip"
URL_IMG_ROOT="http://assets.amuniversal.com"

function PMkdir() {
	if [ ! -d "$1" ] ; then
		mkdir -p "$1"
	fi
}

DT_FIRST='890416'

i=0
bDone=0
while [ $bDone != 1 ] ; do
	DT=$(date -d '-'$i' days' +"%y%m%d")
	Y=${DT:0:2}
	M=${DT:2:2}
	D=${DT:4:2}
	IMG_DIR="img/$Y/$M"
	TMP_DIR=tmp
	TXT_DIR="$IMG_DIR"
	TXT="$TXT_DIR/$DT.txt"

	PMkdir "$IMG_DIR"
	PMkdir "$TMP_DIR"

	if [ ! -f "$TXT" ] ; then
		URL_HTML="$URL_HTML_ROOT/$Y-$M-$D"
		HTML="$TMP_DIR/$DT.html"
		WGET_IMG_OUT="$TMP_DIR/$DT.out"

		wget -O "$HTML" $URL_HTML

		IMG=$(grep -o -m 1 -e "$URL_IMG_ROOT"'/[0-9a-f]\+' "$HTML")
		wget --referer="$URL" -P "$IMG_DIR" $IMG 2> "$WGET_IMG_OUT"
		IMG_OUT=$(grep -o -e "image/[a-z]\+" "$WGET_IMG_OUT")
		mv "$IMG_DIR/${IMG##*/}" "$IMG_DIR/$DT"'.'"${IMG_OUT#*/}"
		sed -n -e 's|.\+data-description="\([^"]\+\)".\+|\1|p' "$HTML" | recode html..ascii > "$TXT"
	fi
	if [ $DT_FIRST == $DT ] ; then
		bDone=1
	fi
	((++i))
done
