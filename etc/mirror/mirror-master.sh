#!/bin/sh
# Filename: mirror-master.sh
# Location: brass.example.com:/etc/mirror
# Author: bgstack15@gmail.com
# Startdate: 2015-12-14 08:52:20
# Title: Master Mirror Script
# Purpose: Wraps around individual mirror scripts and logs nicely
# Package: 
# History: 
#   2016-01-07 Fixed logic for detecting already-running instance
#   2016-06-08 Modified to use mirror.conf config file, for mirror-1.0-2
# Usage: Call in cron every day
# Reference: ftemplate.sh 2015-11-23a; framework.sh 2015-11-23a
#    mirror.auser1 (2014-11-11)
# Improve:
fiversion="2015-11-23a"
mirrormasterversion="2016-06-08a"

usage() {
   less -F >&2 <<ENDUSAGE
usage: mirror-master.sh [-duV] [ -f | --file /etc/mirror/mirror.conf ] [ --scriptsdir /etc/mirror/scripts ] [ scriptname ]
version ${mirrormasterversion}
 -d debug   Show debugging info, including parsed variables.
 -u usage   Show this usage block.
 -V version Show script version number.
 -f file    Use specified config file. Default is /etc/mirror/mirror.conf
    --scriptsdir    Use specified scripts directory. Will override anything in the called conf file
Return values:
0 Normal
1 Help or version info displayed
2 mirror-master is already running
3 Unable to modify important file
4 Unable to find dependency
5 Not run as root or sudo
Examples:
   mirror-master.sh centos
      This command will run only the scripts/centos file.
   mirror-master.sh centos putty
      This command will run only centos and putty files.
   mirror-master.sh
      This command will run all files with o+x perms in scriptsdir directory.
ENDUSAGE
}

# DEFINE FUNCTIONS

# DEFINE TRAPS

function clean_mirrormaster {
   flecho "${scriptfile}: ENDED" | tee -a ${logfile} 1>&2 2>/dev/null
   rm -f $lockfile >/dev/null 2>&1
   trap '' 0
   [ ] #use at end of entire script if you need to clean up tmpfiles
}

function CTRLC {
   #trap "CTRLC" 2
   [ ] #useful for controlling the ctrl+c keystroke
}

function CTRLZ {
   #trap "CTRLZ" 18
   [ ] #useful for controlling the ctrl+z keystroke
}

function parseFlag {
   flag=$1
   hasval=0
   case $flag in
      # INSERT FLAGS HERE
      "d" | "debug" | "DEBUG" | "dd" ) setdebug; ferror "debug level ${debug}";;
      "u" | "usage" | "help") usage; exit 1;;
      "V" | "fcheck" | "version") ferror "${scriptfile} version ${mirrormasterversion}"; exit 1;;
      #"i" | "infile" | "inputfile") getval;infile1=$tempval;;
      "f" | "file" | "conf" | "config") getval; conffile="${tempval}";;
      "scriptsdir") getval; scriptsdir="${tempval}";;
   esac
   
   debuglev 10 && { [[ hasval -eq 1 ]] && ferror "flag: $flag = $tempval" || ferror "flag: $flag"; }
}

# DETERMINE LOCATION OF FRAMEWORK
while read flocation; do if [[ -x $flocation ]] && [[ $( $flocation --fcheck ) -ge 20160525 ]]; then frameworkscript=$flocation; break; fi; done <<EOFLOCATIONS
./framework.sh
/usr/bgscripts/framework.sh
EOFLOCATIONS
[[ -z "$frameworkscript" ]] && echo "$0: framework not found. Aborted." 1>&2 && exit 4

# INITIALIZE VARIABLES
# variables set in framework:
# today server thistty scriptdir scriptfile scripttrim
# is_cronjob stdin_piped stdout_piped stderr_piped sendsh sendopts
. ${frameworkscript} || echo "$0: framework did not run properly. Continuing..." 1>&2
infile1=
outfile1=
# DEFAULTS unless overwritten by the mirror.conf or command line
lockfile=/var/lock/mirror.lock
logdir=/var/log/mirror/; mkdir -p ${logdir} 2>/dev/null;
logfile=${logdir}/mirror.${today}.log
errorfile=${logdir}/mirror.${today}.err
scriptsdirdefault=/etc/mirror/scripts
scriptsdir="${scriptsdirdefault}"
interestedparties="root"
keeplogs=14
options=
conffiledefault=/etc/mirror/mirror.conf
conffile="${conffiledefault}"

# REACT TO ROOT STATUS
case $is_root in
   1) # proper root
      [ ] ;;
   sudo) # sudo to root
      [ ] ;;
   "") # not root at all
      if [[ ! $(whoami) = "mirror" ]];
      then
         ferror "${scriptfile}: 5. Please run as root or sudo. Aborted."
         exit 5
      fi
      ;;
esac

# SET CUSTOM SCRIPT AND VALUES
#setval 1 sendsh sendopts<<EOFSENDSH      # if $1="1" then setvalout="critical-fail" on failure
#/usr/local/bin/bgscripts/send.sh -hs     #                setvalout maybe be "fail" otherwise
#/usr/local/bin/send.sh -hs               # on success, setvalout="valid-sendsh"
#/usr/bin/mail -s
#EOFSENDSH
#[[ "$setvalout" = "critical-fail" ]] && ferror "${scriptfile}: 4. mailer not found. Aborted." && exit 4

# VALIDATE PARAMETERS
# objects before the dash are options, which get filled with the optvals
# to debug flags, use option DEBUG. Variables set in framework: fallopts
validateparams - "$@"

