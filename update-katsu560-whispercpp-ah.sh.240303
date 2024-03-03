#!/bin/bash

# update katsu560/whisper.cpp
# T902 Intel(R) Core(TM) i5-3320M CPU @ 2.60GHz  2C/4T F16C,AVX IvyBridge/3rd Gen.
# AH   Intel(R) Core(TM) i3-10110U CPU @ 2.10GHz  2C/4T F16C,AVX,AVX2,FMA CometLake/10th Gen.

MYEXT="-ah"
MYNAME=update-katsu560-whispercpp${MYEXT}.sh

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

FUNCTEST_OK=0
FUNCTEST_NG=0
# func:func_test_reset ver:2023.12.30
# reset FUNCTEST_OK, FUNCTEST_NG
# func_test_reset
func_test_reset()
{
	FUNCTEST_OK=0
	FUNCTEST_NG=0
	xmsg "func_test_reset: FUNCTEST_OK:$FUNCTEST_OK FUNCTEST_NG:$FUNCTEST_NG"
}

# func:func_test_show ver:2024.01.08
# show FUNCTEST_OK, FUNCTEST_NG
# func_test_reset
func_test_show()
{
	if [ $FUNCTEST_NG -eq 0 ]; then
		okmsg "func_test_show: FUNCTEST_OK:$FUNCTEST_OK FUNCTEST_NG:$FUNCTEST_NG"
	else
		emsg "func_test_show: FUNCTEST_OK:$FUNCTEST_OK FUNCTEST_NG:$FUNCTEST_NG"
	fi
}

# func:func_test ver:2023.12.30
# check return code of func test with OKCODE and output message for test code
# func_test OKCODE "messages"
func_test()
{
	RETCODE=$?

	OKCODE=$1
	shift
	TESTMSG="$*"

	if [ $RETCODE -eq $OKCODE ]; then
		FUNCTEST_OK=`expr $FUNCTEST_OK + 1`
		msg "${ESCOK}test:OK${ESCBACK}: ret:$RETCODE expected:$OKCODE $TESTMSG"
	else
		FUNCTEST_NG=`expr $FUNCTEST_NG + 1`
		msg "${ESCERR}${ESCBOLD}test:NG${ESCBOLDOFF}${ESCBACK}: ret:$RETCODE expected:$OKCODE ${ESCRED}$TESTMSG${ESCBACK}"
	fi
	msg "----"
}

# func:set_ret ver:2023.12.23
# set $? as return code for test code
# set_ret RETCODE
set_ret()
{
	return $1
}

