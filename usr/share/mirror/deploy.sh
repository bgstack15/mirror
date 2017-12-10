#!/bin/sh
# Filename: deploy.sh
# Location: 
# Author: bgstack15@gmail.com
# Startdate: 2017-12-09 14:21:26
# Title: Script that Deploys Packages and Files to Directories Served to the Web
# Purpose: 
# Package: 
# History: 
#    2017-12-09 rewrite of deploy1.sh
# Usage: 
# Reference: ftemplate.sh 2017-11-11a; framework.sh 2017-11-11a
#    sed nongreedy match https://stackoverflow.com/a/1103159/3569534
# Improve:
fiversion="2017-11-11a"
deployversion="2017-12-09a"

usage() {
   less -F >&2 <<ENDUSAGE
usage: deploy.sh [-duV] [-c conffile] [-n] packagename packageversion
version ${deployversion}
 -d debug   Show debugging info, including parsed variables.
 -u usage   Show this usage block.
 -V version Show script version number.
 -c conf    Read in this config file. Default is ${default_infile1}.
 -n noupdate Do not execute the update script. Useful for serial deployments.
Given a packagename and packageversion, this script will deploy the correct architecture type of package file to the specified locations.
If debug level is 3 or less, the copy will actually be performed.
See the conffile ${conffile} for examples.
Return values:
 0 Normal
 1 Help or version info displayed
 2 Count or type of flaglessvals is incorrect
 3 Incorrect OS type
 4 Unable to find dependency
 5 Not run as root or sudo
Debug levels:
0 silent operation
2 File actions
4 Display only. DOES NOT PERFORM ANY FILE ACTIONS if debuglev >= 4.
5 All variables from conf file
ENDUSAGE
}

# DEFINE FUNCTIONS

fileaction() {
   # call: fileaction copy ${thisfile} ${destdir}
   debuglev 11 && ferror "CALLED: fileaction $@"
   __thisaction="${1}"
   __thisleftfile="${2}"
   ! test -d "${3}" && mkdir -p "${3}"
   __thisrightdir="$( fwhich "${3}" )"
   case "${__thisaction}" in
      copy) __thisfacommand="/bin/cp -p";;
      symlink) __thisfacommand="/bin/ln -sf"; ferror "fileaction symlink not supported any more. Continuing..." && break ;;
      *) __thisfacommand=echo;;
   esac
   debuglev 2 && { ferror ${__thisfacommand}  "${__thisleftfile}" "${__thisrightdir}/"; }
   ! debuglev 4 && { ${__thisfacommand} "${__thisleftfile}" "${__thisrightdir}"; } 2>&1 | grep -viE "failed to preserve ownership for|preserving times for.*: Operation not permitted"
   thiszoneused=1
}

# DEFINE TRAPS

clean_deploy() {
   # use at end of entire script if you need to clean up tmpfiles
   rm -f ${tmpfile1} 1>/dev/null 2>&1
   :
}

CTRLC() {
   # use with: trap "CTRLC" 2
   # useful for controlling the ctrl+c keystroke
   :
}

CTRLZ() {
   # use with: trap "CTRLZ" 18
   # useful for controlling the ctrl+z keystroke
   :
}

parseFlag() {
   flag="$1"
   hasval=0
   case ${flag} in
      # INSERT FLAGS HERE
      "d" | "debug" | "DEBUG" | "dd" ) setdebug; ferror "debug level ${debug}";;
      "u" | "usage" | "help" | "h" ) usage; exit 1;;
      "V" | "fcheck" | "version" ) ferror "${scriptfile} version ${deployversion}"; exit 1;;
      #"i" | "infile" | "inputfile" ) getval; infile1=${tempval};;
      "c" | "conf" | "conffile" | "config" ) getval; infile1="${tempval}";;
      "n" | "noupdate" | "no-update" ) noupdate=1;;
   esac
   
   debuglev 10 && { test ${hasval} -eq 1 && ferror "flag: ${flag} = ${tempval}" || ferror "flag: ${flag}"; }
}

# DETERMINE LOCATION OF FRAMEWORK
while read flocation; do if test -x ${flocation} && test "$( ${flocation} --fcheck )" -ge 20171111; then frameworkscript="${flocation}"; break; fi; done <<EOFLOCATIONS
./framework.sh
${scriptdir}/framework.sh
~/bin/bgscripts/framework.sh
~/bin/framework.sh
~/bgscripts/framework.sh
~/framework.sh
/usr/local/bin/bgscripts/framework.sh
/usr/local/bin/framework.sh
/usr/bin/bgscripts/framework.sh
/usr/bin/framework.sh
/bin/bgscripts/framework.sh
/usr/local/share/bgscripts/framework.sh
/usr/share/bgscripts/framework.sh
EOFLOCATIONS
test -z "${frameworkscript}" && echo "$0: framework not found. Aborted." 1>&2 && exit 4