# CONFIRM TOTAL NUMBER OF FLAGLESSVALS IS CORRECT
#if [[ $thiscount -lt 2 ]];
#then
#   ferror "${scriptfile}: 2. Fewer than 2 flaglessvals. Aborted."
#   exit 2
#fi

# CONFIGURE VARIABLES AFTER PARAMETERS

# ENSURE conffile exists
if [[ ! -f "${conffile}" ]];
then
   if [[ "${conffile}" = "${conffiledefault}" ]];
   then
      # same as default, and does not exist. Throw warning and continue.
      debuglev 1 && ferror "${scriptfile}: Warning 4. Conf ${conffile} not found. Resuming with defaults."
   else
      # specific conf file does not exist. Abort.
      ferror "${scriptfile}: 4. Conf ${conffile} not found. Aborted."
      exit 4
   fi
else
# READ CONFIG FILE TEMPLATE
[[ 1 -eq 1 ]] && { # REMOVE THIS LINE TO USE THE CONFIG FILE PARSER TEMPLATE
oIFS="${IFS}"; IFS=$'\n'
infiledata=( $( sed ':loop;/^\/\*/{s/.//;:ccom;s,^.[^*]*,,;/^$/n;/^\*\//{s/..//;bloop;};bccom;}' "${conffile}") ) #the crazy sed removes c style multiline comments
IFS="${oIFS}"
for line in "${infiledata[@]}";
do line=$( echo "${line}" | sed -e 's/^\s*//;s/\s*$//;/^[#$]/d;s/\s*[^\]#.*$//;' ); [[ -n "${line}" ]] && {
   # the crazy sed removes leading and trailing whitespace, blank lines, and comments
   debuglev 8 && ferror "line=\"$line\""
   if echo "${line}" | grep -qiE "\[.*\]";
   then
      # new zone
      zone=$( echo "${line}" | tr -d '[]' )
      debuglev 7 && ferror "zone=${zone}"
   else
      # directive
      varname=$( echo "${line}" | awk -F\  '{print $1}' )
      varval=$( echo "${line}" | awk -F\  '{$1=""; printf "%s", $0}' | sed 's/^ //;' )
      debuglev 7 && ferror $( eval echo ${varname}=\\\"${varval}\\\" )
      # simple define variable #eval "${zone}${varname}=\${varval}"
      if [[ "${zone}" = "mirror" ]];
      then
         eval "${varname}"=${varval}
      fi
   fi
   #read -p "Please type something here:" response < $thistty
   #echo "$response"
}; done
} # AND THIS LINE
fi

## REACT TO BEING A CRONJOB
#if [[ $is_cronjob -eq 1 ]];
#then
#   [ ]
#else
#   [ ]
#fi

# SET TRAPS
#trap "CTRLC" 2
#trap "CTRLZ" 18
trap "clean_mirrormaster" 0

## PRE-RUN CHECKS
# Ensure not running
if [[ -e ${lockfile} ]];
then
   psmirror=$( cat ${lockfile} )
   if ps h ${psmirror} >/dev/null;
   then
      # lockfile exists and points to a valid running process
      ferror "${scriptfile}: 2. Mirror is already running. Aborted."
      exit 2
   else
      rm ${lockfile}
   fi
fi

# Lock the queue
if ! touch ${lockfile};
then
   ferror "${scriptfile}: 2. Could not create lockfile ${lockfile}. Aborted."
   exit 2
else
   echo "$$" > ${lockfile}
fi

# Ensure files can be created
for word in ${logfile} ${errorfile};
do
   if ! touch ${word};
   then
      ferror "${scriptfile}: 3. Could not modify file ${word}. Aborted."
      exit 3
   fi
done

# Perform logfile cleanup
if [ -n ${keeplogs} ];
then
   find "${logdir}" -type f -mtime "+${keeplogs}" -exec rm -f {} \; 2>/dev/null
fi

# MAIN LOOP
exec 3>&1
{
   {
      debugstring=
      debuglev 1 && debugstring="debugging "
      flecho "BEGIN ${debugstring}mirror"
      flecho "BEGIN ${debugstring}errors" 1>&2
   
      if [ -n thiscount ] && [[ thiscount -ge 1 ]];
      then
         for word in ${fallopts};
         do
            thisfile=$( find ${scriptsdir} -type f -perm /o=x -name "${word}" )
            if debuglev 1;
            then
               [[ -f "${thisfile}" ]] && \
                  echo "${thisfile}" || \
                  flecho "not found: ${scriptsdir}/${word}. Skipped." 1>&2
            else
               [[ -f "${thisfile}" ]] && \
                  find ${scriptsdir} -type f -perm /o=x -name "${word}" -exec {} $options \; || \
                  flecho "not found: ${scriptsdir}/${word}. Skipped." 1>&2
            fi
         done
      else
         if debuglev 1;
         then
            find "${scriptsdir}" -type f -perm /o=x
         else
            find "${scriptsdir}" -type f -perm /o=x -exec {} $options \;
         fi
      fi
   
      flecho "END ${debugstring}mirror"
      flecho "END ${debugstring}errors" 1>&2
   } 2>&1 1>&3 | tee -a ${errorfile} 1>&2
} 3>&1 | tee -a $logfile

# EMAIL LOGFILE
# will only get here if not interrupted by user input
cat ${errorfile} >> ${logfile}
#$sendsh $sendopts "$server $scriptfile out" $logfile $interestedparties
