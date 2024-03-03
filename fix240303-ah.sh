#!/bin/sh

MYEXT="-ah"
MYNAME=fix240303${MYEXT}.sh

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

### flags
VERBOSE=0		# -v --verbose flag, -v -v means more verbose
NOEXEC=$RET_FALSE	# -n --noexec flag
FORCE=$RET_FALSE	# -f --force flag
NODIE=$RET_FALSE	# -nd --nodie
NOCOPY=$RET_FALSE	# -ncp --nocopy
NOTHING=

###
# https://qiita.com/ko1nksm/items/095bdb8f0eca6d327233
ESC=$(printf '\033')
ESCBLACK="${ESC}[30m"
ESCRED="${ESC}[31m"
ESCGREEN="${ESC}[32m"
ESCYELLOW="${ESC}[33m"
ESCBLUE="${ESC}[34m"
ESCMAGENTA="${ESC}[35m"
ESCCYAN="${ESC}[36m"
ESCWHITEL="${ESC}[37m"
ESCDEFAULT="${ESC}[38m"
ESCBACK="${ESC}[m"
ESCRESET="${ESC}[0m"

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

# func:cmd ver:2024.02.17
# show given command CMD and do(eval) it
# cmd "CMD"
cmd()
{
	msg $*
	if [ $NOEXEC -eq $RET_FALSE ]; then
		eval $*
	fi
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
NAMEBASE=fix

CMD=chk
RESULT=0
DT0=
DT1=

###
#do_cp ggml.c	ggml.c.0625	ggml.c.0625mod

# diff old $1 $2 $OPT
diff_old()
{
	# in $TOPDIR

	xmsg "diff_old: CMD:$CMD $1 $2 $3 $4  OPT:$OPT"

	local NEWDATE NEW OLD

	if [ ! x"$OPT" = x ]; then
		NEWDATE=`echo $2 | sed -e 's/\(.*\)\.\([0-9][0-9][01][0-9][0-3][0-9]\)/\2/'`
		#msg "diff: NEW:$NEWDATE"
		if [ ! x"$NEWDATE" = x"$OPT" ]; then
			msg "diff: skip $2 by $NEWDATE"
			return
		fi
	fi

	#msg "diff_old $1 $2"
	NEW="./$2"
	OLD=`find . -path './'$1'.[0-9][0-9][01][0-9][0-3][0-9]' | awk -v NEW="$NEW" '
	$0 != NEW { OLD=$0 }
	END   { print OLD }'`
	okmsg "diff -c $OLD $NEW"
	diff -c $OLD $NEW
}

# do_cp target origin modified
do_cp()
{
	xmsg "do_cp: CMD:$CMD $1 $2 $3 $4"

	local FILES

	FILES="$1 $2"
	if [ -f "$3" ]; then
		FILES="$FILES $3"
	fi
	if [ $# = 4 ]; then
		if [ -f "$4" ]; then
			FILES="$FILES $4"
		fi
	fi

	# check
	case $CMD in
	upd|update)
		if [ -f "$1" ]; then
			XDT=`ls -ltr --time-style=+%Y%m%d%H%M%S $1 | awk '
			BEGIN { XDT="0" }
			{ DT=$6; T=$0; sub(/[\n\r]$/,"",T); I=index(T,DT); I=I+length(DT)+1; if (DT > XDT) { XDT=DT }; }
			END { printf("%s",XDT) }
			'`
			XDT2=`echo $XDT | awk '{ T=$0; T=substr(T,3,6); print T }'`
			msg "$XDT: $XDT2: $1"
			XF="$1.$XDT2"
			if [ ! -f "$XF" ]; then
				msg "cp -p \"$1\" \"$XF\""
				cp -p "$1" "$XF"
				if [ ! -f "$XF" ]; then
					emsg "$XF: can't create"
				else
					msg "ls -l \"$XF\""
					ls -l "$XF"
				fi
			fi
		fi
		;;
	chk|check)
		msg "ls -l $FILES"
		ls -l $FILES
		if [ -f "$1" ]; then
			okmsg "diff -c $2 $1"
			diff -c $2 $1
			xmsg "RESULT: $RESULT $?"
			RESULT=`expr $RESULT + $?`
		fi
		;;
	chkmod|checkmod)
		msg "ls -l $FILES"
		ls -l $FILES
		if [ -f "$3" ]; then
			okmsg "diff -c $1 $3"
			diff -c $1 $3
			RESULT=`expr $RESULT + $?`
		fi
		;;
	chkmod2|checkmod2)
		msg "ls -l $FILES"
		ls -l $FILES
		if [ $# = 4 ]; then
			if [ -f "$4" ]; then
				okmsg "diff -c $1 $4"
				diff -c $1 $4
				RESULT=`expr $RESULT + $?`
			elif [ -f "$3" ]; then
				okmsg "diff -c $1 $3"
				diff -c $1 $3
				RESULT=`expr $RESULT + $?`
			fi
		else
			if [ -f "$3" ]; then
				okmsg "diff -c $1 $3"
				diff -c $1 $3
				RESULT=`expr $RESULT + $?`
			fi
		fi
		;;
	chkmod12|checkmod12)
		msg "ls -l $FILES"
		ls -l $FILES
		if [ $# = 4 ]; then
			if [ -f "$4" ]; then
				okmsg "diff -c $3 $4"
				diff -c $3 $4
				RESULT=`expr $RESULT + $?`
			elif [ -f "$3" ]; then
				okmsg "diff -c $2 $3"
				diff -c $2 $3
				RESULT=`expr $RESULT + $?`
			fi
		else
			if [ -f "$3" ]; then
				okmsg "diff -c $2 $3"
				diff -c $2 $3
				RESULT=`expr $RESULT + $?`
			fi
		fi
		;;
	master)
		msg "cp -p $2 $1"
		cp -p $2 $1
		RESULT=`expr $RESULT + $?`
		;;
	mod)
		if [ -f "$3" ]; then
			msg "cp -p $3 $1"
			cp -p $3 $1
			RESULT=`expr $RESULT + $?`
		fi
		;;
	mod2)
		if [ $# = 4 ]; then
			if [ -f $4 ]; then
				msg "cp -p $4 $1"
				cp -p $4 $1
				RESULT=`expr $RESULT + $?`
			elif [ -f $3 ]; then
				msg "cp -p $3 $1"
				cp -p $3 $1
				RESULT=`expr $RESULT + $?`
			fi
		else
			if [ -f $3 ]; then
				msg "cp -p $3 $1"
				cp -p $3 $1
				RESULT=`expr $RESULT + $?`
			fi
		fi
		;;
	diff)
		msg "diff: $1 $2"
		diff_old $1 $2
		;;
	*)	emsg "unknown command: $CMD"
		;;
	esac
}