# INITIALIZE VARIABLES
# variables set in framework:
# today server thistty scriptdir scriptfile scripttrim
# is_cronjob stdin_piped stdout_piped stderr_piped sendsh sendopts
. ${frameworkscript} || echo "$0: framework did not run properly. Continuing..." 1>&2
default_infile1=/etc/mirror/deploy.conf
infile1="${default_infile1}"
outfile1=
logfile=${scriptdir}/${scripttrim}.${today}.out
tmpfile1="$( mktemp )"
define_if_new interestedparties "bgstack15@gmail.com"
# SIMPLECONF
define_if_new default_conffile "/etc/deploy/deploy.conf"
define_if_new defuser_conffile ~/.config/deploy/deploy.conf

# REACT TO OPERATING SYSTEM TYPE
case $( uname -s ) in
   Linux) : ;;
   FreeBSD) : ;;
   *) ferror "${scriptfile}: 3. Indeterminate OS: $( uname -s )" && exit 3;;
esac

## REACT TO ROOT STATUS
#case ${is_root} in
#   1) # proper root
#      : ;;
#   sudo) # sudo to root
#      : ;;
#   "") # not root at all
#      #ferror "${scriptfile}: 5. Please run as root or sudo. Aborted."
#      #exit 5
#      :
#      ;;
#esac

# SET CUSTOM SCRIPT AND VALUES
#setval 1 sendsh sendopts<<EOFSENDSH     # if $1="1" then setvalout="critical-fail" on failure
#/usr/local/share/bgscripts/send.sh -hs  # setvalout maybe be "fail" otherwise
#/usr/share/bgscripts/send.sh -hs        # on success, setvalout="valid-sendsh"
#/usr/local/bin/send.sh -hs
#/usr/bin/mail -s
#EOFSENDSH
#test "${setvalout}" = "critical-fail" && ferror "${scriptfile}: 4. mailer not found. Aborted." && exit 4

# VALIDATE PARAMETERS
# objects before the dash are options, which get filled with the optvals
# to debug flags, use option DEBUG. Variables set in framework: fallopts
validateparams packagename packageversion - "$@"

# CONFIRM TOTAL NUMBER OF FLAGLESSVALS IS CORRECT
if test ${thiscount} -lt 2;
then
   # see if packagename has the version as well.
   if echo "${packagename}" | grep -qE -- '-[0-9]' ;
   then 
      # FINDTHIS split name from version
      packageversion="$( echo "${packagename}" | sed -r -e 's/^[^-]*-([0-9])/\1/;' )"
      packagename="$( echo "${packagename}" | sed -r -e "s/-${packageversion}//;" )"
   else
     ferror "${scriptfile}: 2. Invalid packagename \"${packagename}\" and version \"${packageversion}\". Aborted."
     exit 2
   fi
fi

## LOAD CONFIG FROM SIMPLECONF
## This section follows a simple hierarchy of precedence, with first being used:
##    1. parameters and flags
##    2. environment
##    3. config file
##    4. default user config: ~/.config/script/script.conf
##    5. default config: /etc/script/script.conf
#if test -f "${conffile}";
#then
#   get_conf "${conffile}"
#else
#   if test "${conffile}" = "${default_conffile}" || test "${conffile}" = "${defuser_conffile}"; then :; else test -n "${conffile}" && ferror "${scriptfile}: Ignoring conf file which is not found: ${conffile}."; fi
#fi
#test -f "${defuser_conffile}" && get_conf "${defuser_conffile}"
#test -f "${default_conffile}" && get_conf "${default_conffile}"

# CONFIGURE VARIABLES AFTER PARAMETERS
if ! test -f "${infile1}" ;
then
   ferror "${scriptfile}: Cannot read requested conf file \"${infile1}\". Using defaults from \"${default_infile1}\". Continuing..."
   infile1="${default_infile1}"
fi

