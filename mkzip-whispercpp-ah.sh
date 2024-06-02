#!/bin/sh

# zip whisper.cpp files
# exclude:
# whisper.cpp/models/ggml-small.bin
# whisper.cpp/models/ggml-base.en.bin
#zip -rv whispercppah-240303.zip whisper.cpp

MYEXT="-ah"
MYNAME="mkzip-whispercpp${MYEXT}.sh"

# common code, functions
### return code/error code
RET_TRUE=1		# TRUE
RET_FALSE=0		# FALSE
RET_OK=0		# OK
RET_NG=1		# NG
RET_YES=1		# YES
RET_NO=0		# NO
RET_CANCEL=2		# CANCEL

ERR_USAGE=1		# usage
ERR_UNKNOWN=2		# unknown error
ERR_NOARG=3		# no argument
ERR_BADARG=4		# bad argument
ERR_NOTEXISTED=10	# not existed
ERR_EXISTED=11		# already existed
ERR_NOTFILE=12		# not file
ERR_NOTDIR=13		# not dir
ERR_CANTCREATE=14	# can't create
ERR_CANTOPEN=15		# can't open
ERR_CANTCOPY=16		# can't copy
ERR_CANTDEL=17		# can't delete
ERR_BADSETTINGS=18	# bad settings
ERR_BADENVIRONMENT=19	# bad environment
ERR_BADENV=19		# bad environment, short name

# set unique return code from 100
ERR_NOTOPDIR=100	# no topdir
ERR_NOBUILDDIR=101	# no build dir
ERR_NOUSB=102		# no USB found


### flags
VERBOSE=0		# -v --verbose flag, -v -v means more verbose
NOEXEC=$RET_FALSE	# -n --noexec flag
FORCE=$RET_FALSE	# -f --force flag
NODIE=$RET_FALSE	# -nd --nodie
NOCOPY=$RET_FALSE	# -ncp --nocopy
NOTHING=


###
# https://qiita.com/ko1nksm/items/095bdb8f0eca6d327233
# https://qiita.com/PruneMazui/items/8a023347772620025ad6
# https://stackoverflow.com/questions/4842424/list-of-ansi-color-escape-sequences
ESC=$(printf '\033')
ESCRESET="${ESC}[0m"
ESCBOLD="${ESC}[1m"
ESCFAINT="${ESC}[2m"
ESCITALIC="${ESC}[3m"
ESCUL="${ESC}[4m"		# underline
ESCBLINK="${ESC}[5m"		# slow blink
ESCRBLINK="${ESC}[6m"		# rapid blink
ESCREVERSE="${ESC}[7m"
ESCCONCEAL="${ESC}[8m"
ESCDELETED="${ESC}[9m"		# crossed-out
ESCBOLDOFF="${ESC}[22m"		# bold off, faint off
ESCITALICOFF="${ESC}[23m"	# italic off
ESCULOFF="${ESC}[24m"		# underline off
ESCBLINKOFF="${ESC}[25m"	# blink off
ESCREVERSEOFF="${ESC}[27m"	# reverse off
ESCCONCEALOFF="${ESC}[28m"	# conceal off
ESCDELETEDOFF="${ESC}[29m"	# deleted off
ESCBLACK="${ESC}[30m"
ESCRED="${ESC}[31m"
ESCGREEN="${ESC}[32m"
ESCYELLOW="${ESC}[33m"
ESCBLUE="${ESC}[34m"
ESCMAGENTA="${ESC}[35m"
ESCCYAN="${ESC}[36m"
ESCWHITE="${ESC}[37m"
ESCDEFAULT="${ESC}[39m"
ESCBGBLACK="${ESC}[40m"
ESCBGRED="${ESC}[41m"
ESCBGGREEN="${ESC}[42m"
ESCBGYELLOW="${ESC}[43m"
ESCBGBLUE="${ESC}[44m"
ESCBGMAGENTA="${ESC}[45m"
ESCBGCYAN="${ESC}[46m"
ESCBGWHITE="${ESC}[47m"
ESCBGDEFAULT="${ESC}[49m"
ESCBACK="${ESC}[m"

ESCOK="$ESCGREEN"
ESCERR="$ESCRED"
ESCWARN="$ESCMAGENTA"
ESCINFO="$ESCWHITE"

# func:xxmsg ver:2023.12.23
# more verbose message to stderr
# xxmsg "messages"
xxmsg()
{
	if [ $VERBOSE -ge 2 ]; then
		echo "$MYNAME: $*" 1>&2
	fi
}