do_mk()
{
	local OPT DT0 DT1 NEWNAME

	OPT="$1"

	DT0=`echo $MYNAME | sed -e 's/'$NAMEBASE'//' -e 's/'${MYEXT}'.sh//'`
	DT1=`date '+%y%m%d'`
	# overwrite
	if [ ! x"$OPT" = x ]; then
		DT1="$OPT"
	fi
	msg "DT0: $DT0  DT1: $DT1"

	NEWNAME=$NAMEBASE$DT1$MYEXT.sh
	msg "making new $NAMEBASE script $NEWNAME and copy backup files ..."

#do_cp ggml.c	     ggml.c.0420	     ggml.c.0420mod    ggml.c.0420mod2
#do_cp examples/CMakeLists.txt examples/CMakeLists.txt.0413 examples/CMakeLists.txt.0415mod
	cat $MYNAME | awk -v DT0=$DT0 -v DT1=$DT1 -v TOP=$TOPDIR '
	function exists(file) {
		n=(getline _ < file);
		#printf "# n:%d %s\n",n,file;
		if (n > 0) {
			return 1; # found
		} else if (n == 0) {
			return 1; # empty
		}
		return 0; # error
	}
	function update(L) {
		NARG=split(L, ARG, /[ \t]/);
		TOPFILE=TOP "/" ARG[2]
		TOPFILEDT1=TOP "/" ARG[2] "." DT1
		#if (exists(TOPFILE)==0) { printf "# %s\n",L; return 1; }
		if (exists(TOPFILE)==0) { return 1; }
		CMD="date '+%y%m%d' -r " TOPFILE;
		CMD | getline; DT=$0;
		TOPFILEDT=TOP "/" ARG[2] "." DT
		printf "do_cp %s\t%s.%s\t%s.%smod\n",ARG[2],ARG[2],DT,ARG[2],DT1;
		#if (exists(TOPFILEDT)==1) { printf "# %s skip cp\n",TOPFILEDT; return 0; }
		if (exists(TOPFILEDT)==1) { return 0; }
		if (DT==DT1) { CMD="cp -p " TOPFILE " " TOPFILEDT1; print CMD > stderr; system(CMD); }
		return 0;
	}
	BEGIN			{ stderr="/dev/stderr"; st=1 }
	st==1 && /^MYNAME=/	{ L=$0; sub(DT0, DT1, L); print L; st=2; next }
	st==2 && /^usage/	{ L=$0; print L; st=3; next }
	st==3 && /^do_cp /	{ L=$0; update(L); next }
	st==3			{ L=$0; gsub(DT0, DT1, L); print L; next }
				{ L=$0; print L; next }
	' - > $NEWNAME.$$

	if [ ! -f $NEWNAME.$$ ]; then
		emsg "can't create $NEWNAME"
		return $ERR_CANTCREATE
	fi
	if [ ! -s $NEWNAME.$$ ]; then
		emsg "size zero $NEWNAME"
		return $ERR_CANTCREATE
	fi

	msg "mv $NEWNAME.$$ $NEWNAME"
	mv $NEWNAME.$$ $NEWNAME
	msg "ls -l $NEWNAME"
	ls -l $NEWNAME

	grep "^MYNAME=" $NEWNAME

	msg "$NEWNAME created"
}