# START READ CONFIG FILE TEMPLATE
zonecount=0
oIFS="${IFS}"; IFS="$( printf '\n' )"
infiledata=$( ${sed} ':loop;/^\/\*/{s/.//;:ccom;s,^.[^*]*,,;/^$/n;/^\*\//{s/..//;bloop;};bccom;}' "${infile1}") #the crazy sed removes c style multiline comments
IFS="${oIFS}"; infilelines=$( echo "${infiledata}" | wc -l )
{ echo "${infiledata}"; echo "ENDOFFILE"; } | {
   while read line; do
   # the crazy sed removes leading and trailing whitespace, blank lines, and comments
   if test ! "${line}" = "ENDOFFILE";
   then
      line=$( echo "${line}" | sed -e 's/^\s*//;s/\s*$//;/^[#$]/d;s/\s*[^\]#.*$//;' )
      if test -n "${line}";
      then
         debuglev 8 && ferror "line=\"${line}\""
         if echo "${line}" | grep -qiE "\[.*\]";
         then
            # new zone
            zone=$( echo "${line}" | tr -d '[]' )
            debuglev 7 && ferror "zone=${zone}"
            zonecount=$(( ${zonecount} + 1 ))
            zones[${zonecount}]=${zone}
         else
            # directive
            varname=$( echo "${line}" | awk -F= '{print $1}' )
            varval=$( echo "${line}" | awk -F= '{$1=""; printf "%s", $0}' | sed 's/^ //;' )
            debuglev 7 && ferror "X_${zone}_${varname}=\"${varval}\""
            # simple define variable
            #eval "${zone}${varname}=\${varval}"
            eval "X_${zone}_${varname}=\${varval}"
         fi
         ## this part is untested
         #read -p "Please type something here:" response < ${thistty}
         #echo "${response}"
      fi
   else

## REACT TO BEING A CRONJOB
#if test ${is_cronjob} -eq 1;
#then
#   :
#else
#   :
#fi

# SET TRAPS
#trap "CTRLC" 2
#trap "CTRLZ" 18
trap "clean_deploy" 0

## DEBUG SIMPLECONF
#debuglev 5 && {
#   ferror "Using values"
#   # used values: EX_(OPT1|OPT2|VERBOSE)
#   set | grep -iE "^EX_" 1>&2
#}

# Debug section
debuglev 5 &&  set | grep -E '^(X_|zones=|packagename|packageversion)' 1>&2

## CONFIRM the input zone exists
[[ -z "${X_input_type}" ]] || [[ ! "${X_input_type}" = "input" ]] && fexit 6 "Invalid inputtype: \"${X_input_type}\". Must be \"input\" and in zone named \"input\". Aborted."
[[ -z "${X_input_location}" ]] || [[ ! -d "${X_input_location}" ]] && fexit 6 "Invalid inputlocation: \"${X_input_location}\". Confirm directory exists. Aborted."
# [[ -n "${X_input_packagedir}" ]] && eval X_input_packagedir="${X_input_packagedir}"

# MAIN LOOP
#{
   for thiszone in ${zones[@]} ;
   do
      eval thistype="\${X_${thiszone}_type}"
      case "${thistype}" in
         input)
            #echo "INPUT ZONE IS HERE"
            eval thisinputlocation="\${X_input_location}"
            eval thisinputpackagedir="$( eval echo "\${X_input_packagedir}" | sed -r -e "s/\\$\{(location)/\$\{X_${thiszone}_\1/g;" )"
            ;;
         destination)
            #set | grep -E "X_${thiszone}_"
            eval thisflavor="\${X_${thiszone}_flavor}"
            eval thislocation="\${X_${thiszone}_location}"
            eval thisupdatescript="\${X_${thiszone}_updatescript}"
            eval thispackagedir="$( eval echo "\${X_${thiszone}_packagedir}" | sed -r -e "s/\\$\{(location)/\$\{X_${thiszone}_\1/g;" )"

            #echo "------------"
            #echo "thislocation=${thislocation}"
            #echo "thispackagedir=${thispackagedir}"
            
            # find the files to move to thispackagedir
            notregex=''
            case "${thisflavor}" in
               rpm | centos | redhat | fedora | korora )
                  filetyperegex='.*.rpm'
                  ;;
               deb | debian | ubuntu | devuan | mint )
                  filetyperegex='.*.deb'
                  ;;
               freebsd | bsd )
                  filetyperegex='.*freebsd.*\(.tar.gz\|.tgz\)'
                  ;;
               tar | tarball | targz | tar.gz )
                  filetyperegex='.*\(.tar.gz\|.tgz\)'
                  notregex='.*freebsd.*'
                  ;;
               * )
                  ferror "For zone \"${thiszone}\", will use default flavor \"tarball\"."
                  filetyperegex='.*\(.tar.gz\|.tgz\)'
                  notregex='.*freebsd.*'
                  ;;
            esac
            filetyperegex=".*${packagename}-${packageversion}.*${filetyperegex}"
            #echo find "${thisinputpackagedir}" -type f -regex "${filetyperegex}" ! -regex "${notregex}" 
            find "${thisinputpackagedir}" -type f -regex "${filetyperegex}" ! -regex "${notregex}" > "${tmpfile1}"

            # perform file action
            thiszoneused=0
            while read leftfile ;
            do
               fileaction copy "${leftfile}" "${thispackagedir}/"
            done < "${tmpfile1}"

            # execute update script
            if ! test "${thiszoneused}" = "0" ;
            then
               #echo "THISZONEUSED"
               if ! test "${noupdate}" = "1" ;
               then
                  #echo "NOUPDATE IS ZERO"
                  if test -n "${thisupdatescript}" ;
                  then
                     #echo "THISUPDATESCRIPT IS NOT NULL"
                     if test -x "${thisupdatescript}" ;
                     then
                        debuglev 2 && ferror "Executing updatescript \"${thisupdatescript}\""
                        ! debuglev 4 && fsudo "${thisupdatescript}"
                     else
                        ferror "${scriptfile}: Unable to execute updatescript \"${thisupdatescript}\". Continuing..."
                     fi
                  else
                     # no updatescript specified, so pass
                     :
                  fi
               else
                  # noupdate=1, which means do not call the update scripts
                  :
               fi
            fi

            ;; # case type=destination
      esac
   done
#} | tee -a ${logfile}

# EMAIL LOGFILE
#${sendsh} ${sendopts} "${server} ${scriptfile} out" ${logfile} ${interestedparties}

trap '' 0 # 
clean_deploy

# STOP THE READ CONFIG FILE
exit 0
fi; done; }