# func:xmsg ver:2023.12.23
# verbose message to stderr
# xmsg "messages"
xmsg()
{
	if [ $VERBOSE -ge 1 ]; then
		echo "$MYNAME: $*" 1>&2
	fi
}

# func:emsg ver:2023.12.31
# error message to stderr
# emsg "messages"
emsg()
{
	echo "$MYNAME: ${ESCERR}$*${ESCBACK}" 1>&2
}

# func:okmsg ver:2024.01.01
# ok message to stdout
# okmsg "messages"
okmsg()
{
	echo "$MYNAME: ${ESCOK}$*${ESCBACK}"
}

# func:msg ver:2023.12.23
# message to stdout
# msg "messages"
msg()
{
	echo "$MYNAME: $*"
}

# func:die ver:2023.12.31
# die with RETCODE and error message
# die RETCODE "messages"
die()
{
	local RETCODE

	RETCODE=$1
	shift
	xxmsg "die: RETCODE:$RETCODE msg:$*"

	emsg "$*"
	if [ $NODIE -eq $RET_TRUE ]; then
		xmsg "die: nodie"
		return
	fi
	exit $RETCODE
}

# func:nothing ver:2023.12.23
# do nothing function
# nothing
nothing()
{
	NOTHING=
}

###
TOPDIR=whisper.cpp
ZIPBASE=whispercppah

BUILDPATH="$TOPDIR/build"

MODELSPATH1="$TOPDIR/models"
MODELSPATH2="$BUILDPATH/models"
MODELS=""

DATEFOLDERS=""

# flags
EXMODEL=$RET_FALSE
EXGGUF=$RET_FALSE
EXDATE=$RET_FALSE
EXCLUDE=$RET_FALSE
ADDFOLDER=$RET_FALSE
ADDFOLDEROPT=""

###
# set MODELS
do_checkmodels()
{
	msg "# checkmodels"

	local MODELS1 MODELS2

	# ex. ggml/build/models/whisper/ggml-small.bin
	if [ -d $MODELSPATH1 ]; then
		msg "find -L $MODELSPATH1"
		find -L $MODELSPATH1
		MODELS1=`find -L $MODELSPATH1 -type f | awk '{ printf(" %s",$0); }'`
		msg "MODELS1: $MODELS1"
	fi
	if [ -d $MODELSPATH2 ]; then
		msg "find -L $MODELSPATH2"
		find -L $MODELSPATH2
		MODELS2=`find -L $MODELSPATH2 -type f | awk '{ printf(" %s",$0); }'`
		msg "MODELS2: $MODELS2"
	fi

	MODELS="$MODELS $MODELS1 $MODELS2"
}

# set MODELS
do_checkgguf()
{
	msg "# checkgguf"

	local MODELS1 MODELS2

	# ex. ggml/build/240519up/examples/yolo/gguf-py/scripts/yolov3-tiny.gguf 
	if [ -d $TOPDIR ]; then
		MODELS1=`find -L $TOPDIR -type f -name "*.gguf" -size +1M | awk '{ printf(" %s",$0); }'`
		msg "MODELS1: $MODELS1"
	fi

	MODELS="$MODELS $MODELS1 $MODELS2"
}

do_checkdatefolders()
{
	msg "# checkdatefolders"
	# ex. ggml/build/0226up
	if [ -d $BUILDPATH ]; then
		msg "find -L $BUILDPATH"
		#find -L $BUILDPATH
		DATEFOLDERS=`find -L $BUILDPATH -type d | \
		awk '/build.[0-9][0-9][01][0-9][0-3][0-9][[:print:]]*/ { print $0 }'`
		#awk '/build.[0-9][0-9][01][0-9][0-3][0-9][[:print:]]*\// { next } /build.[0-9][0-9][01][0-9][0-3][0-9][[:print:]]*/ { print $0 }'`
		msg "DATEFOLDERS: $DATEFOLDERS"
	fi
}

usage()
{
	echo "usage: $MYNAME [-h][-v][-n][-nd][-xm][-xg][-xd][-xx][-a folders,...] zip-filename|commands"
	echo "options: (default)"
	echo "  -h|--help ... this message"
	echo "  -v|--verbose ... increase verbose message level"
	echo "  -n|--noexec ... no execution, test mode (FALSE)"
	echo "  -nd|--nodie ... no die (FALSE)"
	echo "  -xm|--exmodel ... exclude models in $MODELSPATH1,$MODELSPATH2"
	echo "  -xg|--exgguf ... exclude .gguf >1MB file"
	echo "  -xd|--exdate ... exclude date folders in build folder, except for below id"
	echo "  -xx|--exclude ... do exclude if set below add folders"
	echo "  -a|--add 240602,240602up ... add specified folders in build folder"
	echo "  chkmodels ... check models"
	echo "  chkgguf ... check gguf files"
	echo "  chkdate ... check date folders"
	echo "  zip-filename ... zip filename ex. ${ZIPBASE}-240602up.zip"
}