# dolevel
LEVELMIN=1
LEVELSTD=3
LEVELMAX=5
DOLEVEL=$LEVELSTD
# func:chk_level ver: 2024.01.08
# check given LEVEL less or equal than DOLEVEL, then do ARGS
# chk_level LEVEL ARGS ...
chk_level()
{
	xxmsg "chk_level: DOLEVEL:$DOLEVEL LEVEL:$1 ARGS:$*"

	local LEVEL RETCODE CHK

	RETCODE=$RET_OK

	# check DOLEVEL
	if [ x"$DOLEVEL" = x ]; then
		emsg "chk_level: need set DOLEVEL, skip"
		return $ERR_BADSETTINGS
	fi
	# check args
	if [ x"$1" = x ]; then
		emsg "chk_level: need LEVEL, skip"
		return $ERR_NOARG
	fi
	LEVEL="$1"
	CHK=`echo $LEVEL | awk '!/['$LEVELMIN'-'$LEVELMAX']/ { print "BADVALUE"; exit } { print $0 }'`
	if [ $CHK = "BADVALUE" ]; then
		emsg "chk_level: LEVEL:$LEVEL bad value, skip"
		return $ERR_BADARG
	fi
	if [ $LEVEL -lt $LEVELMIN -o $LEVELMAX -lt $LEVEL ]; then
		emsg "chk_level: LEVEL:$LEVEL bad value, skip"
		return $ERR_BADARG
	fi
	shift
	if [ ! $# -gt 0 ]; then
		emsg "chk_level: need ARGS, skip"
		return $ERR_NOARG
	fi

	xmsg "chk_level: LEVEL:$DOLEVEL >= $LEVEL do $*"
	if [ $DOLEVEL -ge $LEVEL ]; then
		xmsg "chk_level: do $*"
		eval $*
		RETCODE=$?
	else
		xmsg "${ESCWARN}chk_level: skip $*${ESCBACK}"
		RETCODE=$RET_OK
	fi

	xxmsg "chk_level: RETCODE:$RETCODE"
	return $RETCODE
}
test_chk_level_func()
{
	okmsg "test_chk_level_func: $*"
	return $RET_OK
}
test_chk_level()
{
	local DOLEVELBK LEVELNONUM LEVELZERO LEVELBAD

	# set test env
	DOLEVELBK=$DOLEVEL
	LEVELNONUM="NONUM"
	LEVELZERO=`expr $LEVELMIN - 1`
	LEVELBAD=`expr $LEVELMAX + 1`
	func_test_reset

	# test code
	DOLEVEL=
	msg "test_chk_level: DOLEVEL:$DOLEVEL"
	chk_level
	func_test $ERR_BADSETTINGS "bad settings: chk_level"

	chk_level $LEVELMIN
	func_test $ERR_BADSETTINGS "bad settings: chk_level $LEVELMIN"
	chk_level $LEVELMIN test_chk_level_func
	func_test $ERR_BADSETTINGS "bad settings: chk_level $LEVELMIN test_chk_level_func"
	chk_level $LEVELMIN test_chk_level_func arg1
	func_test $ERR_BADSETTINGS "bad settings: chk_level $LEVELMIN test_chk_level_func arg1"
	chk_level $LEVELMIN test_chk_level_func arg1 arg2
	func_test $ERR_BADSETTINGS "bad settings: chk_level $LEVELMIN test_chk_level_func arg1 arg2"
	chk_level $LEVELSTD
	func_test $ERR_BADSETTINGS "bad settings: chk_level $LEVELSTD"
	chk_level $LEVELSTD test_chk_level_func
	func_test $ERR_BADSETTINGS "bad settings: chk_level $LEVELSTD test_chk_level_func"
	chk_level $LEVELSTD test_chk_level_func arg1
	func_test $ERR_BADSETTINGS "bad settings: chk_level $LEVELSTD test_chk_level_func arg1"
	chk_level $LEVELSTD test_chk_level_func arg1 arg2
	func_test $ERR_BADSETTINGS "bad settings: chk_level $LEVELSTD test_chk_level_func arg1 arg2"
	chk_level $LEVELMAX
	func_test $ERR_BADSETTINGS "bad settings: chk_level $LEVELMAX"
	chk_level $LEVELMAX test_chk_level_func
	func_test $ERR_BADSETTINGS "bad settings: chk_level $LEVELMAX test_chk_level_func"
	chk_level $LEVELMAX test_chk_level_func arg1
	func_test $ERR_BADSETTINGS "bad settings: chk_level $LEVELMAX test_chk_level_func arg1"
	chk_level $LEVELMAX test_chk_level_func arg1 arg2
	func_test $ERR_BADSETTINGS "bad settings: chk_level $LEVELMAX test_chk_level_func arg1 arg2"
	chk_level $LEVELNONUM
	func_test $ERR_BADSETTINGS "bad settings: chk_level $LEVELNONUM"
	chk_level $LEVELNONUM test_chk_level_func
	func_test $ERR_BADSETTINGS "bad settings: chk_level $LEVELNONUM test_chk_level_func"
	chk_level $LEVELNONUM test_chk_level_func arg1
	func_test $ERR_BADSETTINGS "bad settings: chk_level $LEVELNONUM test_chk_level_func arg1"
	chk_level $LEVELNONUM test_chk_level_func arg1 arg2
	func_test $ERR_BADSETTINGS "bad settings: chk_level $LEVELNONUM test_chk_level_func arg1 arg2"
	chk_level $LEVELZERO
	func_test $ERR_BADSETTINGS "bad settings: chk_level $LEVELZERO"
	chk_level $LEVELZERO test_chk_level_func
	func_test $ERR_BADSETTINGS "bad settings: chk_level $LEVELZERO test_chk_level_func"
	chk_level $LEVELZERO test_chk_level_func arg1
	func_test $ERR_BADSETTINGS "bad settings: chk_level $LEVELZERO test_chk_level_func arg1"
	chk_level $LEVELZERO test_chk_level_func arg1 arg2
	func_test $ERR_BADSETTINGS "bad settings: chk_level $LEVELZERO test_chk_level_func arg1 arg2"
	chk_level $LEVELBAD
	func_test $ERR_BADSETTINGS "bad settings: chk_level $LEVELBAD"
	chk_level $LEVELBAD test_chk_level_func
	func_test $ERR_BADSETTINGS "bad settings: chk_level $LEVELBAD test_chk_level_func"
	chk_level $LEVELBAD test_chk_level_func arg1
	func_test $ERR_BADSETTINGS "bad settings: chk_level $LEVELBAD test_chk_level_func arg1"
	chk_level $LEVELBAD test_chk_level_func arg1 arg2
	func_test $ERR_BADSETTINGS "bad settings: chk_level $LEVELBAD test_chk_level_func arg1 arg2"

	DOLEVEL=$LEVELMIN
	msg "----"
	msg "test_chk_level: DOLEVEL:$DOLEVEL"
	chk_level
	func_test $ERR_NOARG "no arg: chk_level"

	chk_level $LEVELMIN
	func_test $ERR_NOARG "no arg: chk_level $LEVELMIN"
	chk_level $LEVELMIN test_chk_level_func
	func_test $RET_OK "ok: chk_level $LEVELMIN test_chk_level_func"
	chk_level $LEVELMIN test_chk_level_func arg1
	func_test $RET_OK "ok: chk_level $LEVELMIN test_chk_level_func arg1"
	chk_level $LEVELMIN test_chk_level_func arg1 arg2
	func_test $RET_OK "ok: chk_level $LEVELMIN test_chk_level_func arg1 arg2"
	chk_level $LEVELSTD
	func_test $ERR_NOARG "no arg: chk_level $LEVELSTD"
	chk_level $LEVELSTD test_chk_level_func
	func_test $RET_OK "ok: chk_level $LEVELSTD test_chk_level_func"
	chk_level $LEVELSTD test_chk_level_func arg1
	func_test $RET_OK "ok: chk_level $LEVELSTD test_chk_level_func arg1"
	chk_level $LEVELSTD test_chk_level_func arg1 arg2
	func_test $RET_OK "ok: chk_level $LEVELSTD test_chk_level_func arg1 arg2"
	chk_level $LEVELMAX
	func_test $ERR_NOARG "no arg: chk_level $LEVELMAX"
	chk_level $LEVELMAX test_chk_level_func
	func_test $RET_OK "ok: chk_level $LEVELMAX test_chk_level_func"
	chk_level $LEVELMAX test_chk_level_func arg1
	func_test $RET_OK "ok: chk_level $LEVELMAX test_chk_level_func arg1"
	chk_level $LEVELMAX test_chk_level_func arg1 arg2
	func_test $RET_OK "ok: chk_level $LEVELMAX test_chk_level_func arg1 arg2"
	chk_level $LEVELNONUM
	func_test $ERR_BADARG "bad arg: chk_level $LEVELNONUM"
	chk_level $LEVELNONUM test_chk_level_func
	func_test $ERR_BADARG "bad arg: chk_level $LEVELNONUM test_chk_level_func"
	chk_level $LEVELNONUM test_chk_level_func arg1
	func_test $ERR_BADARG "bad arg: $LEVELNONUM test_chk_level_func arg1"
	chk_level $LEVELNONUM test_chk_level_func arg1 arg2
	func_test $ERR_BADARG "bad arg: $LEVELNONUM test_chk_level_func arg1 arg2"
	chk_level $LEVELZERO
	func_test $ERR_BADARG "bad arg: chk_level $LEVELZERO"
	chk_level $LEVELZERO test_chk_level_func
	func_test $ERR_BADARG "bad arg: chk_level $LEVELZERO test_chk_level_func"
	chk_level $LEVELZERO test_chk_level_func arg1
	func_test $ERR_BADARG "bad arg: chk_level $LEVELZERO test_chk_level_func arg1"
	chk_level $LEVELZERO test_chk_level_func arg1 arg2
	func_test $ERR_BADARG "bad arg: chk_level $LEVELZERO test_chk_level_func arg1 arg2"
	chk_level $LEVELBAD
	func_test $ERR_BADARG "bad arg: chk_level $LEVELBAD"
	chk_level $LEVELBAD test_chk_level_func
	func_test $ERR_BADARG "bad arg: chk_level $LEVELBAD test_chk_level_func"
	chk_level $LEVELBAD test_chk_level_func arg1
	func_test $ERR_BADARG "bad arg: chk_level $LEVELBAD test_chk_level_func arg1"
	chk_level $LEVELBAD test_chk_level_func arg1 arg2
	func_test $ERR_BADARG "bad arg: chk_level $LEVELBAD test_chk_level_func arg1 arg2"

	DOLEVEL=$LEVELSTD
	msg "----"
	msg "test_chk_level: DOLEVEL:$DOLEVEL"
	chk_level
	func_test $ERR_NOARG "no arg: chk_level"

	chk_level $LEVELMIN
	func_test $ERR_NOARG "no arg: chk_level $LEVELMIN"
	chk_level $LEVELMIN test_chk_level_func
	func_test $RET_OK "ok: chk_level $LEVELMIN test_chk_level_func"
	chk_level $LEVELMIN test_chk_level_func arg1
	func_test $RET_OK "ok: chk_level $LEVELMIN test_chk_level_func arg1"
	chk_level $LEVELMIN test_chk_level_func arg1 arg2
	func_test $RET_OK "ok: chk_level $LEVELMIN test_chk_level_func arg1 arg2"
	chk_level $LEVELSTD
	func_test $ERR_NOARG "no arg: chk_level $LEVELSTD"
	chk_level $LEVELSTD test_chk_level_func
	func_test $RET_OK "ok: chk_level $LEVELSTD test_chk_level_func"
	chk_level $LEVELSTD test_chk_level_func arg1
	func_test $RET_OK "ok: chk_level $LEVELSTD test_chk_level_func arg1"
	chk_level $LEVELSTD test_chk_level_func arg1 arg2
	func_test $RET_OK "ok: chk_level $LEVELSTD test_chk_level_func arg1 arg2"
	chk_level $LEVELMAX
	func_test $ERR_NOARG "no arg: chk_level $LEVELMAX"
	chk_level $LEVELMAX test_chk_level_func
	func_test $RET_OK "ok: chk_level $LEVELMAX test_chk_level_func"
	chk_level $LEVELMAX test_chk_level_func arg1
	func_test $RET_OK "ok: chk_level $LEVELMAX test_chk_level_func arg1"
	chk_level $LEVELMAX test_chk_level_func arg1 arg2
	func_test $RET_OK "ok: chk_level $LEVELMAX test_chk_level_func arg1 arg2"
	chk_level $LEVELNONUM
	func_test $ERR_BADARG "bad arg: chk_level $LEVELNONUM"
	chk_level $LEVELNONUM test_chk_level_func
	func_test $ERR_BADARG "bad arg: chk_level $LEVELNONUM test_chk_level_func"
	chk_level $LEVELNONUM test_chk_level_func arg1
	func_test $ERR_BADARG "bad arg: $LEVELNONUM test_chk_level_func arg1"
	chk_level $LEVELNONUM test_chk_level_func arg1 arg2
	func_test $ERR_BADARG "bad arg: $LEVELNONUM test_chk_level_func arg1 arg2"
	chk_level $LEVELZERO
	func_test $ERR_BADARG "bad arg: chk_level $LEVELZERO"
	chk_level $LEVELZERO test_chk_level_func
	func_test $ERR_BADARG "bad arg: chk_level $LEVELZERO test_chk_level_func"
	chk_level $LEVELZERO test_chk_level_func arg1
	func_test $ERR_BADARG "bad arg: chk_level $LEVELZERO test_chk_level_func arg1"
	chk_level $LEVELZERO test_chk_level_func arg1 arg2
	func_test $ERR_BADARG "bad arg: chk_level $LEVELZERO test_chk_level_func arg1 arg2"
	chk_level $LEVELBAD
	func_test $ERR_BADARG "bad arg: chk_level $LEVELBAD"
	chk_level $LEVELBAD test_chk_level_func
	func_test $ERR_BADARG "bad arg: chk_level $LEVELBAD test_chk_level_func"
	chk_level $LEVELBAD test_chk_level_func arg1
	func_test $ERR_BADARG "bad arg: chk_level $LEVELBAD test_chk_level_func arg1"
	chk_level $LEVELBAD test_chk_level_func arg1 arg2
	func_test $ERR_BADARG "bad arg: chk_level $LEVELBAD test_chk_level_func arg1 arg2"

	DOLEVEL=$LEVELMAX
	msg "----"
	msg "test_chk_level: DOLEVEL:$DOLEVEL"
	chk_level
	func_test $ERR_NOARG "no arg: chk_level"

	chk_level $LEVELMIN
	func_test $ERR_NOARG "no arg: chk_level $LEVELMIN"
	chk_level $LEVELMIN test_chk_level_func
	func_test $RET_OK "ok: chk_level $LEVELMIN test_chk_level_func"
	chk_level $LEVELMIN test_chk_level_func arg1
	func_test $RET_OK "ok: chk_level $LEVELMIN test_chk_level_func arg1"
	chk_level $LEVELMIN test_chk_level_func arg1 arg2
	func_test $RET_OK "ok: chk_level $LEVELMIN test_chk_level_func arg1 arg2"
	chk_level $LEVELSTD
	func_test $ERR_NOARG "no arg: chk_level $LEVELSTD"
	chk_level $LEVELSTD test_chk_level_func
	func_test $RET_OK "ok: chk_level $LEVELSTD test_chk_level_func"
	chk_level $LEVELSTD test_chk_level_func arg1
	func_test $RET_OK "ok: chk_level $LEVELSTD test_chk_level_func arg1"
	chk_level $LEVELSTD test_chk_level_func arg1 arg2
	func_test $RET_OK "ok: chk_level $LEVELSTD test_chk_level_func arg1 arg2"
	chk_level $LEVELMAX
	func_test $ERR_NOARG "no arg: chk_level $LEVELMAX"
	chk_level $LEVELMAX test_chk_level_func
	func_test $RET_OK "ok: chk_level $LEVELMAX test_chk_level_func"
	chk_level $LEVELMAX test_chk_level_func arg1
	func_test $RET_OK "ok: chk_level $LEVELMAX test_chk_level_func arg1"
	chk_level $LEVELMAX test_chk_level_func arg1 arg2
	func_test $RET_OK "ok: chk_level $LEVELMAX test_chk_level_func arg1 arg2"
	chk_level $LEVELNONUM
	func_test $ERR_BADARG "bad arg: chk_level $LEVELNONUM"
	chk_level $LEVELNONUM test_chk_level_func
	func_test $ERR_BADARG "bad arg: chk_level $LEVELNONUM test_chk_level_func"
	chk_level $LEVELNONUM test_chk_level_func arg1
	func_test $ERR_BADARG "bad arg: $LEVELNONUM test_chk_level_func arg1"
	chk_level $LEVELNONUM test_chk_level_func arg1 arg2
	func_test $ERR_BADARG "bad arg: $LEVELNONUM test_chk_level_func arg1 arg2"
	chk_level $LEVELZERO
	func_test $ERR_BADARG "bad arg: chk_level $LEVELZERO"
	chk_level $LEVELZERO test_chk_level_func
	func_test $ERR_BADARG "bad arg: chk_level $LEVELZERO test_chk_level_func"
	chk_level $LEVELZERO test_chk_level_func arg1
	func_test $ERR_BADARG "bad arg: chk_level $LEVELZERO test_chk_level_func arg1"
	chk_level $LEVELZERO test_chk_level_func arg1 arg2
	func_test $ERR_BADARG "bad arg: chk_level $LEVELZERO test_chk_level_func arg1 arg2"
	chk_level $LEVELBAD
	func_test $ERR_BADARG "bad arg: chk_level $LEVELBAD"
	chk_level $LEVELBAD test_chk_level_func
	func_test $ERR_BADARG "bad arg: chk_level $LEVELBAD test_chk_level_func"
	chk_level $LEVELBAD test_chk_level_func arg1
	func_test $ERR_BADARG "bad arg: chk_level $LEVELBAD test_chk_level_func arg1"
	chk_level $LEVELBAD test_chk_level_func arg1 arg2
	func_test $ERR_BADARG "bad arg: chk_level $LEVELBAD test_chk_level_func arg1 arg2"

	# reset test env
	func_test_show
	DOLEVEL=$DOLEVELBK
}
#msg "test_chk_level"; VERBOSE=2; test_chk_level; exit 0

### date time
DTTMSHSTART=
# func:get_datetime ver:2023.12.31
# get date time and store to VARDTTM
# get_date VARDTTM
get_datetime()
{
	xxmsg "get_datetime: ARGS:$*"

	local RETCODE VARDTTM DTTM VALDTTM

	RETCODE=$RET_OK

	# check VARDTTM
	if [ x"$1" = x ]; then
		emsg "get_datetime: need VARDTTM, skip"
		return $ERR_NOARG
	fi
	VARDTTM="$1"
	xxmsg "get_datetime: VARDTTM:$VARDTTM"

	DTTM=`date '+%Y%m%d-%H%M%S'`
	eval $VARDTTM="$DTTM"
	VALDTTM=`eval echo '$'${VARDTTM}`
	xxmsg "get_datetime: DTTM:$DTTM $VARDTTM:$VALDTTM"

	return $RETCODE
}
test_get_datetime()
{
	local DTTMTEST

	# set test env
	DTTMTEST=
	msg "DTTMTEST:$DTTMTEST"
	date '+%Y%m%d-%H%M%S'
	func_test_reset

	# test code
	get_datetime
	func_test $ERR_NOARG "no arg: get_datetime"
	msg "DTTMTEST:$DTTMTEST"
	get_datetime DTTMTEST
	func_test $RET_OK "ok: get_datetime DTTMTEST"
	msg "DTTMTEST:$DTTMTEST"

	# reset test env
	func_test_show
	DTTMTEST=
}
#msg "test get_datetime"; VERBOSE=2; test_get_datetime; exit 0
get_datetime DTTMSHSTART

# func:diff_datetime ver:2023.12.31
# get date time difference in second
# get_date DTTMSTART DTTMEND
diff_datetime()
{
	xxmsg "diff_datetime: ARGS:$*"

	local RETCODE DTTMS DTTME DIFF

	RETCODE=$RET_OK

	# check
	if [ $# -lt 2 ]; then
		emsg "diff_datetime: need DTTMSTART DTTMEND, skip"
		return $ERR_NOARG
	fi
	DTTMS="$1"
	DTTME="$2"

	DIFF=`echo -e "$DTTMS\n$DTTME" | awk '
	{ T=$0; NDT=patsplit(T, DT, /([0-9][0-9])/); 
	  I=I+1; SDT[I]=sprintf("%02d%02d %2d %2d %2d %2d %2d\n",DT[1],DT[2],DT[3],DT[4],DT[5],DT[6],DT[7]); S[I]=mktime(SDT[I]) }
	END { DIFF=S[2]-S[1]; printf("%d",DIFF)}'`
	echo $DIFF

	return $RETCODE
}
test_diff_datetime()
{
	local DTTMS DTTME DTTME2 DTTMU DIFF DIFFOK

	# set test env
	DTTMS=20231229-064933
	DTTME=20231229-085939
	DTTME2=20231230-085939
	DTTMU=
	DIFF=
	DIFFOK=7806
	msg "DTTMS:$DTTMS DTTME:$DTTME DIFF:$DIFF"
	func_test_reset

	# test code
	DIFF=`diff_datetime`
	func_test $ERR_NOARG "no arg: diff_datetime"
	msg "DTTMS:$DTTMS DTTME:$DTTME DTTMU:$DTTMU DIFF:$DIFF"

	DIFF=`diff_datetime $DTTMS`
	func_test $ERR_NOARG "no arg: diff_datetime $DTTMS"
	msg "DTTMS:$DTTMS DTTME:$DTTME DTTMU:$DTTMU DIFF:$DIFF"

	DIFF=`diff_datetime $DTTMS $DTTME`
	func_test $RET_OK "ok: diff_datetime $DTTMS $DTTME"
	msg "DTTMS:$DTTMS DTTME:$DTTME DTTMU:$DTTMU DIFF:$DIFF"
	DIFF=`diff_datetime $DTTMS $DTTME2`
	func_test $RET_OK "ok: diff_datetime $DTTMS $DTTME2"
	msg "DTTMS:$DTTMS DTTME:$DTTME DTTMU:$DTTMU DIFF:$DIFF"
	DIFF=`diff_datetime $DTTMS $DTTMS`
	func_test $RET_OK "ok: diff_datetime $DTTMS $DTTMS"
	msg "DTTMS:$DTTMS DTTME:$DTTME DTTMU:$DTTMU DIFF:$DIFF"
	DIFF=`diff_datetime $DTTME $DTTMS`
	func_test $RET_OK "ok: diff_datetime $DTTME $DTTMS"
	msg "DTTMS:$DTTMS DTTME:$DTTME DTTMU:$DTTMU DIFF:$DIFF"

	DIFF=`diff_datetime $DTTMS $DTTMU`
	func_test $ERR_NOARG "no arg: diff_datetime $DTTMS $DTTMU"
	msg "DTTMS:$DTTMS DTTME:$DTTME DTTMU:$DTTMU DIFF:$DIFF"
	DIFF=`diff_datetime $DTTMU $DTTME`
	func_test $ERR_NOARG "no arg: diff_datetime $DTTMU $DTTME"
	msg "DTTMS:$DTTMS DTTME:$DTTME DTTMU:$DTTMU DIFF:$DIFF"
	DIFF=`diff_datetime $DTTMS $DTTME`
	func_test $RET_OK "ok: diff_datetime $DTTMS $DTTME"
	msg "DTTMS:$DTTMS DTTME:$DTTME DIFF:$DIFF"

	DIFF=`diff_datetime $DTTMS $DTTME ABC`
	func_test $RET_OK "ok: diff_datetime $DTTMS $DTTME"
	msg "DTTMS:$DTTMS DTTME:$DTTME DIFF:$DIFF"

	# reset test env
	func_test_show
	DTTMS=
	DTTME=
	DTTMU=
	DIFF=
}
#msg "test diff_datetime"; VERBOSE=2; test_diff_datetime; exit 0

# func:get_physpath ver:2024.02.24
# get physical file path if it is symlink
# get_physpath VARPHYSPATH FILE
get_physpath()
{
	local XVARPHYSPATH XFILE RETCODE XPHYSPATH XVALPHYSPATH

	xmsg "get_physpath: ARGS:$*"
	if [ $# -lt 2 ]; then
		emsg "get_physpath: need VARPHYSPATH, FILE, skip"
		return $ERR_NOARG
	fi

	XVARPHYSPATH="$1"
	shift
	XFILE="$*"

	RETCODE=$RET_OK

	xxmsg "get_physpath: test XFILE:$XFILE"
	if [ ! -e "$XFILE" ]; then
		emsg "get_physpath: not existed: $XFILE"
		return $ERR_NOTEXISTED
	fi

	# $ ls -l llama.cpp/models/llama-2-7b.Q8_0*
	#-rwxrwxrwx 1 user user 7161089728 Sep  5 00:54 llama.cpp/models/llama-2-7b.Q8_0-local.gguf
	#lrwxrwxrwx 1 user user         60 Feb 12 06:13 llama.cpp/models/llama-2-7b.Q8_0.gguf -> /mnt/hd-le-b/gpt/llama2/gguf/llama-2-7b/llama-2-7b.Q8_0.gguf
	# ls -alng fix240218-ah.sh
	#-rw-r--r-- 1 109 12303 Feb 18 02:44 fix240218-ah.sh
	# ls -alng llama.cpp/models/llama-2-7b.Q8_0.gguf
	#lrwxrwxrwx 1 1000 60 Feb 12 06:13 llama.cpp/models/llama-2-7b.Q8_0.gguf -> /mnt/hd-le-b/gpt/llama2/gguf/llama-2-7b/llama-2-7b.Q8_0.gguf
	# ls -alng llama.cpp/models/llama-2-7b.Q8_0-local.gguf
	#-rwxrwxrwx 1 1000 7161089728 Sep  5 00:54 llama.cpp/models/llama-2-7b.Q8_0-local.gguf

	if [ $VERBOSE -ge 2 ]; then
		xxmsg "ls -alngd \"$XFILE\""
		ls -alngd "$XFILE"
	fi
	XPHYSPATH=`ls -alngd "$XFILE" | awk '/^l/ { T=$0; sub(/^.* -> /,"",T); printf "%s",T; exit } { T=$0; NDEL=10+length($2)+length($3)+length($4)+12+6; FP=substr(T,NDEL); printf "%s",FP; exit }'`
	xmsg "get_physpath: PHYSPATH:$XPHYSPATH"
	eval $XVARPHYSPATH=\""$XPHYSPATH"\"
	XVALPHYSPATH=`eval echo '$'${XVARPHYSPATH}`
	xmsg "get_physpath: PHYSPATH:$XPHYSPATH $XVARPHYSPATH:$XVALPHYSPATH"

	return $RETCODE
}
test_get_physpath()
{
	local FILE0 FILE1 FILE2 FILE3 FILE4 FILE5 FILE10 FILE11 FILE12 FILE13 FILE14 FILE15 PHYSPATH

	# set test env
	# FILE0, FILE10 do not existed, FILE5, FILE15 are dir
	FILE0=tmp-physpath0.$$
	FILE1=tmp-physpath1.$$
	FILE2=tmp-physpath2.$$
	FILE3="tmp-physpath3 with space.$$"
	FILE4=tmp-physpath4.$$
	FILE5=tmp-physpath5.$$
	FILE10=tmp-physpath10.$$
	FILE11=tmp-physpath11.$$
	FILE12=tmp-physpath12.$$
	FILE13=tmp-physpath13.$$
	FILE14="tmp-physpath14 with space.$$"
	FILE15=tmp-physpath15.$$
	msg "rm -rf $FILE0 $FILE1 $FILE2 \"$FILE3\" $FILE4 $FILE5 $FILE10 $FILE11 $FILE12 $FILE13 \"$FILE14\" $FILE15"
	rm -rf $FILE0 $FILE1 $FILE2 "$FILE3" $FILE4 $FILE5 $FILE10 $FILE11 $FILE12 $FILE13 "$FILE14" $FILE15
	touch $FILE1
	echo "1234567890" >> $FILE2
	echo "12345678901234567890" >> "$FILE3"
	echo "123456789012345678901234567890" >> $FILE4
	mkdir $FILE5
	ln -s $FILE1 $FILE11
	ln -s $FILE2 $FILE12
	ln -s "$FILE3" $FILE13
	ln -s $FILE4 "$FILE14"
	ln -s $FILE0 "$FILE10"
	ln -s $FILE5 $FILE15
	msg "ls -ld $FILE0 $FILE1 $FILE2 \"$FILE3\" $FILE4 $FILE5 $FILE10 $FILE11 $FILE12 $FILE13 \"$FILE14\" $FILE15"
	ls -ld $FILE0 $FILE1 $FILE2 "$FILE3" $FILE4 $FILE5 $FILE10 $FILE11 $FILE12 $FILE13 "$FILE14" $FILE15
	msg "PHYSPATH:$PHYSPATH"
	func_test_reset

	# test code
	PHYSPATH=
	get_physpath
	func_test $ERR_NOARG "no arg: PHYSPATH:$PHYSPATH get_physpath"
	get_physpath PHYSPATH
	func_test $ERR_NOARG "no arg: PHYSPATH:$PHYSPATH get_physpath PHYSPATH"

	PHYSPATH=
	get_physpath PHYSPATH $FILE0
	func_test $ERR_NOTEXISTED "not existed: PHYSPATH:$PHYSPATH get_physpath PHYSPATH $FILE0"
	PHYSPATH=
	get_physpath PHYSPATH $FILE1
	func_test $RET_OK "ok: PHYSPATH:$PHYSPATH get_physpath PHYSPATH $FILE1"
	PHYSPATH=
	get_physpath PHYSPATH $FILE2
	func_test $RET_OK "ok: PHYSPATH:$PHYSPATH get_physpath PHYSPATH $FILE2"
	PHYSPATH=
	get_physpath PHYSPATH $FILE3
	func_test $RET_OK "ok: PHYSPATH:$PHYSPATH get_physpath PHYSPATH $FILE3"
	PHYSPATH=
	get_physpath PHYSPATH "$FILE3"
	func_test $RET_OK "ok: PHYSPATH:$PHYSPATH get_physpath PHYSPATH \"$FILE3\""
	PHYSPATH=
	get_physpath PHYSPATH $FILE4
	func_test $RET_OK "ok: PHYSPATH:$PHYSPATH get_physpath PHYSPATH $FILE4"
	PHYSPATH=
	get_physpath PHYSPATH $FILE5
	func_test $RET_OK "ok: PHYSPATH:$PHYSPATH get_physpath PHYSPATH $FILE5"

	PHYSPATH=
	get_physpath PHYSPATH $FILE10
	func_test $ERR_NOTEXISTED "not existed: PHYSPATH:$PHYSPATH get_physpath PHYSPATH $FILE10"
	PHYSPATH=
	get_physpath PHYSPATH $FILE11
	func_test $RET_OK "ok: PHYSPATH:$PHYSPATH get_physpath PHYSPATH $FILE11"
	PHYSPATH=
	get_physpath PHYSPATH $FILE12
	func_test $RET_OK "ok: PHYSPATH:$PHYSPATH get_physpath PHYSPATH $FILE12"
	PHYSPATH=
	get_physpath PHYSPATH $FILE13
	func_test $RET_OK "ok: PHYSPATH:$PHYSPATH get_physpath PHYSPATH $FILE13"
	PHYSPATH=
	get_physpath PHYSPATH "$FILE13"
	func_test $RET_OK "ok: PHYSPATH:$PHYSPATH get_physpath PHYSPATH \"$FILE13\""
	PHYSPATH=
	get_physpath PHYSPATH $FILE14
	func_test $RET_OK "ok: PHYSPATH:$PHYSPATH get_physpath PHYSPATH $FILE14"
	PHYSPATH=
	get_physpath PHYSPATH "$FILE14"
	func_test $RET_OK "ok: PHYSPATH:$PHYSPATH get_physpath PHYSPATH \"$FILE14\""
	PHYSPATH=
	get_physpath PHYSPATH "$FILE15"
	func_test $RET_OK "ok: PHYSPATH:$PHYSPATH get_physpath PHYSPATH \"$FILE15\""

	# reset test env
	func_test_show
	msg "rm -rf $FILE0 $FILE1 $FILE2 \"$FILE3\" $FILE4 $FILE5 $FILE10 $FILE11 $FILE12 $FILE13 \"$FILE14\" $FILE15"
	rm -rf $FILE0 $FILE1 $FILE2 "$FILE3" $FILE4 $FILE5 $FILE10 $FILE11 $FILE12 $FILE13 "$FILE14" $FILE15
	msg "ls -ld $FILE0 $FILE1 $FILE2 \"$FILE3\" $FILE4 $FILE5 $FILE10 $FILE11 $FILE12 $FILE13 \"$FILE14\" $FILE15"
	ls -ld $FILE0 $FILE1 $FILE2 "$FILE3" $FILE4 $FILE5 $FILE10 $FILE11 $FILE12 $FILE13 "$FILE14" $FILE15
	msg "PHYSPATH:$PHYSPATH"
}
#msg "test get_physpath"; VERBOSE=2; test_get_physpath; exit 0
#msg "test get_physpath"; VERBOSE=0; test_get_physpath; exit 0

# func:chk_and_cp ver:2023.12.30
# do cp with cp option and check source file(s) and dir(s) to file or dir
# chk_and_cp CPOPT SRCFILE SRCDIR ... DSTPATH
chk_and_cp()
{
	local chkfiles cpopt narg argfiles dstpath ncp cpfiles i

	#xmsg "----"
	#xmsg "chk_and_cp: VERBOSE:$VERBOSE NOEXEC:$NOEXEC NOCOPY:$NOCOPY"
	#xmsg "chk_and_cp: $*"
	#xmsg "chk_and_cp: nargs:$# args:$*"
	if [ $# -eq 0 ]; then
		emsg "chk_and_cp: ARG:$*: no cpopt, chkfiles"
		return $ERR_NOARG
	fi

	# get cp opt
	cpopt=$1
	shift
	#xmsg "chk_and_cp: narg:$# args:$*"

	if [ $# -le 1 ]; then
		emsg "chk_and_cp: CPOPT:$cpopt ARG:$*: bad arg, not enough"
		return $ERR_BADARG
	fi

	narg=$#
	dstpath=`eval echo '${'$#'}'`
	#xmsg "chk_and_cp: narg:$# dstpath:$dstpath"
	if [ ! -d $dstpath ]; then
		dstpath=
	fi
	argfiles="$*"
	#xmsg "chk_and_cp: cpopt:$cpopt narg:$narg argfiles:$argfiles dstpath:$dstpath"

	ncp=1
	cpfiles=
	for i in $argfiles
	do
		#xmsg "chk_and_cp: ncp:$ncp/$narg i:$i"
		if [ $ncp -eq $narg ]; then
			dstpath="$i"
			break
		fi

		if [ -f $i ]; then
			cpfiles="$cpfiles $i"
		elif [ -d $i -a ! "x$i" = x"$dstpath" ]; then
			cpfiles="$cpfiles $i"
		else
			msg "${ESCWARN}chk_and_cp: $i: can't add to cpfiles, ignore${ESCBACK}"
			msg "ls -l $i"
			ls -l $i
		fi

		ncp=`expr $ncp + 1`
	done

	xmsg "chk_and_cp: cpopt:$cpopt ncp:$ncp cpfiles:$cpfiles dstpath:$dstpath"
	if [ x"$cpfiles" = x ]; then
		emsg "chk_and_cp: bad arg, no cpfiles"
		return $ERR_BADARG
	fi

	if [ x"$dstpath" = x ]; then
		emsg "chk_and_cp: bad arg, no dstpath$"
		return $ERR_BADARG
	fi

	if [ $ncp -eq 1 ]; then
		emsg "chk_and_cp: bad arg, only 1 parameter:$cpfiles $dstpath"
		if [ $NOEXEC -eq $RET_FALSE ]; then
			return $ERR_BADARG
		else
			msg "${ESC_WARN}NOEXEC, return $RET_OK${ESC_BACK}"
			return $RET_OK
		fi
	elif [ $ncp -eq 2 ]; then
		if [ -f $cpfiles -a ! -e $dstpath ]; then
			nothing
		elif [ -f $cpfiles -a -f $dstpath -a $cpfiles = $dstpath ]; then
			emsg "chk_and_cp: bad arg, same file"
			return $ERR_BADARG
		elif [ -d $cpfiles -a -f $dstpath ]; then
			emsg "chk_and_cp: bad arg, dir to file"
			return $ERR_BADARG
		elif [ -f $cpfiles -a -f $dstpath ]; then
			nothing
		elif [ -f $cpfiles -a -d $dstpath ]; then
			nothing
		fi
	elif [ ! -e $dstpath ]; then
		emsg "chk_and_cp: dstpath:$dstpath: not existed"
		if [ $NOEXEC -eq $RET_FALSE ]; then
			return $ERR_NOTEXISTED
		else
			msg "${ESC_WARN}NOEXEC, return $RET_OK${ESC_BACK}"
			return $RET_OK
		fi
	elif [ ! -d $dstpath ]; then
		emsg "chk_and_cp: not dir"
		return $ERR_NOTDIR
	fi

	if [ $NOEXEC -eq $RET_FALSE -a $NOCOPY -eq $RET_FALSE ]; then
		msg "cp $cpopt $cpfiles $dstpath"
		cp $cpopt $cpfiles $dstpath || return $?
	else
		msg "${ESCWARN}noexec: cp $cpopt $cpfiles $dstpath${ESCBACK}"
	fi

	return $RET_OK
}

# chk_and_cp test code
test_chk_and_cp()
{
	# test files and dir, test-no.$$, testdir-no.$$: not existed
	touch test.$$ test-1.$$ test-2.$$ test-3.$$ test-4.$$ test-5.$$ test-6.$$ test-7.$$ test-8.$$ test-9.$$ test-10.$$
	rm test-no.$$
	mkdir testdir.$$
	rmdir testdir-no.$$
	ls -ld test.$$ test-1.$$ test-2.$$ test-3.$$ test-4.$$ test-5.$$ test-6.$$ test-7.$$ test-8.$$ test-9.$$ test-10.$$ test-no.$$ testdir.$$ testdir-no.$$
	msg "test_chk_and_cp: create test.$$ test-1.$$ test-2.$$ test-3.$$ test-4.$$ test-5.$$ test-6.$$ test-7.$$ test-8.$$ test-9.$$ test-10.$$ test-no.$$ testdir.$$ testdir-no.$$"
	func_test_reset

	# test code
	msg "ls testdir.$$"; ls -l testdir.$$; rm -rf testdir.$$; mkdir testdir.$$
	chk_and_cp -p test.$$ test-1.$$ test-2.$$ test-3.$$ test-4.$$ test-5.$$ test-6.$$ test-7.$$ test-8.$$ test-9.$$ testdir.$$
	func_test $RET_OK "ok: chk_and_cp -p test.$$ test-1.$$ test-2.$$ test-3.$$ test-4.$$ test-5.$$ test-6.$$ test-7.$$ test-8.$$ test-9.$$ testdir.$$"
	msg "ls testdir.$$"; ls -l testdir.$$; rm -rf testdir.$$; mkdir testdir.$$

	chk_and_cp
	func_test $ERR_NOARG "no cpopt: chk_and_cp"

	chk_and_cp -p
	func_test $ERR_BADARG "bad arg: chk_and_cp -p"

	chk_and_cp -p test-no.$$
	func_test $ERR_BADARG "bad arg: chk_and_cp -p test-no.$$"
	chk_and_cp -p test.$$
	func_test $ERR_BADARG "bad arg: chk_and_cp -p test.$$"
	chk_and_cp -p testdir-no.$$
	func_test $ERR_BADARG "bad arg: chk_and_cp -p testdir-no.$$"
	chk_and_cp -p testdir.$$
	func_test $ERR_BADARG "bad arg: chk_and_cp -p testdir.$$"

	chk_and_cp -p test-no.$$ test-no.$$
	func_test $ERR_BADARG "bad arg: chk_and_cp -p test-no.$$ test-no.$$"
	chk_and_cp -p test-no.$$ test.$$
	func_test $ERR_BADARG "bad arg: chk_and_cp -p test-no.$$ test.$$"
	chk_and_cp -p test-no.$$ testdir-no.$$
	func_test $ERR_BADARG "bad arg: chk_and_cp -p test-no.$$ testdir-no.$$"
	chk_and_cp -p test-no.$$ testdir.$$
	func_test $ERR_BADARG "bad arg: chk_and_cp -p test-no.$$ testdir.$$"

	chk_and_cp -p test.$$ test-no.$$
	func_test $RET_OK "ok: chk_and_cp -p test.$$ test-no.$$"
	msg "ls test-no.$$"; ls -l test-no.$$; rm -rf test-no.$$
	chk_and_cp -p test.$$ test-1.$$
	func_test $RET_OK "ok: chk_and_cp -p test.$$ test-1.$$"
	msg "ls test-1.$$"; ls -l test-1.$$
	chk_and_cp -p test.$$ test.$$
	func_test $ERR_BADARG "bad arg: chk_and_cp -p test.$$ test.$$"
	chk_and_cp -p test.$$ testdir-no.$$
	func_test $RET_OK "ok: chk_and_cp -p test.$$ testdir-no.$$"
	msg "ls testdir-no.$$"; ls -l testdir-no.$$; rm -rf testdir-no.$$
	chk_and_cp -p test.$$ testdir.$$
	func_test $RET_OK "ok: chk_and_cp -p test.$$ testdir.$$"
	msg "ls testdir.$$"; ls -l testdir.$$; rm -rf testdir.$$; mkdir testdir.$$

	chk_and_cp -p test.$$ test-no.$$ testdir.$$
	func_test $RET_OK "ok: chk_and_cp -p test.$$ test-no.$$ testdir.$$"
	msg "ls testdir.$$"; ls -l testdir.$$; rm -rf testdir.$$; mkdir testdir.$$
	chk_and_cp -p test.$$ test.$$ testdir.$$
	func_test $RET_OK "ok: chk_and_cp -p test.$$ test.$$ testdir.$$"
	msg "ls testdir.$$"; ls -l testdir.$$; rm -rf testdir.$$; mkdir testdir.$$
	chk_and_cp -p test.$$ test-1.$$ testdir.$$
	func_test $RET_OK "ok: chk_and_cp -p test.$$ test-1.$$ testdir.$$"
	msg "ls testdir.$$"; ls -l testdir.$$; rm -rf testdir.$$; mkdir testdir.$$
	chk_and_cp -p test.$$ testdir-no.$$ testdir.$$
	func_test $RET_OK "ok: chk_and_cp -p test.$$ testdir-no.$$ testdir.$$"
	msg "ls testdir.$$"; ls -l testdir.$$; rm -rf testdir.$$; mkdir testdir.$$
	chk_and_cp -p test.$$ testdir.$$ testdir.$$
	func_test $RET_OK "ok: chk_and_cp -p test.$$ testdir.$$ testdir.$$"
	msg "ls testdir.$$"; ls -l testdir.$$; rm -rf testdir.$$; mkdir testdir.$$

	chk_and_cp -p test.$$ test-1.$$ test-2.$$ testdir.$$
	func_test $RET_OK "ok: chk_and_cp -p test.$$ test-1.$$ test-2.$$ testdir.$$"
	msg "ls testdir.$$"; ls -l testdir.$$; rm -rf testdir.$$; mkdir testdir.$$
	chk_and_cp -p test.$$ test-1.$$ test-2.$$ test-3.$$ testdir.$$
	func_test $RET_OK "ok: chk_and_cp -p test.$$ test-1.$$ test-2.$$ test-3.$$ testdir.$$"
	msg "ls testdir.$$"; ls -l testdir.$$; rm -rf testdir.$$; mkdir testdir.$$
	chk_and_cp -p test.$$ test-1.$$ test-2.$$ test-3.$$ test-4.$$ testdir.$$
	func_test $RET_OK "ok: chk_and_cp -p test.$$ test-1.$$ test-2.$$ test-3.$$ test-4.$$ testdir.$$"
	msg "ls testdir.$$"; ls -l testdir.$$; rm -rf testdir.$$; mkdir testdir.$$

	chk_and_cp -p test.$$ test-1.$$ test-2.$$ test-3.$$ test-4.$$ test-5.$$ test-6.$$ test-7.$$ test-8.$$ testdir.$$
	func_test $RET_OK "ok: chk_and_cp -p test.$$ test-1.$$ test-2.$$ test-3.$$ test-4.$$ test-5.$$ test-6.$$ test-7.$$ test-8.$$ testdir.$$"
	msg "ls testdir.$$"; ls -l testdir.$$; rm -rf testdir.$$; mkdir testdir.$$
	chk_and_cp -p test.$$ test-1.$$ test-2.$$ test-3.$$ test-4.$$ test-5.$$ test-6.$$ test-7.$$ test-8.$$ test-9.$$ testdir.$$
	func_test $RET_OK "ok: chk_and_cp -p test.$$ test-1.$$ test-2.$$ test-3.$$ test-4.$$ test-5.$$ test-6.$$ test-7.$$ test-8.$$ test-9.$$ testdir.$$"
	msg "ls testdir.$$"; ls -l testdir.$$; rm -rf testdir.$$; mkdir testdir.$$
	chk_and_cp -p test.$$ test-1.$$ test-2.$$ test-3.$$ test-4.$$ test-5.$$ test-6.$$ test-7.$$ test-8.$$ test-9.$$ test-10.$$ testdir.$$
	func_test $RET_OK "ok: chk_and_cp -p test.$$ test-1.$$ test-2.$$ test-3.$$ test-4.$$ test-5.$$ test-6.$$ test-7.$$ test-8.$$ test-9.$$ test-10.$$ testdir.$$"
	msg "ls testdir.$$"; ls -l testdir.$$; rm -rf testdir.$$; mkdir testdir.$$

	# reset test env
	func_test_show
	rm test.$$ test-1.$$ test-2.$$ test-3.$$ test-4.$$ test-5.$$ test-6.$$ test-7.$$ test-8.$$ test-9.$$ test-10.$$ test-no.$$
	rm -rf testdir.$$ testdir-no.$$
	ls -ld test.$$ test-1.$$ test-2.$$ test-3.$$ test-4.$$ test-5.$$ test-6.$$ test-7.$$ test-8.$$ test-9.$$ test-10.$$ test-no.$$ testdir.$$ testdir-no.$$
	msg "test_chk_and_cp: rm test.$$ test-1.$$ test-2.$$ test-3.$$ test-4.$$ test-5.$$ test-6.$$ test-7.$$ test-8.$$ test-9.$$ test-10.$$ test-no.$$ testdir.$$ testdir-no.$$"
}
#msg "test_chk_and_cp"; VERBOSE=2; test_chk_and_cp; exit 0

# func:get_latestdatefile ver: 2023.12.30
# yyyymmddHHMMSS filename
# get latest date and filename given FILENAME
# get_datefile FILENAME
get_latestdatefile()
{
	local FILE FILES i

	if [ ! $# -ge 1 ]; then
		emsg "get_latestdatefile: RETCODE:$ERR_NOARG: ARG:$*: need FILENAME, error return"
		return $ERR_NOARG
	fi

	FILE="$1"

	xmsg "get_latestdatefile: FILE:$FILE ARG:$*"

	FILES=`eval echo $FILE`
	xmsg "get_latestdatefile: FILES:$FILES"
	for i in $FILES
	do
		if [ ! -e $i ]; then
			emsg "get_latestdatefile: RETCODE:$ERR_NOTEXISTED: $FILE: not found, error return"
			return $ERR_NOTEXISTED
		fi
	done

	ls -ltr --time-style=+%Y%m%d%H%M%S $FILES | awk '
	BEGIN { XDT="0"; XNM="" }
	#{ DT=$6; T=$0; sub(/[\n\r]$/,"",T); I=index(T,DT); I=I+length(DT)+1; NM=substr(T,I); if (DT > XDT) { XDT=DT; XNM=NM }; printf("%s %s D:%s %s\n",XDT,XNM,DT,NM) >> /dev/stderr }
	{ DT=$6; T=$0; sub(/[\n\r]$/,"",T); I=index(T,DT); I=I+length(DT)+1; NM=substr(T,I); if (DT > XDT) { XDT=DT; XNM=NM }; }
	END { printf("%s %s\n",XDT,XNM) }
	'

	return $?
}
test_get_latestdatefile()
{
	local DT OKFILE NGFILE TMPDIR1 OKFILE2 NGFILE2 DF RETCODE

	# set test env
	DT=20231203145627
	OKFILE=test.$$
	OKFILE1=test.$$.1
	NGFILE=test-no.$$
	touch $OKFILE $OKFILE1
	rm $NGFILE
	TMPDIR1=tmpdir.$$
	mkdir $TMPDIR1
	OKFILE2=$TMPDIR1/test2.$$
	NGFILE2=$TMPDIR1/test-no2.$$
	touch $OKFILE2
	rm $NGFILE2
	msg "ls $OKFILE $OKFILE1 $NGFILE $OKFILE2 $NGFILE2 $TMPDIR1"
	ls $OKFILE $OKFILE1 $NGFILE $OKFILE2 $NGFILE2 $TMPDIR1
	func_test_reset

	# test code
	DF=`get_latestdatefile`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $ERR_NOARG "no arg: get_latestdatefile"

	DF=`get_latestdatefile $NGFILE`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $ERR_NOTEXISTED "not existed: get_latestdatefile $NGFILE"
	DF=`get_latestdatefile $OKFILE`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $RET_OK "ok: get_latestdatefile $OKFILE"
	DF=`get_latestdatefile $OKFILE1`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $RET_OK "ok: get_latestdatefile $OKFILE1"
	DF=`get_latestdatefile $OKFILE*`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $RET_OK "ok: get_latestdatefile $OKFILE*"
	DF=`get_latestdatefile "$OKFILE*"`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $RET_OK "ok: get_latestdatefile \"$OKFILE*\""
	DF=`get_latestdatefile $NGFILE2`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $ERR_NOTEXISTED "not existed: get_latestdatefile $NGFILE2"
	DF=`get_latestdatefile $OKFILE2`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $RET_OK "ok: get_latestdatefile $OKFILE2"

	# reset test env
	func_test_show
	rm $OKFILE $OKFILE1 $NGFILE $OKFILE2 $NGFILE2
	rmdir $TMPDIR1
	msg "ls $OKFILE $OKFILE1 $NGFILE $OKFILE2 $NGFILE2 $TMPDIR1"
	ls $OKFILE $OKFILE1 $NGFILE $OKFILE2 $NGFILE2 $TMPDIR1
}
#msg "test_get_latestdatefile"; VERBOSE=2; test_get_latestdatefile; exit 0

# func:get_datefile_date ver: 2023.12.30
# Ymd|ymd|md|full yyyymmddHHMMSS filename
# get date given YMDoption(Ymd,ymd,md,full) DATE FILENAME
# get_datefile_date OPT DATE FILENAME
get_datefile_date()
{
	local DTFILE

	if [ ! $# -ge 3 ]; then
		emsg "get_datefile_date: RETCODE:$ERR_NOARG: ARG:$*: need OPT DATE FILENAME, error return"
		return $ERR_NOARG
	fi

	OPT="$1"
	shift
	DTFILE="$*" # date filename

	xmsg "get_datefile_date: OPT:$OPT DTFILE:$DTFILE"

	echo $DTFILE | awk -v OPT=$OPT '{ T=$0; sub(/[\n\r]$/,"",T); D=substr(T,1,14); if (OPT=="Ymd") { print substr(D,1,8) } else if (OPT=="ymd") { print substr(D,3,6) } else if (OPT=="md") { print substr(D,5,4) } else if (OPT=="full") { print D } else { print D } }'
	return $?
}
test_get_datefile_date()
{
	local DT OKFILE NGFILE DF RETCODE

	# set test env
	DT=20231203145627
	OKFILE=test.$$
	NGFILE=test-no.$$
	touch $OKFILE
	rm $NGFILE
	ls $OKFILE $NGFILE
	func_test_reset

	# test code
	DF=`get_datefile_date`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $ERR_NOARG "no arg: get_datefile_date"
	DF=`get_datefile_date md`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $ERR_NOARG "no arg: get_datefile_date md"
	DF=`get_datefile_date $DT`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $ERR_NOARG "no arg: get_datefile_date $DT"
	DF=`get_datefile_date $OKFILE`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $ERR_NOARG "no arg: get_datefile_date $OKFILE"
	DF=`get_datefile_date $DT $OKFILE`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $ERR_NOARG "no arg: get_datefile_date $DT $OKFILE"

	DF=`get_datefile_date Ymd $DT $OKFILE`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $RET_OK "ok: get_datefile_date Ymd $DT $OKFILE"
	DF=`get_datefile_date ymd $DT $OKFILE`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $RET_OK "ok: get_datefile_date ymd $DT $OKFILE"
	DF=`get_datefile_date md $DT $OKFILE`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $RET_OK "ok: get_datefile_date md $DT $OKFILE"
	DF=`get_datefile_date full $DT $OKFILE`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $RET_OK "ok: get_datefile_date full $DT $OKFILE"
	DF=`get_datefile_date ngopt $DT $OKFILE`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $RET_OK "ok: get_datefile_date ngopt $DT $OKFILE"
	DF=`get_datefile_date md $DT $NGFILE`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $RET_OK "ok: get_datefile_date md $DT $NGFILE"

	DF=`get_datefile_date Ymd $DT $OKFILE extra`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $RET_OK "ok: get_datefile_date Ymd $DT $OKFILE extra"
	DF=`get_datefile_date md $DT $OKFILE extra`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $RET_OK "ok: get_datefile_date md $DT $OKFILE extra"
	DF=`get_datefile_date md $DT $NGFILE extra`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $RET_OK "ok: get_datefile_date md $DT $NGFILE extra"

	# reset test env
	func_test_show
	rm $OKFILE $NGFILE
}
#msg "test_get_datefile_date"; VERBOSE=2; test_get_datefile_date; exit 0

# func:get_datefile_file ver: 2023.12.30
# yyyymmddHHMMSS filename
# get filename given DATE FILENAME
# get_datefile_file DATE FILENAME
get_datefile_file()
{
	local DTFILE

	if [ ! $# -ge 2 ]; then
		emsg "get_datefile_file: RETCODE:$ERR_NOARG: ARG:$*: need DATE FILENAME, error return"
		return $ERR_NOARG
	fi

	DTFILE="$*" # date filename

	xmsg "get_datefile_file: DTFILE:$DTFILE"

	echo $DTFILE | awk '{ T=$0; sub(/[\n\r]$/,"",T); F=substr(T,16); print F }'
}
test_get_datefile_file()
{
	local DT OKFILE NGFILE TMPDIR1 OKFILE2 NGFILE2 DF RETCODE

	# set test env
	DT=20231203145627
	OKFILE=test.$$
	NGFILE=test-no.$$
	touch $OKFILE
	rm $NGFILE
	TMPDIR1=tmpdir.$$
	mkdir $TMPDIR1
	OKFILE2=$TMPDIR1/test2.$$
	NGFILE2=$TMPDIR1/test-no2.$$
	touch $OKFILE2
	rm $NGFILE2
	msg "ls $OKFILE $NGFILE $OKFILE2 $NGFILE2 $TMPDIR1"
	ls $OKFILE $NGFILE $OKFILE2 $NGFILE2 $TMPDIR1
	func_test_reset

	# test code
	DF=`get_datefile_file`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $ERR_NOARG "no arg: get_datefile_file"

	DF=`get_datefile_file md`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $ERR_NOARG "no arg: get_datefile_file md"
	DF=`get_datefile_file $DT`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $ERR_NOARG "no arg: get_datefile_file $DT"
	DF=`get_datefile_file $OKFILE`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $ERR_NOARG "no arg: get_datefile_file $OKFILE"

	DF=`get_datefile_file $DT $OKFILE`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $RET_OK "ok: get_datefile_file $DT $OKFILE"
	DF=`get_datefile_file $DT $NGFILE`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $RET_OK "ok: get_datefile_file $DT $NGFILE"
	DF=`get_datefile_file $DT $OKFILE2`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $RET_OK "ok: get_datefile_file $DT $OKFILE2"
	DF=`get_datefile_file $DT $NGFILE2`
	RETCODE=$?; msg "DF:$DF"; set_ret $RETCODE
	func_test $RET_OK "ok: get_datefile_file $DT $NGFILE2"

	# reset test env
	func_test_show
	rm $OKFILE $NGFILE $OKFILE2 $NGFILE2
	rmdir $TMPDIR1
	msg "ls $OKFILE $NGFILE $OKFILE2 $NGFILE2 $TMPDIR1"
	ls $OKFILE $NGFILE $OKFILE2 $NGFILE2 $TMPDIR1
}
#msg "test_get_datefile_file"; VERBOSE=2; test_get_datefile_file; exit 0

# func:find_latest ver: 2023.12.31
# find latest created/modified files from DTTMSTART, use DTTMSHSTART if no VARDTTMSTART
# find_latest [VARDTTMSTART]
find_latest()
{
	local VARDTTMSTART DTTMNOW DTTMSTART DTTMSEC DTTMMIN

	if [ ! x"$1" = x ]; then
		VARDTTMSTART=$1
	else
		VARDTTMSTART=DTTMSHSTART
	fi

	get_datetime DTTMNOW
	xmsg "find_latest: DTTMNOW:$DTTMNOW"

	xmsg "find_latest: VARDTTMSTART:$VARDTTMSTART"
	DTTMSTART=`eval echo '$'${VARDTTMSTART}`
	xmsg "find_latest: DTTMSTART:$DTTMSTART"

	DTTMSEC=`diff_datetime $DTTMSTART $DTTMNOW`
	DTTMMIN=`expr $DTTMSEC + 59`
	DTTMMIN=`expr $DTTMMIN / 60`
	xmsg "find_latest: DTTMSEC:$DTTMSEC DTTMMIN:$DTTMMIN"

	xmsg "find . -maxdepth 1 -type f -cmin -$DTTMMIN -mmin -$DTTMMIN -exec ls -l '{}' \;"
	find . -maxdepth 1 -type f -cmin -$DTTMMIN -mmin -$DTTMMIN -exec ls -l '{}' \;
}
test_find_latest()
{
	local DTTMSTART1 DTTMSTART2

	# set env
	sleep 1
	get_datetime DTTMSTART1
	touch tmp1.$$ tmp2.$$
	msg "wait 60 sec ..."
	sleep 60
	touch tmp3.$$ tmp4.$$
	get_datetime DTTMSTART2
	msg "DTTMSHSTART:$DTTMSHSTART DTTMSTART1:$DTTMSTART1 DTTMSTART2:$DTTMSTART2"
	ls -l tmp1.$$ tmp2.$$ tmp3.$$ tmp4.$$
	func_test_reset

	# test code
	find_latest
	func_test $RET_OK "ok: find_latest tmp1-4"
	find_latest DTTMSHSTART
	func_test $RET_OK "ok: find_latest DTTMSHSTART:$DTTMSHSTART tmp1-4"
	find_latest DTTMSTART1
	func_test $RET_OK "ok: find_latest DTTMSHSTART:$DTTMSTART1 tmp1-4"
	find_latest DTTMSTART2
	func_test $RET_OK "ok: find_latest DTTMSHSTART:$DTTMSTART2 tmp3-4"

	# reset env
	func_test_show
	DTTMSTART1=
	DTTMSTART2=
	rm tmp1.$$ tmp2.$$ tmp3.$$ tmp4.$$
}
#msg "test_find_latest"; VERBOSE=2; test_find_latest; exit 0


# func:get_gitbranch ver: 2024.01.15
# get current git branch to VARBRANCH
# get_gitbranch VARBRANCH
get_gitbranch()
{
	local RETCODE VARBRANCH XPWD XBRANCH VALBRANCH

	xmsg "get_gitbranch: $*"

	if [ x"$GITDIR" = x ]; then
		emsg "get_gitbranch: no GITDIR, skip"
		return $ERR_BADSETTINGS
	fi
	if [ x"$1" = x ]; then
		emsg "get_gitbranch: need VARBRANCH, skip"
		return $ERR_NOARG
	fi

	RETCODE=$RET_OK

	VARBRANCH="$1"
	xxmsg "get_gitbranch: VARBRANCH:$VARBRANCH"

	#0 cd ~/github/stable-diffusion.cpp/
	#1 cd ~/github/stable-diffusion.cpp/stable-diffusion.cpp
	#1 cd ~/github/stable-diffusion.cpp/stable-diffusion.cpp/build
	#XPWD=`pwd`
	#xmsg "get_gitbranch: PWD:$XPWD"
	XPWD=`pwd | awk -v DIR="$GITDIR" '{ T=$0; I=index(T, DIR); print I }'`
	#xmsg "get_gitbranch: XPWD:$XPWD"
	if [ $XPWD -eq 0 ]; then
		XPWD=`pwd`
		xmsg "get_gitbranch: cd $GITDIR"
		cd $GITDIR
	else
		XPWD=""
		xmsg "get_gitbranch: under $GITDIR"
	fi

	XBRANCH=`git branch | awk '/^\*/ { T=$0; B=substr(T, 3); print B; exit }'`
	xmsg "get_gitbranch: XBRANCH:$XBRANCH"

	eval $VARBRANCH="$XBRANCH"
	VALBRANCH=`eval echo '$'${VARBRANCH}`
	xxmsg "get_gitbranch: XBRANCH:$XBRANCH $VARBRANCH:$VALBRANCH"

	if [ ! x"$XPWD" = x"" ]; then
		xmsg "get_gitbranch: cd $XPWD"
		cd $XPWD
	fi

	return $RETCODE
}
test_get_gitbranch()
{
	local GITDIR BRANCH

	# set env
	GITDIR=
	BRANCH=
	func_test_reset

	# test code
	GITDIR=
	get_gitbranch
	func_test $ERR_BADSETTINGS "bad settings: GITDIR:$GITDIR get_gitbranch"
	GITDIR=~/github/stable-diffusion.cpp/stable-diffusion.cpp
	cd ~/github/stable-diffusion.cpp
	get_gitbranch BRANCH
	func_test $RET_OK "ok: get_gitbranch BRANCH:$BRANCH"
	cd ~/github/stable-diffusion.cpp/stable-diffusion.cpp
	get_gitbranch BRANCH
	func_test $RET_OK "ok: get_gitbranch BRANCH:$BRANCH"
	cd ~/github/stable-diffusion.cpp/stable-diffusion.cpp/build
	get_gitbranch BRANCH
	func_test $RET_OK "ok: get_gitbranch BRANCH:$BRANCH"

	# reset env
	func_test_show
	BRANCH=
}
#msg "test_get_gitbranch"; VERBOSE=2; test_get_gitbranch; exit 0

TIMESTAMPS=$RET_FALSE

# func:git_init ver: 2024.01.08
# git init
# git_init GITTOKEN
git_init()
{
	# in git folder (TOPDIR)

	local GITTOKEN MAIL GITTOKENURL

	xmsg "git_init: $*"

	if [ x"$GITDIR" = x ]; then
		die $ERR_BADSETTINGS "git_init: need GITDIR, exit"
	fi
	if [ x"$GITNAME" = x ]; then
		die $ERR_BADSETTINGS "git_init: need GITNAME, exit"
	fi

	if [ x"$1" = x ]; then
		die $ERR_NOARG "git_init: need GITTOKEN like ghp_123456789012345678901234567890123456, exit"
	fi
	GITTOKEN="$1"

	# to GITDIR
	msg "cd $GITDIR"
	if [ $NOEXEC -eq $RET_FALSE ]; then
		cd $GITDIR || die $? "can't cd $GITDIR, exit"
	fi

	# check first time
	#if [ ! -f $TOPDIR/CMakeLists.txt ]; then
		msg "# setup git"
		msg "git init"
		if [ $NOEXEC -eq $RET_FALSE ]; then
			git init || die $? "can't git init, exit"
		fi

		MAIL="${GITNAME}@example.com"
		# git git config --global user.email "GITNAME@example.com"
		msg "git config --global user.email \"$MAIL\""
		if [ $NOEXEC -eq $RET_FALSE ]; then
			git config --global user.email "$MAIL"
		fi
		# git config --global user.name "GITNAME"
		msg "git config --global user.name \"$GITNAME\""
		if [ $NOEXEC -eq $RET_FALSE ]; then
			git config --global user.name "$GITNAME"
		fi

		# git remote add origin https://ghp_123456789012345678901234567890123456@github.com/GITNAME/ggml.git
		GITTOKENURL="https://${GITTOKEN}@github.com/${GITNAME}/${TOPDIR}.git"
		msg "git remote remove origin"
		if [ $NOEXEC -eq $RET_FALSE ]; then
			git remote remove origin
		fi
		msg "git remote add origin $GITTOKENURL"
		if [ $NOEXEC -eq $RET_FALSE ]; then
			git remote add origin $GITTOKENURL
		fi

		# save all timestamps
		if [ $TIMESTAMPS -eq $RET_TRUE ]; then
			msg "$BASEDIR/pre-commit -a"
			$BASEDIR/pre-commit -a
			msg "ls -la .timestamps*"
			ls -la .timestamps*
		fi
	#fi
}

# func:git_showinfo ver: 2024.03.03
# show github info
# git_showinfo
git_showinfo()
{
	xmsg "git_showinfo: $*"

	if [ x"$GITDIR" = x ]; then
		die $ERR_BADSETTINGS "git_showinfo: need GITDIR, exit"
	fi

	# to GITDIR
	msg "cd $GITDIR"
	if [ $NOEXEC -eq $RET_FALSE ]; then
		cd $GITDIR || die $? "can't cd $GITDIR, exit"
	fi

	msg "git config --list"
	git config --list

	return $RET_OK
}

# func:do_sync ver: 2024.02.12
# update github token
# git_updatetoken GITTOKEN [removeadd]
git_updatetoken()
{
	local RETCODE XGITTOKEN XTOKENOPT XGITNAME XGITTOKENURL

	xmsg "git_updatetoken: $*"

	if [ x"$GITDIR" = x ]; then
		die $ERR_BADSETTINGS "git_updatetoken: need GITDIR, exit"
	fi
	if [ x"$GITNAME" = x ]; then
		die $ERR_BADSETTINGS "git_updatetoken: need GITNAME, exit"
	fi
	if [ x"$TOPDIR" = x ]; then
		die $ERR_BADSETTINGS "git_updatetoken: need TOPDIR, exit"
	fi

	if [ x"$1" = x ]; then
		msg "cd $GITDIR"
		if [ $NOEXEC -eq $RET_FALSE ]; then
			#cd $GITDIR || die $? "can't cd $GITDIR, exit"
			cd $GITDIR || emsg "can't cd $GITDIR, skip"
			msg "git config --list"
			git config --list
			die $ERR_NOARG "git_updatetoken: need GITTOKEN like ghp_123456789012345678901234567890123456, exit"
		fi
	fi
	XGITTOKEN="$1"
	XTOKENOPT="$2"
	xmsg "XGITTOKEN:$XGITTOKEN"
	xmsg "XTOKENOPT:$XTOKENOPT"

	# to GITDIR
	msg "cd $GITDIR"
	if [ $NOEXEC -eq $RET_FALSE ]; then
		cd $GITDIR || die $? "can't cd $GITDIR, exit"
	fi

	msg "git config --list"
	git config --list

	XGITNAME=
	msg "git config --global user.name"
	XGITNAME=`git config --global user.name`
	msg "GITNAME:$GITNAME"

	# git remote add origin https://ghp_123456789012345678901234567890123456@github.com/GITNAME/ggml.git
	XGITTOKENURL="https://${GITNAME}:${XGITTOKEN}@github.com/${GITNAME}/${TOPDIR}.git"
	if [ x"$XTOKENOPT" = x"removeadd" ]; then
		msg "git remote remove origin"
		if [ $NOEXEC -eq $RET_FALSE ]; then
			git remote remove origin
		fi
		msg "git remote add origin $XGITTOKENURL"
		if [ $NOEXEC -eq $RET_FALSE ]; then
			git remote add origin $XGITTOKENURL
		fi
	else
		msg "git remote set-url origin $XGITTOKENURL"
		git remote set-url origin $XGITTOKENURL
	fi
	RETCODE=$?
	msg "git config --list"
	git config --list

	if [ ! $RETCODE -eq $RET_OK ]; then
		emsg "git_updatetoken: $RETCODE: error"
	fi

	return $RETCODE
}

# func:do_sync ver: 2024.01.15
# do synchronize remote BRANCH
# do_sync
do_sync()
{
	# in build

	msg "# synchronizing ..."

	if [ x"$BRANCH" = x ]; then
		die $ERR_BADSETTINGS "do_sync: need BRANCH, exit"
	fi

	msg "git branch"
	git branch
	msg "git checkout $BRANCH"
	if [ $NOEXEC -eq $RET_FALSE ]; then
		git checkout $BRANCH
	fi
	msg "git fetch"
	if [ $NOEXEC -eq $RET_FALSE ]; then
		git fetch || die $? "can not git fetch, exit"
	fi
	msg "git reset --hard origin/master"
	if [ $NOEXEC -eq $RET_FALSE ]; then
		git reset --hard origin/master
	fi

	#msg "ls -lad $GITDIR/*"; ls -lad $GITDIR/*
	if [ $TIMESTAMPS -eq $RET_TRUE ]; then
		msg "ls -la $GITDIR/.timestamps*"
		ls -la $GITDIR/.timestamps*
		msg "$BASEDIR/post-checkout -d $GITDIR"
		$BASEDIR/post-checkout -d $GITDIR
		msg "ls -lad $GITDIR/*"; ls -lad $GITDIR/*

		# save timestamps
		msg "$BASEDIR/pre-commit -d $GITDIR"
		$BASEDIR/pre-commit -d $GITDIR
		msg "ls -la $GITDIR/.timestamps*"
		ls -la $GITDIR/.timestamps*
	fi
}

###
GITNAME=katsu560
TOPDIR=whisper.cpp
REMOTEURL=https://github.com/$GITNAME/$TOPDIR
BASEDIR=~/github/$TOPDIR
GITDIR="$BASEDIR/$TOPDIR"
BUILDPATH="$GITDIR/build"
# script
SCRIPT=script
FIXBASE="fix"
SCRIPTNAME=whispercpp
UPDATENAME=update-${GITNAME}-${SCRIPTNAME}${MYEXT}.sh
FIXSHNAME=${FIXBASE}[0-9][0-9][01][0-9][0-3][0-9]${MYEXT}.sh
FIXSHLATESTNAME=${FIXBASE}latest${MYEXT}.sh
MKZIPNAME=mkzip-${SCRIPTNAME}${MYEXT}.sh
# https://raw.githubusercontent.com/katsu560/stable-diffusion.cpp/script/mkzip-sdcpp.sh
REMOTERAWURL=https://raw.githubusercontent.com/$GITNAME
# https://ghp_123456789012345678901234567890123456@github.com/katsu560/ggml.git
GITTOKEN=


# setup by git clone, git init
if [ x"$1" = x"setup" ]; then
	if [ x"$1" = x ]; then
		die $ERR_NOARG "setup: need GITTOKEN, exit"
	fi

	GITTOKEN="$2"
	SETUPOPT="$3"
	msg "# setup from $REMOTEURL"
	if [ ! -d $GITDIR ]; then
		msg "git clone $REMOTEURL"
		if [ $NOEXEC -eq $RET_FALSE ]; then
			git clone $REMOTEURL || die $? "RETCODE:$?: can't clone $REMOTEURL, exit"
		fi
	fi
	if [ ! -d $GITDIR ]; then
		die $ERR_NOTEXISTED "setup: no GITDIR $GITDIR, exit"
	fi
	if [ -d $GITDIR ]; then
		msg "ls -ld $GITDIR"
		ls -ld $GITDIR
		okmsg "# git clone finished"

		msg "git_init $GITTOKEN $SETUPOPT"
		if [ $NOEXEC -eq $RET_FALSE ]; then
			git_init $GITTOKEN $SETUPOPT || die $? "RETCODE:$?: can't git_init, exit"
		fi

		msg "cd $BASEDIR"
		cd $BASEDIR
		okmsg "# git init finished"
	fi

	if [ ! -f $MKZIPNAME ]; then
		MKZIPNAMEURL="$REMOTERAWURL/$TOPDIR/$SCRIPT/$MKZIPNAME"
		msg "wget -4 $MKZIPNAMEURL"
		if [ $NOEXEC -eq $RET_FALSE ]; then
			#wget -4 $MKZIPNAMEURL || die $? "RETCODE:$?: can't download $MKZIPNAME, exit"
			wget -4 $MKZIPNAMEURL || emsg "RETCODE:$?: can't download $MKZIPNAME, skip"
		else
			chmod +x $MKZIPNAME
			okmsg "# $MKZIPNAME downloaded"
		fi
	else
		okmsg "# $MKZIPNAME already existed, skip"
	fi
	if [ ! -f $FIXSHLATESTNAME ]; then
		FIXSHLATESTNAMEURL="$REMOTERAWURL/$TOPDIR/$SCRIPT/$FIXSHLATESTNAME"
		msg "wget -4 $FIXSHLATESTNAMEURL"
		if [ $NOEXEC -eq $RET_FALSE ]; then
			#wget -4 $FIXSHLATESTNAMEURL || die $? "RETCODE:$?: can't download $FIXSHLATESTNAME, exit"
			wget -4 $FIXSHLATESTNAMEURL || emsg "RETCODE:$?: can't download $FIXSHLATESTNAME, skip"
		else
			chmod +x $FIXSHLATESTNAME
			okmsg "# $FIXSHLATESTNAME downloaded"
		fi
	else
		okmsg "# $FIXSHLATESTNAME already existed, skip"
	fi

	okmsg "# $MYNAME setup finished"
	exit $RET_OK
fi

# cmake
# check OpenBLAS
# new CMakeLists.txt from 2023.7
BLASCMKLIST="$TOPDIR/CMakeLists.txt"
if [ ! -f $BLASCMKLIST ]; then
	die $ERR_NOTEXISTED "not existed: BLASCMKLIST:$BLASCMKLIST, exit\nif you want to setup, do ./$MYNAME setup GITTOKEN like ghp_123456789012345678901234567890123456"
fi
OPENBLAS=`grep -sr WHISPER_OPENBLAS $BLASCMKLIST | sed -z -e 's/\n//g' -e 's/.*WHISPER_OPENBLAS.*/WHISPER_OPENBLAS/'`
BLAS=`grep -sr WHISPER_BLAS $BLASCMKLIST | sed -z -e 's/\n//g' -e 's/.*WHISPER_BLAS.*/WHISPER_BLAS/'`
# WHISPER_OPENBLAS > WHISPER_BLAS
if [ ! x"$BLAS" = x ]; then
	WHISPER_BLAS="-DWHISPER_BLAS=ON"
	BLASVENDOR="-DWHISPER_BLAS_VENDOR=OpenBLAS"
	echo "# use WHISPER_BLAS=$WHISPER_BLAS BLASVENDOR=$BLASVENDOR"
else
	WHISPER_BLAS=
fi
if [ ! x"$OPENBLAS" = x ]; then
	WHISPER_OPENBLAS="-DWHISPER_OPENBLAS=ON"
	echo "# use WHISPER_OPENBLAS=$WHISPER_OPENBLAS"
else
	WHISPER_OPENBLAS=
fi
CMKOPTBLAS="$WHISPER_BLAS $WHISPER_OPENBLAS $BLASVENDOR"

CMKOPTTEST="-DWHISPER_BUILD_TESTS=ON"
CMKOPTEX="-DWHISPER_BUILD_EXAMPLES=ON"
CMKCOMMON="-DWHISPER_STANDALONE=ON $CMKOPTTEST $CMKOPTEX"

CMKOPTNOAVX="-DWHISPER_NO_AVX=ON -DWHISPER_NO_AVX2=ON -DWHISPER_NO_FMA=ON -DWHISPER_NO_F16C=OFF $CMKOPTBLAS $CMKCOMMON"
CMKOPTAVX="-DWHISPER_NO_AVX=OFF -DWHISPER_NO_AVX2=ON -DWHISPER_NO_FMA=ON -DWHISPER_NO_F16C=OFF $CMKOPTBLAS  $CMKCOMMON"
CMKOPTAVX2="-DWHISPER_NO_AVX=OFF -DWHISPER_NO_AVX2=OFF -DWHISPER_NO_FMA=OFF -DWHISPER_NO_F16C=OFF $CMKOPTBLAS  $CMKCOMMON"
CMKOPTNONE="$CMKOPTBLAS $CMKCOMMON"
CMKOPT="$CMKOPTNONE"
CMKOPT2=""

# targets

#Makefile
##
## Examples
##
# :
#main: examples/main/main.cpp $(SRC_COMMON) $(WHISPER_OBJ)
#        $(CXX) $(CXXFLAGS) examples/main/main.cpp $(SRC_COMMON) $(WHISPER_OBJ) -o main $(LDFLAGS)
#        ./main -h
#
#bench: examples/bench/bench.cpp $(WHISPER_OBJ)
#        $(CXX) $(CXXFLAGS) examples/bench/bench.cpp $(WHISPER_OBJ) -o bench $(LDFLAGS)
# :
##
## Audio samples
##
# :
##
## Tests
##
#
#.PHONY: tests
#tests:
#        bash ./tests/run-tests.sh $(word 2, $(MAKECMDGOALS))

NOTGTS="stream command lsp talk"
NOTESTS=
TARGETS=
TESTS=

# func:get_targets ver: 2024.03.02
# get make targets to TARGETS and test targets to TESTS for whisper.cpp
# get_targets
get_targets()
{
	local MKFILE

	MKFILE=$GITDIR/Makefile
	if [ ! -e $MKFILE ]; then
		die $ERR_NOTEXISTED "no $MKFILE, exit"
	fi

	TARGETS=""
	TESTS=""

	msg "NOTGTS:$NOTGTS"
	TARGETS=`awk -v NOTGT0="$NOTGTS" '
	BEGIN { ST=0; NT=0; split(NOTGT0,NOTGT) }
	function is_notgt(tgt) {
		for(i in NOTGT) { if (NOTGT[i]==tgt) return 1; continue }
		return 0;
	}
	ST==1 && /^# Audio samples/ { ST=2 }
	ST==1 && /^[a-zA-Z0-9]*:/ { T=$0; sub(/:.*$/,"",T); if (is_notgt(T)==0) {XT[NT]=T; NT=NT+1 } }
	ST==0 && /^# Examples/ { ST=1 }
	END { for(i in XT) { printf("%s ",XT[i]) } }
	' $MKFILE`
	msg "TARGETS:$TARGETS"

	msg "NOTESTS:$NOTESTS"
	TESTS=`awk -v NOTGT0="$NOTESTS" '
	BEGIN { ST=0; NT=0; split(NOTGT0,NOTGT) }
	function is_notgt(tgt) {
		for(i in NOTGT) { if (NOTGT[i]==tgt) return 1; continue }
		return 0;
	}
	ST==1 && /^[a-zA-Z0-9]*:/ { T=$0; sub(/:.*$/,"",T); if (is_notgt(T)==0) {XT[NT]=T; NT=NT+1 } }
	ST==0 && /^# Tests/ { ST=1 }
	END { for(i in XT) { printf("%s ",XT[i]) } }
	' $MKFILE`
	msg "TESTS:$TESTS"

	if [ x"$TARGETS" = x ]; then
		die $ERR_NOARG "get_targets: no TARGETS, exit"
	fi
	if [ x"$TESTS" = x ]; then
		die $ERR_NOARG "get_targets: no TESTS, exit"
	fi
}
#get_targets; exit 0

# for test, main, examples execution
TESTENV="GGML_NLOOP=1 GGML_NTHREADS=4"

MODELSDIR=../models
SAMPLESDIR=../samples
JFKWAV=jfk.wav
NHKWAV=nhk0521-16000hz1ch-0-10s.wav

MKCLEAN=$RET_FALSE
NOCLEAN=$RET_FALSE

DIRNAME=
BRANCH=
CMD=

###
# func:cd_buildpath ver: 2024.01.08
# cd BUILDPATH
# cd_buildpath
cd_buildpath()
{
	# cd BUILDPATH
	msg "cd $BUILDPATH"
	if [ $NOEXEC -eq $RET_FALSE ]; then
		cd $BUILDPATH
	fi
}

# func:do_mk_script ver: 2024.02.03
# do script(FIXBASEyymmddMYEXT.sh mk) for create script
# do_mk_script
do_mk_script()
{
	# in build

	# update fixsh in BASEDIR and save update files
	msg "# creating FIXSH ..."

	local DTNOW DFFIXSH FFIXSH DFIXSH

	DTNOW=`date '+%y%m%d'`
	msg "DTNOW:$DTNOW"


	# to BASEDIR
	msg "cd $BASEDIR"
	cd $BASEDIR
	if [ $VERBOSE -ge 1 ]; then
		msg "ls -ltr ${FIXSHNAME}*"
		if [ $NOEXEC -eq $RET_FALSE ]; then
			ls -ltr ${FIXSHNAME}*
		fi
	fi
	DFFIXSH=`get_latestdatefile "${FIXSHNAME}*"`
	DFIXSH=`get_datefile_date ymd $DFFIXSH`
	FFIXSH=`get_datefile_file $DFFIXSH`
	# git change date as today, so get date from file name
	DFIXSH=`echo $FFIXSH | sed -e 's/'${FIXBASE}'//' -e 's/'${MYEXT}'\.sh.*//'`
	msg "FIXSH:$FFIXSH"

	# check
	msg "FFIXSH: DTNOW:$DTNOW DFIXSH:$DFIXSH"
	if [ ! x"$DTNOW" = x"$DFIXSH" ]; then
		msg "sh $FFIXSH mk"
		if [ $NOEXEC -eq $RET_FALSE ]; then
			sh $FFIXSH mk
			if [ ! $? -eq $RET_OK ]; then
				die $? "RETCODE:$?: can't make ${FIXBASE}${DTNOW}${MYEXT}.sh, exit"
			fi
			if [ ! -s $FFIXSH ]; then
				rm -f $FFIXSH
				die $ERR_CANTCREATE "size zero, can't create ${FIXBASE}${DTNOW}${MYEXT}.sh, exit"
			fi

			DFFIXSH=`get_latestdatefile "${FIXSHNAME}*"`
			FFIXSH=`get_datefile_file $DFFIXSH`
			msg "$FFIXSH: created"
			msg "ls -l $FFIXSH"
			ls -l $FFIXSH
			if [ ! -s $FFIXSH ]; then
				rm -f $FFIXSH
				die $ERR_CANTCREATE "size zero, can't create ${FIXBASE}${DTNOW}${MYEXT}.sh, exit"
			fi
		fi
	else
		msg "$FFIXSH: already existed, skip"	
	fi

	# back to BUILDPATH
	msg "cd $BUILDPATH"
	cd $BUILDPATH
}
#VERBOSE=2; do_mk_script; exit 0

# func:do_cp ver: 2024.01.01
# do copy sd.cpp source,examples files to DIRNAME for whisper
# do_cp
do_cp()
{
	# in build

	msg "# copying ..."
	chk_and_cp -p ../ggml.[ch] ../whisper.cpp ../whisper.h ../CMakeLists.txt ../Makefile $DIRNAME || die 201 "can't copy files"
	chk_and_cp -pr ../examples $DIRNAME || die 202 "can't copy examples files"
	chk_and_cp -pr ../tests $DIRNAME || die 203 "can't copy tests files"
}

# func:do_cmk ver: 2024.02.18
# do cmake .. CMKOPT CMKOPT2
# do_cmk
do_cmk()
{
	# in build

	if [ x"$CMKOPT" = x ]; then
		die $ERR_BADSETTINGS "do_cmk: need CMKOPT, exit"
	fi

	msg "# do cmake"
	if [ -f CMakeCache.txt ]; then
		msg "rm CMakeCache.txt"
		if [ $NOEXEC -eq $RET_FALSE ]; then
			rm CMakeCache.txt
		fi
	fi
	msg "cmake .. $CMKOPT $CMKOPT2"
	if [ $NOEXEC -eq $RET_FALSE ]; then
		cmake .. $CMKOPT $CMKOPT2 || die 231 "cmake failed"
	fi
	chk_and_cp -p Makefile $DIRNAME/Makefile.build

	# update targets
	msg "get_targets"
	get_targets
}

# func:do_test ver: 2024.01.20
# do make TESTS, then make test, move test exec-files to DIRNAME
# do_test
do_test()
{
	# in build

	# update targets
	msg "get_targets"
	get_targets

	if [ x"$TESTS" = x ]; then
		die $ERR_BADSETTINGS "do_tests: need TESTS, exit"
	fi
	# whisper.cpp test needs main
	if [ x"$TARGETS" = x ]; then
		die $ERR_BADSETTINGS "do_tests: need TARGETS, exit"
	fi

	msg "# testing ..."
	if [ $MKCLEAN -eq $RET_FALSE -a $NOCLEAN -eq $RET_FALSE ]; then
		msg "make clean"
		if [ $NOEXEC -eq $RET_FALSE ]; then
			make clean || die 241 "make clean failed"
			MKCLEAN=$RET_TRUE
		fi
	fi

	# whisper.cpp test needs main
	msg "make $TARGETS"
	if [ $NOEXEC -eq $RET_FALSE ]; then
		make $TARGETS || die 242 "make $TARGETS build failed"
	fi

	msg "make $TESTS"
	if [ $NOEXEC -eq $RET_FALSE ]; then
		make $TESTS || die 242 "make test build failed"
	fi

	msg "env $TESTENV make test"
	if [ $NOEXEC -eq $RET_FALSE ]; then
		env $TESTENV make test || die 243 "make test failed"
	fi
	#msg "mv bin/test* $DIRNAME/"
	#if [ $NOEXEC -eq $RET_FALSE ]; then
	#	mv bin/test* $DIRNAME || die 244 "can't move tests"
	#fi
}

CPSCRIPTFILES=
# func:cp_script ver: 2024.01.03
# copy srcfile to dstfile.yymmdd and dstfile, store dstfiles to CPSCRIPTFILES
# cp_script SRC DST
cp_script()
{
	local SRC DST DFSRC MDSRC DSTDT

	if [ ! $# -ge 2 ]; then
		emsg "cp_script: ARG:$*: need SRC DST, error return"
		return $ERR_NOARG
	fi

	SRC="$1"
	DST="$2"
	xmsg "cp_script: SRC:$SRC"
	xmsg "cp_script: DST:$DST"

	if [ ! -f "$SRC" ]; then
		emsg "cp_script: $SRC: not found, error return"
		return $ERR_NOTEXISTED
	fi
	if [ "$SRC" = "$DST" ]; then
		emsg "cp_script: $SRC: $DST: same file, error return"
		return $ERR_BADARG
	fi

	# DF DstFile
	DFSRC=`get_latestdatefile "$SRC"`
	xxmsg "cp_script: DFSRC:$DFSRC"
	YMDSRC=`get_datefile_date ymd $DFSRC`
	xxmsg "cp_script: YMDSRC:$YMDSRC"
	DSTDT="${DST}.$YMDSRC"
	msg "cp -p \"$SRC\" \"$DSTDT\""
	if [ $NOEXEC -eq $RET_FALSE ]; then
		cp -p "$SRC" "$DSTDT"
	fi
	msg "cp -p \"$SRC\" \"$DST\""
	if [ $NOEXEC -eq $RET_FALSE ]; then
		cp -p "$SRC" "$DST"
	fi
	CPSCRIPTFILES="$DSTDT $DST"
}
test_cp_script()
{
	local DT OKFILE NGFILE TMPDIR1 OKFILE2 NGFILE2 DF RETCODE

	# set test env
	DT=`date '+%y%m%d'`
	msg "DT:$DT0"
	OKFILE=test.$$
	NGFILE=test-no.$$
	touch $OKFILE
	rm $NGFILE
	TMPDIR1=tmpdir.$$
	mkdir $TMPDIR1
	OKFILE2=$TMPDIR1/test2.$$
	NGFILE2=$TMPDIR1/test-no2.$$
	touch $OKFILE2
	rm $NGFILE2
	msg "ls $OKFILE ${NGFILE}* ${OKFILE2}* ${NGFILE2}* $TMPDIR1"
	ls $OKFILE ${NGFILE}* ${OKFILE2}* ${NGFILE2}* $TMPDIR1
	func_test_reset

	# test code
	cp_script
	func_test $ERR_NOARG "no arg: cp_script"

	msg "ls -l $OKFILE $NGFILE $OKFILE2 $NGFILE2"
	cp_script $NGFILE
	RETCODE=$?; ls -l $OKFILE ${NGFILE}* ${OKFILE2}* ${NGFILE2}*; set_ret $RETCODE
	func_test $ERR_NOARG "no arg: cp_script $NGFILE"
	cp_script $OKFILE
	RETCODE=$?; ls -l $OKFILE ${NGFILE}* ${OKFILE2}* ${NGFILE2}*; set_ret $RETCODE
	func_test $ERR_NOARG "no arg: cp_script $OKFILE"
	cp_script $NGFILE2
	RETCODE=$?; ls -l $OKFILE ${NGFILE}* ${OKFILE2}* ${NGFILE2}*; set_ret $RETCODE
	func_test $ERR_NOARG "no arg: cp_script $NGFILE2"
	cp_script $OKFILE2
	RETCODE=$?; ls -l $OKFILE ${NGFILE}* ${OKFILE2}* ${NGFILE2}*; set_ret $RETCODE
	func_test $ERR_NOARG "no arg: cp_script $OKFILE2"

	cp_script $NGFILE $NGFILE2
	RETCODE=$?; ls -l $OKFILE ${NGFILE}* ${OKFILE2}* ${NGFILE2}*; set_ret $RETCODE
	func_test $ERR_NOTEXISTED "not existed: cp_script $NGFILE $NGFILE2"
	cp_script $OKFILE $OKFILE2
	RETCODE=$?; ls -l $OKFILE ${NGFILE}* ${OKFILE2}* ${NGFILE2}*; set_ret $RETCODE
	func_test $RET_OK "ok: cp_script $OKFILE $OKFILE2"
	cp_script $OKFILE $NGFILE
	RETCODE=$?; ls -l $OKFILE ${NGFILE}* ${OKFILE2}* ${NGFILE2}*; set_ret $RETCODE
	func_test $RET_OK "ok: cp_script $OKFILE $NGFILE"
	rm $NGFILE
	cp_script $OKFILE $NGFILE2
	RETCODE=$?; ls -l $OKFILE ${NGFILE}* ${OKFILE2}* ${NGFILE2}*; set_ret $RETCODE
	func_test $RET_OK "ok: cp_script $OKFILE $NGFILE2"
	rm $NGFILE2

	# reset test env
	func_test_show
	msg "rm $OKFILE ${NGFILE}* ${OKFILE2}* ${NGFILE2}*"
	rm $OKFILE ${NGFILE}* ${OKFILE2}* ${NGFILE2}*
	rmdir $TMPDIR1
	msg "ls -l $OKFILE ${NGFILE}* ${OKFILE2}* ${NGFILE2}*"
	ls -l $OKFILE ${NGFILE}* ${OKFILE2}* ${NGFILE2}*
}
#msg "test_cp_script"; VERBOSE=2; NOEXEC=$RET_TRUE; test_cp_script; exit 0
#msg "test_cp_script"; VERBOSE=2; NOEXEC=$RET_FALSE; test_cp_script; exit 0

# func:git_script ver: 2024.03.03
# git push scripts ymd, UPDATENAME, FIXSHNAME, MKZIPNAME
# git_script
git_script()
{
	# in build

	msg "# git push scripts ..."

	local DT0 ADDFILES COMMITFILES
	local DFUPDATE DFFIXSH DFMKZIP FUPDATE FFIXSH FMKZIP
	local DFUPDATEG DFFIXSHG DFMKZIPG FUPDATEG FFIXSHG FMKZIPG
	local TBRANCH

	# check
	if [ x"$BASEDIR" = x ]; then
		die $ERR_BADSETTINGS "git_script: need path, BASEDIR, exit"
	fi
	#if [ x"$TOPDIR" = x ]; then
	#	die $ERR_BADSETTINGS "git_script: need dirname, TOPDIR, exit"
	#fi
	if [ x"$GITDIR" = x ]; then
		die $ERR_BADSETTINGS "git_script: need dirname, GITDIR, exit"
	fi
	if [ x"${FIXSHNAME}" = x ]; then
		die $ERR_BADSETTINGS "git_script: need FIXSHNAME, exit"
	fi
	if [ x"${MKZIPNAME}" = x ]; then
		die $ERR_BADSETTINGS "git_script: need MKZIPNAME, exit"
	fi
	if [ x"${UPDATENAME}" = x ]; then
		die $ERR_BADSETTINGS "git_script: need UPDATENAME, exit"
	fi
	if [ x"$SCRIPT" = x ]; then
		die $ERR_BADSETTINGS "git_script: need branch, SCRIPT, exit"
	fi
	if [ x"$BRANCH" = x ]; then
		die $ERR_BADSETTINGS "git_script: need branch, BRANCH, exit"
	fi
	if [ x"$BUILDPATH" = x ]; then
		die $ERR_BADSETTINGS "git_script: need path, BUILDPATH, exit"
	fi

	DT0=`date '+%y%m%d'`
	msg "DT0:$DT0"

	ADDFILES=""
	COMMITFILES=""

	# to BASEDIR
	msg "cd $BASEDIR"
	cd $BASEDIR
	if [ $VERBOSE -ge 1 ]; then
		msg "ls -ltr ${FIXSHNAME}* ${MKZIPNAME}* ${UPDATENAME}*"
		if [ $NOEXEC -eq $RET_FALSE ]; then
			ls -ltr ${FIXSHNAME}* ${MKZIPNAME}* ${UPDATENAME}*
		fi
	fi
	DFUPDATE=`get_latestdatefile "${UPDATENAME}"`
	DFFIXSH=`get_latestdatefile "${FIXSHNAME}*"`
	DFMKZIP=`get_latestdatefile "${MKZIPNAME}"`
	FUPDATE=
	FFIXSH=
	FMKZIP=
	if [ ! x"$DFUPDATE" = x ]; then
		FUPDATE=`get_datefile_file $DFUPDATE`
	fi
	if [ ! x"$DFFIXSH" = x ]; then
		FFIXSH=`get_datefile_file $DFFIXSH`
	fi
	if [ ! x"$DFMKZIP" = x ]; then
		FMKZIP=`get_datefile_file $DFMKZIP`
	fi
	msg "FUPDATE:$FUPDATE"
	msg "FFIXSH:$FFIXSH"
	msg "FMKZIP:$FMKZIP"

	# to GITDIR
	# move to git SCRIPT branch and sync

	msg "cd $GITDIR"
	cd $GITDIR
	msg "git branch"
	if [ $NOEXEC -eq $RET_FALSE ]; then
		git branch
	fi
	msg "git checkout $SCRIPT"
	if [ $NOEXEC -eq $RET_FALSE ]; then
		git checkout $SCRIPT
		# first time?
		if [ ! $? -eq $RET_OK ]; then
			msg "git checkout -b $SCRIPT"
			git checkout -b $SCRIPT || die $? "git_script: can not create $SCRIPT branch, exit"
			msg "git push -u origin $SCRIPT"
			git push -u origin $SCRIPT || die $? "git_script: can not create remote $SCRIPT branch, exit"
		fi
	fi
	# check branch
	get_gitbranch TBRANCH
	if [ ! x"$TBRANCH" = x"$SCRIPT" ]; then
		die $ERR_NOTEXISTED "git_script: BRANCH:$TBRANCH: not $SCRIPT branch, exit"
	fi

	if [ $TIMESTAMPS -eq $RET_TRUE ]; then
		# restore timestamps
		msg "ls -lad $GITDIR/*"; ls -lad $GITDIR/*
		msg "ls -la $GITDIR/.timestamps*"
		ls -la $GITDIR/.timestamps*
		msg "$BASEDIR/post-checkout --dir $GITDIR"
		$BASEDIR/post-checkout --dir $GITDIR
		msg "ls -lad $GITDIR/*"; ls -lad $GITDIR/*
	fi

	# avoid error: pathspec 'fix1202.sh' did not match any file(s) known to git.
	# avoid  ! [rejected]	script -> script (non-fast-forward)  error: failed to push some refs to 'https://ghp_ ...
	# https://docs.github.com/ja/get-started/using-git/dealing-with-non-fast-forward-errors
	msg "git pull origin $SCRIPT"
	if [ $NOEXEC -eq $RET_FALSE ]; then
		git pull origin $SCRIPT
		if [ ! $? -eq $RET_OK ]; then
			RETCODE=$?
			msg "git checkout master"
			git checkout master
			die $RETCODE "git_script: RETCODE:$?: can not git pull origin $SCRIPT, exit"
		fi
	fi

	if [ $VERBOSE -ge 1 ]; then
		msg "ls -ltr ${FIXSHNAME}* ${MKZIPNAME}* ${UPDATENAME}*"
		if [ $NOEXEC -eq $RET_FALSE ]; then
			ls -ltr ${FIXSHNAME}* ${MKZIPNAME}* ${UPDATENAME}*
		fi
	fi

	# G means git
	DFUPDATEG=`get_latestdatefile "${UPDATENAME}"`
	DFFIXSHG=`get_latestdatefile "${FIXSHNAME}*"`
	DFMKZIPG=`get_latestdatefile "${MKZIPNAME}"`
	FUPDATEG=
	FFIXSHG=
	FMKZIPG=
	if [ ! x"$DFUPDATEG" = x ]; then
		FUPDATEG=`get_datefile_file $DFUPDATEG`
	fi
	if [ ! x"$DFFIXSHG" = x ]; then
		FFIXSHG=`get_datefile_file $DFFIXSHG`
	fi
	if [ ! x"$DFMKZIPG" = x ]; then
		FMKZIPG=`get_datefile_file $DFMKZIPG`
	fi
	msg "FUPDATEG:$FUPDATEG"
	msg "FFIXSHG:$FFIXSHG"
	msg "FMKZIPG:$FMKZIPG"

	#
	if [ ! x"$FUPDATE" = x ]; then
		if [ x"$FUPDATEG" = x ]; then
			# new copy
			FUPDATEG="$UPDATENAME"
			msg "new: copy: $BASEDIR/$FUPDATE $FUPDATEG"
			if [ $NOEXEC -eq $RET_FALSE ]; then
				cp_script $BASEDIR/$FUPDATE $FUPDATEG
				ADDFILES="$ADDFILES $CPSCRIPTFILES"
				COMMITFILES="$COMMITFILES $CPSCRIPTFILES"
			fi
		else
			# check diff, copy
			msg "diff $FUPDATEG $BASEDIR/$FUPDATE"
			if [ $NOEXEC -eq $RET_FALSE ]; then
				if [ $VERBOSE -ge 1 ]; then
					diff $FUPDATEG $BASEDIR/$FUPDATE
				else
					diff $FUPDATEG $BASEDIR/$FUPDATE > /dev/null
				fi
				if [ $? -eq $RET_OK -a $FORCE -eq 0 ]; then
					msg "same: no copy: $BASEDIR/$FUPDATE $FUPDATEG"
				else
					msg "diff: copy: $BASEDIR/$FUPDATE $FUPDATEG"
					cp_script $BASEDIR/$FUPDATE $FUPDATEG
					ADDFILES="$ADDFILES $CPSCRIPTFILES"
					COMMITFILES="$COMMITFILES $CPSCRIPTFILES"
				fi
			fi
		fi
	fi

	if [ ! x"FFIXSH" = x ]; then
		if [ x"$FFIXSHG" = x ]; then
			# new copy
			msg "new: copy: $BASEDIR/$FFIXSH $FFIXSH"
			msg "cp -p $BASEDIR/$FFIXSH $FFIXSH"
			if [ $NOEXEC -eq $RET_FALSE ]; then
				cp -p $BASEDIR/$FFIXSH $FFIXSH
				ADDFILES="$ADDFILES $FFIXSH"
				COMMITFILES="$COMMITFILES $FFIXSH"
			fi
			msg "cp -p $BASEDIR/$FFIXSH $FIXSHLATESTNAME"
			if [ $NOEXEC -eq $RET_FALSE ]; then
				cp -p $BASEDIR/$FFIXSH $FIXSHLATESTNAME
				ADDFILES="$ADDFILES $FIXSHLATESTNAME"
				COMMITFILES="$COMMITFILES $FIXSHLATESTNAME"
			fi
		elif [ ! $FFIXSH = $FFIXSHG ]; then
			# always copy
			msg "always: copy: $BASEDIR/$FFIXSH $FFIXSH"
			msg "cp -p $BASEDIR/$FFIXSH $FFIXSH"
			if [ $NOEXEC -eq $RET_FALSE ]; then
				cp -p $BASEDIR/$FFIXSH $FFIXSH
				ADDFILES="$ADDFILES $FFIXSH"
				COMMITFILES="$COMMITFILES $FFIXSH"
			fi
			msg "cp -p $BASEDIR/$FFIXSH $FIXSHLATESTNAME"
			if [ $NOEXEC -eq $RET_FALSE ]; then
				cp -p $BASEDIR/$FFIXSH $FIXSHLATESTNAME
				ADDFILES="$ADDFILES $FIXSHLATESTNAME"
				COMMITFILES="$COMMITFILES $FIXSHLATESTNAME"
			fi
		else
			# check diff, copy
			msg "diff $FFIXSHG $BASEDIR/$FFIXSH"
			if [ $NOEXEC -eq $RET_FALSE ]; then
				if [ $VERBOSE -ge 1 ]; then
					diff $FFIXSHG $BASEDIR/$FFIXSH
				else
					diff $FFIXSHG $BASEDIR/$FFIXSH > /dev/null
				fi
				if [ $? -eq $RET_OK -a $FORCE -eq 0 ]; then
					msg "same: no copy: $BASEDIR/$FFIXSH $FFIXSHG"
				else
					msg "diff: copy: $BASEDIR/$FFIXSH $FFIXSHG"
					cp_script $BASEDIR/$FFIXSH $FFIXSHG
					ADDFILES="$ADDFILES $CPSCRIPTFILES"
					COMMITFILES="$COMMITFILES $CPSCRIPTFILES"
					msg "cp -p $BASEDIR/$FFIXSH $FIXSHLATESTNAME"
					if [ $NOEXEC -eq $RET_FALSE ]; then
						cp -p $BASEDIR/$FFIXSH $FIXSHLATESTNAME
						ADDFILES="$ADDFILES $FIXSHLATESTNAME"
						COMMITFILES="$COMMITFILES $FIXSHLATESTNAME"
					fi
				fi
			fi
		fi
	fi

	if [ ! x"$FMKZIP" = x ]; then
		if [ x"$FMKZIPG" = x ]; then
			# new copy
			FMKZIPG="$MKZIPNAME"
			msg "new: copy: $BASEDIR/$FMKZIP $FMKZIPG"
			cp_script $BASEDIR/$FMKZIP $FMKZIPG
			ADDFILES="$ADDFILES $CPSCRIPTFILES"
			COMMITFILES="$COMMITFILES $CPSCRIPTFILES"
		else
			# check diff, copy
			msg "diff $FMKZIPG $BASEDIR/$FMKZIP"
			if [ $NOEXEC -eq $RET_FALSE ]; then
				if [ $VERBOSE -ge 1 ]; then
					diff $FMKZIPG $BASEDIR/$FMKZIP
				else
					diff $FMKZIPG $BASEDIR/$FMKZIP > /dev/null
				fi
				if [ $? -eq $RET_OK -a $FORCE -eq 0 ]; then
					msg "same: no copy: $BASEDIR/$FMKZIP $FMKZIPG"
				else
					msg "diff: copy: $BASEDIR/$FMKZIP $FMKZIPG"
					cp_script $BASEDIR/$FMKZIP $FMKZIPG
					ADDFILES="$ADDFILES $CPSCRIPTFILES"
					COMMITFILES="$COMMITFILES $CPSCRIPTFILES"
				fi
			fi
		fi
	fi

	# git
	msg "ADDFILES:$ADDFILES"
	msg "COMMITFILES:$COMMITFILES"
	if [ ! x"$COMMITFILES" = x ]; then
		if [ ! x"$ADDFILES" = x ]; then
			msg "git add $ADDFILES"
			if [ $NOEXEC -eq $RET_FALSE ]; then
				git add $ADDFILES
			fi
		fi
		msg "git commit -m \"update scripts\" $COMMITFILES"
		if [ $NOEXEC -eq $RET_FALSE ]; then
			git commit -m "update scripts" $COMMITFILES
		fi
		msg "git status"
		if [ $NOEXEC -eq $RET_FALSE ]; then
			git status
		fi
		msg "git push origin $SCRIPT"
		if [ $NOEXEC -eq $RET_FALSE ]; then
			git push origin $SCRIPTi
			RETCODE=$?
			if [ ! $? -eq $RET_OK ]; then
				emsg "back to $BRANCH"
				msg "git checkout $BRANCH"
				git checkout $BRANCH
				die $RET_NG "can not git push origin $SCRIPT, exit"
			fi
		fi
	
		if [ $TIMESTAMPS -eq $RET_TRUE ]; then
			# save timestamps
			msg "$BASEDIR/pre-commit -d $GITDIR"
			$BASEDIR/pre-commit -d $GITDIR
			msg "ls -la .timestamps*"
			ls -la .timestamps*
		fi
	fi

	# back
	msg "git checkout $BRANCH"
	if [ $NOEXEC -eq $RET_FALSE ]; then
		git checkout $BRANCH
	fi
	if [ $TIMESTAMPS -eq $RET_TRUE ]; then
		# restore timestamps
		msg "ls -lad $GITDIR/*"; ls -lad $GITDIR/*
		msg "ls -la $GITDIR/.timestamps*"
		ls -la $GITDIR/.timestamps*
		msg "$BASEDIR/post-checkout -d $GITDIR"
		$BASEDIR/post-checkout -d $GITDIR
		msg "ls -lad $GITDIR/*"; ls -lad $GITDIR/*
	fi

	# back to BUILDPATH
	msg "cd $BUILDPATH"
	cd $BUILDPATH
}
#msg "git_script"; NOEXEC=$RET_TRUE; VERBOSE=2; git_script; exit 0


# func:do_bin ver: 2024.02.25
# execute whisper with MODEL, VARWAVFILE, DOOPT for whisper
# do_bin DOBIN MODEL VARWAVFILE DOOPT
do_bin()
{
	local RETCODE XDOBIN XMODEL XVARWAVFILE XWAVFILE DOOPT

	RETCODE=$RET_OK

	if [ x"$DIRNAME" = x ]; then
		emsg "do_bin: need DIRNAME, skip"
		return $ERR_BADSETTINGS
	fi

	if [ x"$1" = x ]; then
		emsg "do_bin: need DOBIN, MODEL, VARWAVFILE skip"
		return $ERR_BADARG
	fi
	XDOBIN="$1"
	XMODEL="$2"
	XVARWAVFILE="$3"
	shift 3
	DOOPT="$*"

	msg "#"
	# warmup
	get_physpath PHYSPATH "$XMODEL"
	msg "ls -l $PHYSPATH"
	ls -l $PHYSPATH

	#msg "./$DIRNAME/main -l en -m $MODELS/ggml-base.bin -f $SAMPLES/$JFKWAV"
	#./$DIRNAME/main -l en -m $MODELS/ggml-base.bin -f $SAMPLES/$JFKWAV || die 84 "do main failed"
	#chk_level $LEVELSTD do_bin $DOBIN models/whisper/ggml-base.bin JFKWAV "-l en"
	#chk_level $LEVELMAX do_bin $DOBIN models/whisper/ggml-base.bin NHKWAV "-l ja"
	#chk_level $LEVELMIN do_bin $DOBIN models/whisper/ggml-small.bin JFKWAV "-l en"
	XWAVFILE=`eval echo '$'${XVARWAVFILE}`

	msg "./$DIRNAME/$XDOBIN -m $XMODEL $DOOPT -f $SAMPLESDIR/$XWAVFILE"
	if [ $NOEXEC -eq $RET_FALSE ]; then
		./$DIRNAME/$XDOBIN -m $XMODEL $DOOPT -f $SAMPLESDIR/$XWAVFILE
		RETCODE=$?
	fi
	if [ ! $RETCODE -eq $RET_OK ]; then
		emsg "do $XDOBIN failed"
	fi

	return $RETCODE
}

# func:mk_clean ver: 2024.02.03
# make clean
# mk_clean [MKOPT]
mk_clean()
{
	local XMKOPT

	XMKOPT=	
	if [ ! x"$1" = x ]; then
		XMKOPT="$1"
	fi
	
	if [ $MKCLEAN -eq $RET_FALSE -a $NOCLEAN -eq $RET_FALSE ]; then
		msg "make clean"
		if [ $NOEXEC -eq $RET_FALSE -a ! x"$XMKOPT" = x"NOMAKE" ]; then
			make clean || die 261 "make clean failed"
			MKCLEAN=$RET_TRUE
		fi
	fi
}

do_main()
{
	local DOMAINOPT BINS MODELS SAMPLES

	DOMAINOPT="$1"

	# in build

	msg "# executing main ..."
	# make main
	if [ ! x"$MAINOPT" = xNOMAKE ]; then
		mk_clean $DOOPT

		msg "get_targets"
		get_targets
		msg "make $TARGETS"
		if [ $NOEXEC -eq $RET_FALSE ]; then
			make $TARGETS || die 252 "make main failed"
		fi
		BINS=""; for i in $TARGETS ;do BINS="$BINS bin/$i" ;done
		chk_and_cp -p $BINS $DIRNAME || die 253 "can't cp main"
	fi

	# main
	DOBIN=main

	if [ ! x"$DOMAINOPT" = xNOEXEC ]; then
		if [ -f ./$DIRNAME/$DOBIN ]; then
			chk_level $LEVELSTD do_bin $DOBIN $MODELSDIR/ggml-base.bin JFKWAV "-l en"
			chk_level $LEVELMAX do_bin $DOBIN $MODELSDIR/ggml-base.bin NHKWAV "-l ja"
			chk_level $LEVELMIN do_bin $DOBIN $MODELSDIR/ggml-small.bin JFKWAV "-l en"
			chk_level $LEVELMIN do_bin $DOBIN $MODELSDIR/ggml-small.bin NHKWAV "-l ja"
			chk_level $LEVELMIN do_bin $DOBIN $MODELSDIR/ggml-small-q4_0.bin NHKWAV "-l ja"
			chk_level $LEVELMIN do_bin $DOBIN $MODELSDIR/ggml-small-q4_1.bin NHKWAV "-l ja"
			# large
			chk_level $LEVELMIN do_bin $DOBIN $MODELSDIR/ggml-large.bin NHKWAV "-l ja"
			chk_level $LEVELMIN do_bin $DOBIN $MODELSDIR/ggml-large-v2.bin NHKWAV "-l ja"
			chk_level $LEVELMIN do_bin $DOBIN $MODELSDIR/ggml-large-v2-q4_k.bin NHKWAV "-l ja"
			chk_level $LEVELMIN do_bin $DOBIN $MODELSDIR/ggml-large-v2-q5_k.bin NHKWAV "-l ja"
			chk_level $LEVELMIN do_bin $DOBIN $MODELSDIR/ggml-large-v3.bin NHKWAV "-l ja"
			chk_level $LEVELMIN do_bin $DOBIN $MODELSDIR/ggml-large-v3-q4_k.bin NHKWAV "-l ja"
			chk_level $LEVELMIN do_bin $DOBIN $MODELSDIR/ggml-large-v3-q5_k.bin NHKWAV "-l ja"

			chk_level $LEVELMIN do_bin $DOBIN $MODELSDIR/ggml-distil-large.bin NHKWAV "-l ja"
		else
			msg "no ./$DIRNAME/$DOBIN, skip executing $DOBIN"
		fi
	else
		msg "skip executing main"
	fi
}

###
# intel oneAPI
INTELONEAPI=$RET_FALSE
SYCL=$RET_FALSE
IONEAPISH=/opt/intel/oneapi/setvars.sh

# func:chk_inteloneapi ver: 2024.02.18
# check Intel oneAPI compiler
# chk_inteloneapi
chk_inteloneapi()
{
	local RETCODE

	if [ ! -f $IONEAPISH ]; then
		emsg "can't exist $IONEAPISH, skip"
		return $ERR_NOTEXISTED
	fi

	cmd "source $IONEAPISH"
	RETCODE=$?
	if [ $RETCODE -eq $RET_OK -o $RETCODE -eq 3 ]; then
		msg "OK: RETCODE:$RETCODE $IONEAPI"
	else
		die $RETCODE "NG: $IONEAPI, exit"
	fi
	cmd icpx --version || die $? "RETCODE:$RETCODE: no icpx, exit"
	cmd icx --version || die $? "RETCODE:$RETCODE: no icx, exit"
	cmd icx-cc --version || die $? "RETCODE:$RETCODE: no icx-cc, exit"

	return $RET_OK
}
#msg "test chk_inteloneapi"; chk_inteloneapi; exit 0

###
usage()
{
	echo "usage: $MYNAME [-h][-v][-n][-f][-nd][-ncp][-nc][-ts][-noavx|avx|avx2][-ione][-sycl][-lv LEVEL] dirname branch cmd"
	echo "       $MYNAME setup GITTOKEN"
	echo "       $MYNAME [-h][-v][-n][-f][-nd][-ncp] token|gitinfo [TOKEN][OPT]"
	echo "options: (default)"
	echo "  -h|--help ... this message"
	echo "  -v|--verbose ... increase verbose message level ($VERBOSE)"
	echo "  -n|--noexec ... no execution, test mode ($NOEXEC)"
	echo "  -f|--force ... increase force level ($FORCE)"
	echo "  -nd|--nodie ... no die ($NODIE)"
	echo "  -ncp|--nocopy ... no copy ($NOCOPY)"
	echo "  -nc|--noclean ... no make clean (FALSE)"
	echo "  -ts|--timestamps ... process timestamps (FALSE)"
	#echo "  -up ... upstream, no mod source, skip test-blas0"
	echo "  -noavx|-avx|-avx2 ... set cmake option for no AVX, AVX, AVX2 (AVX)"
	echo "  -ione|--inteloneapi ... using Intel oneAP compiler ($INTELONEAPI)"
	echo "  -sycl|--sycl ... using SYCL with intel oneAPI compiler ($SYCL)"
	echo "  -lv|--level LEVEL ... set execution level as LEVEL, min. 1 .. max. 5 ($DOLEVEL)"
	echo "  dirname ... directory name ex. 240407up"
	echo "  branch ... git branch ex. master, devpr"
	echo "  cmd ... sycpcmktstmain sy/sync,cp,cmk/cmake,tst/test,main"
	echo "  cmd ... sycpcmktstnm sy,cp,cmk,tst,nm  nm .. build main but no exec"
	echo "  cmd ... mainonly .. main execution only"
	echo "  cmd ... script .. push $UPDATENAME $MKZIPNAME $FIXSHNAME to remote"
	echo ""
	echo "  cmd ... setup .. setup $TOPDIR with GITTOKEN, git clone, init, download scripts"
	echo "  cmd ... token [TOKEN][OPT] .. update git token with TOKEN, opt .. removeadd"
	echo "  cmd ... gitinfo .. show github info"
}
# default -avx
CMKOPT="$CMKOPTAVX"
CMKOPT2=""

###
# options and args
if [ x"$1" = x ]; then
	usage
	exit $ERR_USAGE
fi

ALLOPT="$*"
OPTLOOP=$RET_TRUE
while [ $OPTLOOP -eq $RET_TRUE ];
do
	case $1 in
	-h|--help)	usage; exit $ERR_USAGE;;
	-v|--verbose)	VERBOSE=`expr $VERBOSE + 1`;;
	-n|--noexec)	NOEXEC=$RET_TRUE;;
	-f|--force)	FORCE=`expr $FORCE + 1`;;
	-nd|--nodie)	NODIE=$RET_TRUE;;
	-ncp|--nocopy)	NOCOPY=$RET_TRUE;;
	-nc|--noclean)	NOCLEAN=$RET_TRUE;;
	-ts|--timestamps)
			TIMESTAMPS=$RET_TRUE;;
	#-up)		TARGETS="$ALLBINSUP";;
	-noavx)		CMKOPT="$CMKOPTNOAVX";;
	-avx)		CMKOPT="$CMKOPTAVX";;
	-avx2)		CMKOPT="$CMKOPTAVX2";;
	-ione|-ioneapi|--intel|--intelone|--inteloneapi)
			INTELONEAPI=$RET_TRUE;;
	-sycl|--sycl)	SYCL=$RET_TRUE; INTELONEAPI=$RET_TRUE;;
	-lv|--level)	shift; DOLEVEL=$1;;
	*)		OPTLOOP=$RET_FALSE; break;;
	esac
	shift
done

# default -avx|AVX
if [ x"$CMKOPT" = x"" ]; then
	CMKOPT="$CMKOPTAVX"
fi
#CMKOPT="$CMKOPT $CMKOPT2"

# token
if [ x"$1" = x"token" ]; then
	shift
	msg "git_updatetoken $*"
	git_updatetoken $*
	exit $?
fi
if [ x"$1" = x"gitinfo" ]; then
	shift
	msg "git_showinfo $*"
	git_showinfo $*
	exit $?
fi

if [ $# -lt 3 ]; then
	usage
	exit $ERR_USAGE
fi
DIRNAME="$1"
BRANCH="$2"
CMD="$3"
shift 2
ADDINTEL=$RET_FALSE
ADDSYCL=$RET_FALSE

xmsg "VERBOSE:$VERBOSE NOEXEC:$NOEXEC FORCE:$FORCE NODIE:$NODIE NOCOPY:$NOCOPY"
xmsg "NOCLEAN:$NOCLEAN TIMESTAMPS:$TIMESTAMPS"
xmsg "CMKOPT:$CMKOPT CMKOPT2:$CMKOPT2"
xmsg "LEVEL:$DOLEVEL"
xmsg "INTELONEAPI:$INTELONEAPI SYCL:$SYCL"
if [ $NOEXEC -eq $RET_TRUE ]; then
	emsg "SET NOEXEC as TRUE"
fi

###
# setup part

msg "# start"
get_datetime DTTM0
msg "# date time: $DTTM0"

# warning:  Clock skew detected.  Your build may be incomplete.
msg "sudo ntpdate ntp.nict.jp"
if [ $NOEXEC -eq $RET_FALSE ]; then
	sudo ntpdate ntp.nict.jp || die $? "can not ntp sync, exit"
fi

# check
if [ $NOEXEC -eq $RET_FALSE ]; then
	if [ ! -d $TOPDIR ]; then
		die $ERR_NOTOPDIR "# can't find $TOPDIR, exit"
	fi
else
	msg "skip check $TOPDIR"
fi
if [ ! -d $BUILDPATH ]; then
	msg "mkdir -p $BUILDPATH"
	if [ $NOEXEC -eq $RET_FALSE ]; then
		mkdir -p $BUILDPATH
		if [ ! -d $BUILDPATH ]; then
			die $ERR_NOBUILDDIR "# can't find $BUILDPATH, exit"
		fi
	fi
fi

msg "cd $BUILDPATH"
cd $BUILDPATH

msg "git branch"
if [ $NOEXEC -eq $RET_FALSE ]; then
	git branch
fi
get_gitbranch CURBRANCH
if [ $TIMESTAMPS -eq $RET_TRUE ]; then
	if [ ! x"$BRANCH" = x"$CURBRANCH" ]; then
		emsg "branch mismatch $BRANCH != $CURBRANCH"
		emsg "ls -al $GITDIR/.timestamps*"
		ls -al $GITDIR/.timestamps*
		emsg "do ../pre-commit [-a], ../post-checkout [-r reference-branch]"
		die $ERR_BADSETTINGS "branch mismatch $BRANCH != $CURBRANCH, exit"
	fi
fi

msg "git checkout $BRANCH"
if [ $NOEXEC -eq $RET_FALSE ]; then
	git checkout $BRANCH
fi
TBRANCH=
get_gitbranch TBRANCH
xmsg "TBRANCH:$TBRANCH"
if [ ! $? -eq $RET_OK ]; then
	die $? "# can't git checkout BRANCH:$BRANCH, exit"
elif [ ! $TBRANCH = $BRANCH ]; then
	die $ERR_BADARG "# BRANCH:$TBRANCH: can't git checkout BRANCH:$BRANCH, exit"
fi

if [ ! -e $DIRNAME ]; then
	msg "mkdir $DIRNAME"
	if [ $NOEXEC -eq $RET_FALSE ]; then
		mkdir $DIRNAME
		if [ ! -e $DIRNAME ]; then
			die $ERR_NOTEXISTED "no directory: $DIRNAME, exit"
		fi
	fi
fi


# main options and cmd loop

xmsg "cmdloop: CMD:$# $*"
while [ $# -gt 0 ];
do
	OPTLOOP=$RET_TRUE
	xmsg "cmdloop: OPTLOOP:$OPTLOOP CMD:$# $*"

	# remove break at *
	case $1 in
	-h|--help)	usage; exit $ERR_USAGE;;
	-v|--verbose)	VERBOSE=`expr $VERBOSE + 1`;;
	-n|--noexec)	NOEXEC=$RET_TRUE;;
	-f|--force)	FORCE=`expr $FORCE + 1`;;
	-nd|--nodie)	NODIE=$RET_TRUE;;
	-ncp|--nocopy)	NOCOPY=$RET_TRUE;;
	-nc|--noclean)	NOCLEAN=$RET_TRUE;;
	-ts|--timestamps)
			TIMESTAMPS=$RET_TRUE;;
	#-up)		TARGETS="$TARGETSUP";;
	-noavx)		CMKOPT="$CMKOPTNOAVX";;
	-avx)		CMKOPT="$CMKOPTAVX";;
	-avx2)		CMKOPT="$CMKOPTAVX2";;
	-ione|-ioneapi|--intel|--intelone|--inteloneapi)
			INTELONEAPI=$RET_TRUE;;
	-sycl|--sycl)	SYCL=$RET_TRUE; INTELONEAPI=$RET_TRUE;;
	-lv|--level)	shift; DOLEVEL=$1;;
	*)		OPTLOOP=$RET_FALSE;;
	esac

	# check no CMD
	if [ $OPTLOOP -eq $RET_TRUE ]; then
		shift
		xmsg "cmdloop: continue: CMD:$# $*"
		continue
	fi

	CMD="$1"
	xmsg "cmdloop: CMD:$CMD"

	# check intel
	msg "INTELONEAPI:$INTELONEAPI SYCL:$SYCL"
	if [ $INTELONEAPI -eq $RET_TRUE -a $ADDINTEL -eq $RET_FALSE ]; then
		chk_inteloneapi || die $? "can't use Intel oneAPI compiler, exit"
		CMKOPT2="$CMKOPT2 -DCMAKE_C_COMPILER=icx -DCMAKE_CXX_COMPILER=icpx"
		msg "updated CMKOPT2:$CMKOPT2"
		ADDINTEL=$RET_TRUE
	fi
	# sycl
	if [ $SYCL -eq $RET_TRUE -a $ADDSYCL -eq $RET_FALSE -a $ADDINTEL -eq $RET_TRUE ]; then
		cmd sycl-ls || die $? "can't use sycl-ls, exit"
		CMKOPT2="$CMKOPT2 -DWHISPER_SYCL=ON"
		msg "updated CMKOPT2:$CMKOPT2"
		ADDSYCL=$RET_TRUE
	fi
	msg "CMKOPT:$CMKOPT"
	msg "CMKOPT2:$CMKOPT2"

	case $CMD in
	*sync*)		do_sync; cd_buildpath; do_mk_script;;
	*sy*)		do_sync; cd_buildpath; do_mk_script;;
	*)		msg "no sync";;
	esac

	case $CMD in
	*copy*)		do_cp;;
	*cp*)		do_cp;;
	*)		msg "no copy";;
	esac

	case $CMD in
	*cmake*)	do_cmk;;
	*cmk*)		do_cmk;;
	*)		msg "no cmake";;
	esac

	case $CMD in
	*test*)		do_test;;
	*tst*)		do_test;;
	*)		msg "no make test";;
	esac

	case $CMD in
	*nm*)		do_main NOEXEC;;
	*nomain*)	do_main NOEXEC;;
	*mainonly*)	do_main NOMAKE;;
	*main*)		do_main;;
	*)		msg "no make main";;
	esac

	case $CMD in
	*script*)	git_script;;
	*scr*)		git_script;;
	*)		msg "no git push script";;
	esac

	shift
done


# end part

msg "# end"
get_datetime DTTM1
msg "# date time: $DTTM1"
msg "# done."

# duration
#update-katsu560-sdcpp.sh: # date: 20231229-064933
#update-katsu560-sdcpp.sh: # date: 20231229-145939
DTTMSEC=`diff_datetime $DTTM0 $DTTM1`

# summary
msg "# $MYNAME $ALLOPT"
msg "# date time of start: $DTTM0"
msg "# date time of end:   $DTTM1"
msg "# duration: $DTTMSEC sec"
msg "# output file(s):"
DTTMMIN=`expr $DTTMSEC + 59`
DTTMMIN=`expr $DTTMMIN / 60`
EXCLUDE='^'$BUILDPATH'/('$DIRNAME'|CMakeFiles|Testing|data|examples|src|tests)/.*'
msg "find $BUILDPATH -type f \( -cmin -$DTTMMIN -o -mmin -$DTTMMIN \) -regextype awk -not -regex $EXCLUDE -exec ls -l '{}' \;"
find $BUILDPATH -type f \( -cmin -$DTTMMIN -o -mmin -$DTTMMIN \) -regextype awk -not -regex $EXCLUDE -exec ls -l '{}' \;

# end