###
usage()
{
	echo "usage: $MYNAME [-h][-v][-n][-nd][-ncp] chk|chkmod|chkmod2|chkmod12|master|mod|mod2|diff [DT]|mk [DT]|new [DT]"
	echo "options: (default)"
	echo "  -h|--help ... this message"
	echo "  -v|--verbose ... increase verbose message level"
	echo "  -n|--noexec ... no execution, test mode (FALSE)"
	echo "  -nd|--nodie ... no die (FALSE)"
	echo "  -ncp|--nocopy ... no copy (FALSE)"
	echo "  chk ... diff master"
	echo "  chkmod ... diff mod"
	echo "  chkmod2 ... diff mod2"
	echo "  chkmod12 ... diff mod mod2"
	echo "  master ... cp master files on 240127"
	echo "  mod ... cp mod files on 240127"
	echo "  mod2 ... cp mod2 files on 240127"
	echo "  diff [DT] ... diff old and new, new on DT only if set DT"
	echo "  mk [DT] ... create new shell script"
	echo "  new [DT] ... show new files since DT"
}

###
if [ x"$1" = x -o x"$1" = "x-h" ]; then
	usage
	exit $ERR_USAGE
fi

ALLOPT="$*"
OPTLOOP=$RET_TRUE
while [ $OPTLOOP -eq $RET_TRUE ];
do
	case $1 in
	-h|--help)	usage; exit $ERR_USAGE;;
	-v|--verbose)   VERBOSE=`expr $VERBOSE + 1`;;
	-n|--noexec)    NOEXEC=$RET_TRUE;;
	-nd|--nodie)	NODIE=$RET_TRUE;;
	-ncp|--nocopy)	NOCOPY=$RET_TRUE;;
	*)		OPTLOOP=$RET_FALSE; break;;
	esac
	shift