###
# options
if [ $# = 0 ]; then
	usage
	exit $ERR_USAGE
fi

# save options
ALLOPT="$*"
OPTLOOP=$RET_TRUE
while [ $OPTLOOP -eq $RET_TRUE ];
do
	#msg "OPT: $1"
	case "$1" in
	-h|--help)	usage; exit $ERR_USAGE;;
	-v|--verbose)	VERBOSE=`expr $VERBOSE + 1`;;
	-n|--noexec)	NOEXEC=$RET_TRUE;;
	-nd|--nodie)	NODIE=$RET_TRUE;;
	-xm|--exmodel)	EXMODEL=$RET_TRUE;;
	-xg|--exgguf)	EXGGUF=$RET_TRUE;;
	-xd|--exdate)	EXDATE=$RET_TRUE;;
	-xx|--exclude)	EXCLUDE=$RET_TRUE;;
	-a|--add)	ADDFOLDER=$RET_TRUE; shift; ADDFOLDEROPT=$1;;
	-*)		emsg "# ignore unknown option: $1";;
	*)		OPTLOOP=$RET_FALSE; break;;
	esac
	shift
done

# check
if [ ! -d $TOPDIR ]; then
	emsg "# can't find $TOPDIR, exit"
	exit $ERR_NOTEXISTED
fi

ZIPFILE="$1"
if [ -e $ZIPFILE ]; then
	emsg "# already existed: $ZIPFILE"
	exit $ERR_EXISTED
fi

# do ckeck models
if [ x"$1" = xchkmodels ]; then
	emsg "# do check models"
	do_checkmodels
	exit $RET_OK
fi
if [ x"$1" = xchkgguf ]; then
	emsg "# do check gguf"
	do_checkgguf
	exit $RET_OK
fi

# do ckeck date folders
if [ x"$1" = xchkdate ]; then
	msg "# do check date folders"
	do_checkdatefolders
	exit $RET_OK
fi

# add folders
ADDOPT=""
if [ $ADDFOLDER -eq $RET_TRUE ]; then
	msg "# add folders: $ADDFOLDEROPT"
	ADDFOLDEROPTS=`echo $ADDFOLDEROPT | sed 's/,/ /g'`
	for i in $ADDFOLDEROPTS
	do
		msg "# add folders: $i"
		if [ -d $BUILDPATH/$i ]; then
			ADDOPT="$ADDOPT $BUILDPATH/$i"
		elif [ -f $BUILDPATH/$i ]; then
			emsg "$i: not a folder, skip"
		else
			emsg "$i: not existed or others, skip"
		fi
	done
fi

# delete CMakeFiles
if [ -d $BUILDPATH/CMakeFiles ]; then
	msg "# no rm -rf $BUILDPATH/CMakeFiles"
	#msg "rm -rf $BUILDPATH/CMakeFiles"
	#rm -rf $BUILDPATH/CMakeFiles
fi

# exclude models
XOPT=""
if [ $EXMODEL -eq $RET_TRUE ]; then
	do_checkmodels
	msg "# exclude models"
fi
if [ $EXGGUF -eq $RET_TRUE ]; then
	do_checkgguf
	msg "# exclude gguf"
fi
xmsg "MODELS: $MODELS"
if [ ! x"$MODELS" = x ]; then
	for i in $MODELS
	do
		XOPT="$XOPT -x $i"
	done
fi

# exclude date folders
if [ $EXDATE -eq $RET_TRUE ]; then
	do_checkdatefolders
	for i in $DATEFOLDERS
	do
		XOPT="$XOPT -x $i/*"
	done
	msg "# exclude date folders"
fi
xmsg "XOPT: $XOPT"

# do zip
msg "zip -rvy $ZIPFILE $TOPDIR $XOPT"
zip -rvy $ZIPFILE $TOPDIR $XOPT

if [ $ADDFOLDER -eq $RET_TRUE ]; then
	if [ $EXCLUDE -eq $RET_FALSE ]; then
		msg "zip -rvy $ZIPFILE $ADDOPT"
		zip -rvy $ZIPFILE $ADDOPT
	else
		msg "zip -rvy $ZIPFILE $ADDOPT $XOPT"
		zip -rvy $ZIPFILE $ADDOPT $XOPT
	fi
fi

msg "# finished"

msg "$ $MYNAME $ALLOPT"
msg "ls -l $ZIPFILE"
ls -l $ZIPFILE
# end

