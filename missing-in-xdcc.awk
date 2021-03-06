#!/usr/bin/awk -f
BEGIN {
#	DEBUG = 1
	IGNORECASE = 1
	SAVED_FS = FS
	FS = "|"
        CONTROL = "alle2dk"
	while ( ( res = getline < CONTROL ) > 0 ) {
		NAME = tolower( $3 )
		NAME_CACHE[ NAME ] = 1
		if ( match( NAME, "[({[](crc[_-]*)*[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][]})]" ) ) {
			CRC = substr( NAME, RSTART + 1, RLENGTH - 2 )
			sub( "(crc[_-]*)", "", CRC )
			CRC_CACHE[ CRC ] = NAME
		}
        }
	close( CONTROL )
	FS = SAVED_FS
}
function ausgabe() {
	PACK ++

	NAME = tolower( XD )
	if ( NAME_CACHE[ NAME ] == 1 ) {
		if ( DEBUG != "" )
			printf( "%3s (identical name) %s\n", "#" PACK, XD )
		return
	}
	CRC = ""
	if ( match( NAME, "[({[](crc[_-]*)*[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][]})]" ) ) {
		CRC = substr( NAME, RSTART + 1, RLENGTH - 2 )
		sub( "(crc[_-]*)", "", CRC )
		if ( CRC_CACHE[ CRC ] != "" ) {
			if ( DEBUG != "" )
				printf( "%3s (crc found) %s -> %s\n", "#" PACK, XD, CRC_CACHE[ CRC ] )
			return
		}
	}
	KEY = tolower( XD )
	gsub( "german.sub", " ", KEY )
	gsub( "ger.sub", " ", KEY )
	gsub( "gersub", " ", KEY )
	gsub( "episode", " ", KEY )
	gsub( "ep", " ", KEY )
	gsub( "german", " ", KEY )
	gsub( "fansub", " ", KEY )
	gsub( "divx5", " ", KEY )
	gsub( "xvid", " ", KEY )
	gsub( "v2", " v 2", KEY )
	gsub( "arcthelad", "arc the lad", KEY )
	gsub( "gasbastard", "gas bastard", KEY )
	gsub( "[.]", " ", KEY )
	gsub( "[[&+() _,`!\\]-]+", ".*", KEY )
	gsub( "reminisence", "reminiscence", KEY )
	gsub( "[*]0+", "*[0]*", KEY )
#	gsub( "0", "[0]*", KEY )
	for ( NAME in NAME_CACHE ) {
		if ( NAME_CACHE[ NAME ] != 1 )
			continue
		if ( match( NAME, KEY ) ) {
			if ( DEBUG != "" )
				printf( "%3s (name found) %s -> %s\n", "#" PACK, XD, NAME )
			return
		}
	}
	if ( ( DEBUG != "" ) && ( CRC == "" ) )
		print KEY
	printf( "%3s %s\n", "#" PACK, XD )
}
END {
	ausgabe()
}
/Do Not Edit This File/ {
#	Do Not Edit This File: 50.08 50.43 15173264677 1638743
	if ( LAST_KEY != "" ) {
		ausgabe()
		XF = ""
		print ""
	}
	PACK = 0
	next
}
/^$/ {
	if ( XF == "" )
		next

	ausgabe()
}
/^xx_file/ {
	XF = substr( $0, 9 )
	next
}
/^xx_desc/ {
	XD = substr( $0, 9 )
	next
}
#