done

ORGCMD="$1"
CMD="$1"
OPT="$2"
msg "CMD: $CMD"
msg "OPT: $OPT"

if [ $CMD = "mk" ]; then
	do_mk $OPT
	exit $RET_OK
fi
if [ $CMD = "new" ]; then
	#-rw-r--r-- 1 user user 6512 Oct  1 04:40 ggml/CMakeLists.txt
	#-rw-r--r-- 1 user user 6512 Oct  1 04:40 ggml/CMakeLists.txt.1001
	#-rw-r--r-- 1 user user 5898 Oct  1 04:40 ggml/README.md
	DT1=`date '+%y%m%d'`
	#NEWDATE=`echo $2 | sed -e 's/\(.*\)\.\([0-9][0-9][01][0-9][0-3][0-9]\)/\2/'`
	#find $TOPDIR -type f -mtime 0 -exec ls -l '{}' \; | awk -v DT1=$DT1 '
	find $TOPDIR -type f -mtime 0 | awk -v DT1=$DT1 '
	BEGIN { PREV="" }
	#{ print "line: ",$0; }
	#{ ADDDT=PREV "." DT1; if (ADDDT==$0) { print "same: ",$0; PREV="" } else if (PREV=="") { PREV=$0 } else { print "new: ",PREV; PREV=$0 } }
	#END { ADDDT=PREV "." DT1; if (ADDDT==$0) { print "same: ",$0; } else if (PREV=="") { ; } else { print "new: ",PREV; } }
	{ ADDDT=PREV "." DT1; if (ADDDT==$0) { PREV="" } else if (PREV=="") { PREV=$0 } else { print "new: ",PREV; PREV=$0 } }
	END { ADDDT=PREV "." DT1; if (ADDDT==$0) { ; } else if (PREV=="") { ; } else { print "new: ",PREV; } }
	' -
	exit $RET_OK
fi


###
if [ ! -d $TOPDIR ]; then
	die $ERR_NOTEXISTED "no $TOPDIR, exit"
fi
cd $TOPDIR

msg "git branch"
if [ $NOEXEC -eq $RET_FALSE ]; then
	git branch
fi

# check:  ls -l target origin modified
# revert: cp -p origin target
# revise: cp -p modifid target
#
# do_cp target origin(master) modified(gq)
RESULT=0
do_cp CMakeLists.txt	CMakeLists.txt.240225	CMakeLists.txt.240303mod
do_cp Makefile	Makefile.240225	Makefile.240303mod
do_cp ggml-alloc.c	ggml-alloc.c.240225	ggml-alloc.c.240303mod
do_cp ggml-alloc.h	ggml-alloc.h.240225	ggml-alloc.h.240303mod
do_cp ggml-backend.h	ggml-backend.h.240303	ggml-backend.h.240303mod
do_cp ggml-backend.c	ggml-backend.c.240303	ggml-backend.c.240303mod
do_cp ggml-impl.h	ggml-impl.h.240225	ggml-impl.h.240303mod
do_cp ggml-opencl.cpp	ggml-opencl.cpp.240303	ggml-opencl.cpp.240303mod
do_cp ggml-opencl.h	ggml-opencl.h.240225	ggml-opencl.h.240303mod
do_cp ggml-quants.c	ggml-quants.c.240303	ggml-quants.c.240303mod
do_cp ggml-quants.h	ggml-quants.h.240303	ggml-quants.h.240303mod
do_cp ggml-sycl.cpp	ggml-sycl.cpp.240303	ggml-sycl.cpp.240303mod
do_cp ggml-sycl.h	ggml-sycl.h.240225	ggml-sycl.h.240303mod
do_cp ggml-vulkan.cpp	ggml-vulkan.cpp.240303	ggml-vulkan.cpp.240303mod
do_cp ggml-vulkan.h	ggml-vulkan.h.240225	ggml-vulkan.h.240303mod
do_cp ggml.h	ggml.h.240303	ggml.h.240303mod
do_cp ggml.c	ggml.c.240303	ggml.c.240303mod
do_cp whisper.h	whisper.h.240225	whisper.h.240303mod
do_cp whisper.cpp	whisper.cpp.240225	whisper.cpp.240303mod
do_cp examples/CMakeLists.txt	examples/CMakeLists.txt.240303	examples/CMakeLists.txt.240303mod
do_cp examples/common-ggml.cpp	examples/common-ggml.cpp.240303	examples/common-ggml.cpp.240303mod
do_cp examples/common-ggml.h	examples/common-ggml.h.240225	examples/common-ggml.h.240303mod
do_cp examples/common-sdl.cpp	examples/common-sdl.cpp.240225	examples/common-sdl.cpp.240303mod
do_cp examples/common-sdl.h	examples/common-sdl.h.240225	examples/common-sdl.h.240303mod
do_cp examples/common.cpp	examples/common.cpp.240225	examples/common.cpp.240303mod
do_cp examples/common.h	examples/common.h.240225	examples/common.h.240303mod
do_cp examples/dr_wav.h	examples/dr_wav.h.240225	examples/dr_wav.h.240303mod
do_cp examples/grammar-parser.cpp	examples/grammar-parser.cpp.240225	examples/grammar-parser.cpp.240303mod
do_cp examples/grammar-parser.h	examples/grammar-parser.h.240225	examples/grammar-parser.h.240303mod
do_cp examples/main/CMakeLists.txt	examples/main/CMakeLists.txt.240225	examples/main/CMakeLists.txt.240303mod
do_cp examples/main/main.cpp	examples/main/main.cpp.240225	examples/main/main.cpp.240303mod
do_cp examples/bench/CMakeLists.txt	examples/bench/CMakeLists.txt.240225	examples/bench/CMakeLists.txt.240303mod
do_cp examples/bench/bench.cpp	examples/bench/bench.cpp.240225	examples/bench/bench.cpp.240303mod
do_cp examples/quantize/CMakeLists.txt	examples/quantize/CMakeLists.txt.240225	examples/quantize/CMakeLists.txt.240303mod
do_cp examples/quantize/quantize.cpp	examples/quantize/quantize.cpp.240225	examples/quantize/quantize.cpp.240303mod
do_cp examples/sycl/CMakeLists.txt	examples/sycl/CMakeLists.txt.240225	examples/sycl/CMakeLists.txt.240303mod
do_cp tests/CMakeLists.txt	tests/CMakeLists.txt.240225	tests/CMakeLists.txt.240303mod
msg "RESULT: $RESULT"

if [ $CMD = "chk" ];then
	if [ $RESULT -eq 0 ]; then
		msg "ok for zipping, syncing"
	else
		emsg "do $MYNAME chkmod and $MYNAME master before zipping, syncing"
	fi
fi
if [ $CMD = "chkmod" ];then
	if [ $RESULT -eq 0 ]; then
		msg "ok for do $MYNAME master and then zipping, syncing"
	else
		emsg "save files and update $MYNAME"
	fi
fi
if [ $CMD = "chkmod2" ];then
	if [ $RESULT -eq 0 ]; then
		msg "ok for do $MYNAME master and then zipping, syncing"
	else
		emsg "save files and update $MYNAME"
	fi
fi

# cmake .. -DLLAMA_AVX=ON -DLLAMA_AVX=OFF -DLLAMA_AVX512=OFF -DLLAMA_FMA=OFF -DLLAMA_OPENBLAS=ON -DLLAMA_STANDALONE=ON -DLLAMA_BUILD_EXAMPLES=ON
# make
# GGML_NLOOP=1 GGML_NTHREADS=4 make test
msg "end"

