#!/bin/sh
# File: /usr/share/mirror/deploy.sh
# Author: bgstack15@gmail.com
# Startdate: 2016-07-14 09:53:09
# Title: Script that Deploys a Package
# Purpose: To make it easy to deploy to the mirror a new version of a package
# Package: mirror
# History: 
#    2017-02-06 Added --noupdate option
#    2017-05-20 Added debugging info for thispackagedir. Also displays better error message when skipping source file for a zone due to its absence.
# Usage: 
# Reference: ftemplate.sh 2016-07-12a; framework.sh 2016-05-25a
#    mirror-master from mirror-1.0-2.noarch.rpm
# This script has a symlink: /usr/local/bin/deploy
# Improve:
#    * provide better package name and version parsing
fiversion="2016-05-25a"
deployversion="2017-04-04a"

usage() {
   less -F >&2 <<ENDUSAGE
usage: deploy.sh [-duV] [-c conffile] [-n] packagename packageversion
version ${deployversion}
 -d debug   Show debugging info, including parsed variables.
 -u usage   Show this usage block.
 -V version Show script version number.
 -c conffile Overrides default conffile value. Default is ${conffile}.
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
6 Config is invalid
Debug levels:
2 Perform file actions
3 Perform file actions and display file copy
4 Display only
5 More debug info
ENDUSAGE
}

function fexit {
   errornum="${1}"; shift
   ferror "$@"
   exit "${errornum}"
}

function fileaction {
   thisaction="${1}"
   thisleftfile="${2}"
   thisrightfile="${3}"
   case "${thisaction}" in
      copy) thisfacommand="/bin/cp -p";;
      symlink) thisfacommand="/bin/ln -sf";;
      *) thisfacommand=echo;;
   esac
   debuglev 2 && { ferror ${thisfacommand}  "${thisleftfile}" "${thisrightfile}"; }
   ! debuglev 4 && { ${thisfacommand} "${thisleftfile}" "${thisrightfile}"; } 2>&1 | grep -viE "failed to preserve ownership for"
}

# DEFINE FUNCTIONS

# DEFINE TRAPS

function clean_deploy {
   #rm -f $logfile >/dev/null 2>&1
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
      "u" | "usage" | "help" | "h" ) usage; exit 1;;
      "V" | "fcheck" | "version" ) ferror "${scriptfile} version ${deployversion}"; exit 1;;
      #"i" | "infile" | "inputfile" ) getval;infile1=$tempval;;
      "c" | "conffile" ) getval;conffile=$tempval;;
      "n" | "noupdate" ) noupdate=1;;
   esac
   
   debuglev 10 && { [[ hasval -eq 1 ]] && ferror "flag: $flag = $tempval" || ferror "flag: $flag"; }
}

# DETERMINE LOCATION OF FRAMEWORK
while read flocation; do if [[ -x $flocation ]] && [[ $( $flocation --fcheck ) -ge 20160229 ]]; then frameworkscript=$flocation; break; fi; done <<EOFLOCATIONS
./framework.sh
/usr/bgscripts/framework.sh
/usr/share/bgscripts/framework.sh
EOFLOCATIONS
[[ -z "$frameworkscript" ]] && echo "$0: framework not found. Aborted." 1>&2 && exit 4

# REACT TO OPERATING SYSTEM TYPE
case $( uname -s ) in
   AIX) [ ];;
   Linux) [ ];;
   *) echo "$scriptfile: 3. Indeterminate OS: $( uname -s )" 1>&2 && exit 3;;
esac

# INITIALIZE VARIABLES
# variables set in framework:
# today server thistty scriptdir scriptfile scripttrim
# is_cronjob stdin_piped stdout_piped stderr_piped sendsh sendopts
. ${frameworkscript} || echo "$0: framework did not run properly. Continuing..." 1>&2
conffile=/etc/mirror/deploy.conf
logfile=${scriptdir}/${scripttrim}.${today}.out
interestedparties="bgstack15@gmail.com"
noupdate=0 # can be adjusted with a flag

# REACT TO ROOT STATUS
case $is_root in
   1) # proper root
      [ ] ;;
   sudo|"") # sudo to root or not root at all
      ferror "${scriptfile}: 5. Please run as root. Aborted."
      exit 5
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
validateparams packagename packageversion - "$@"

# CONFIRM TOTAL NUMBER OF FLAGLESSVALS IS CORRECT
if [[ $thiscount -lt 2 ]];
then
   ferror "${scriptfile}: 2. Invalid packagename and version. Aborted."
   exit 2
fi

# CONFIGURE VARIABLES AFTER PARAMETERS

## READ CONFIG FILE TEMPLATE
zonecount=0
[[ 1 -eq 1 ]] && { # REMOVE THIS LINE TO USE THE CONFIG FILE PARSER TEMPLATE
[[ ! -f "${conffile}" ]] && ferror "${scriptfile}: 4. Conffile not found: ${conffile}. Aborted." && exit 4
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
      (( zonecount += 1 ))
      zones[${zonecount}]="${zone}"
      debuglev 7 && ferror "zone=${zone}"
   else
      # directive
      varname=$( echo "${line}" | awk -F= '{print $1}' )
      varval=$( echo "${line}" | awk -F= '{$1=""; printf "%s", $0}' | sed 's/^ //;' )
      #debuglev 7 && ferror "${zone}$( eval echo ${varname}=\\\"${varval}\\\" )" #evaluates the variables in the varval
      debuglev 7 && ferror "${zone}${varname}=\"${varval}\""
      # simple define variable
      eval "${zone}${varname}=\${varval}"
   fi
   #read -p "Please type something here:" response < $thistty
   #echo "$response"
}; done
} # AND THIS LINE
#echo "zonecount=${zonecount}"
#for word in ${zones[@]}; do echo ${word}; done

## CONFIRM the input zone exists
[[ -z "${inputtype}" ]] || [[ ! "${inputtype}" = "input" ]] && fexit 6 "Invalid inputtype: \"${inputtype}\". Must be \"input\" and in zone named \"input\". Aborted."
[[ -z "${inputlocation}" ]] || [[ ! -d "${inputlocation}" ]] && fexit 6 "Invalid inputlocation: \"${inputlocation}\". Confirm directory exists. Aborted."
[[ -n "${inputpackagedir}" ]] && eval inputpackagedir="${inputpackagedir}"

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
#trap "clean_deploy" 0

# MAIN LOOP
#{
   for thiszone in ${zones[@]};
   do
      [[ ! "${thiszone}" = "input" ]] && {
         debuglev 5 && ferror "Running ${thiszone}"
         #eval thislocation=\${${thiszone}location}
         eval eval thislocation=\${${thiszone}location}; location="${thislocation}"
         if [[ -z "${thislocation}" ]] || [[ ! -d "${thislocation}" ]]; then continue; fi

         # so the location exists
         thiszoneused=0

         # DERIVE PACKAGE SOURCE FILE
         eval thisflavor=\${${thiszone}flavor}
         eval thispackagedir=\${${thiszone}packagedir}
         eval eval thispackagedir=\${${thiszone}packagedir}
         debuglev 5 && ferror "thispackagedir=${thispackagedir}"
         [[ -n "${thispackagedir}" ]] && eval thispackagedir="${thispackagedir}"
         case "${thisflavor}" in
            redhat|centos) # needs special attention to get architecture
               sourcefile=$( { find "${inputpackagedir}" -regex ".*${packagename}-${packageversion}.*" -regex ".*.rpm"; find "${inputlocation}" -regex ".*${packagename}-${packageversion}.*" -regex ".*.rpm";} 2>/dev/null | head -n1 )
               ;;
            debian|ubuntu)
               sourcefile=$( { find "${inputpackagedir}" -regex ".*${packagename}-${packageversion}.*" -regex ".*.deb"; find "${inputlocation}" -regex ".*${packagename}-${packageversion}.*" -regex ".*.deb";} 2>/dev/null | head -n1 )
               ;;
            *) # including tarball, tar
               sourcefile=$( { find "${inputpackagedir}" -regex ".*${packagename}-${packageversion}.*" -regex ".*.master.tgz"; find "${inputlocation}" -regex ".*${packagename}-${packageversion}.*" -regex ".*.master.tgz"; } 2>/dev/null | head -n1 )
               ;;
         esac

         # DERIVE TARBALL FILE
         sourcetarfile=$( { find "${inputpackagedir}" -regex ".*${packagename}-${packageversion}.*" -regex ".*.master.tgz"; find "${inputlocation}" -regex ".*${packagename}-${packageversion}.*" -regex ".*.master.tgz"; } 2>/dev/null | head -n1 )
         debuglev 5 && ferror "sourcefile=${sourcefile}"
         debuglev 5 && ferror "sourcetarfile=${sourcetarfile}"

         # CALCULATE DESTINATION FILE
         destinationdir="$( { test -d "$( readlink -f "$( find "${thispackagedir}" -maxdepth 0 \( -type d -o -type l \) )" )" && echo "${thispackagedir}"; find "${thislocation}" -maxdepth 0 -type d; } 2>/dev/null | grep -viE "^$" | head -n1 )"
         #debuglev 5 && ferror "destinationdir=${destinationdir}"
         [[ ! -d "${destinationdir}" ]] && ferror "Skipped ${thiszone} file ${sourcefile}: cannot be copied to invalid directory \"${destinationdir}\"." && continue
         destinationfile=$( echo "${destinationdir}/$( basename "${sourcefile}" )" | sed -e 's!\/\+!\/!g;' )
         debuglev 5 && ferror "destinationfile=${destinationfile}"

         # PERFORM FILE COPY
         if [[ ! -f "${sourcefile}" ]];
         then
            ferror "Skipped ${thiszone} source for ${thispackage}: not found."
         else
            fileaction copy "${sourcefile}" "${destinationfile}"
            thiszoneused=1
         fi

         # IF ZONELINK
         eval thislink=\${${thiszone}link}
         case "${thislink}" in
            "1"|"y"|"yes"|"Y"|"YES")
               # have already derived tarball file
               if [[ ! -f "${sourcetarfile}" ]];
               then
                  # link was yes, but tarball does not exist, so soft error.
                  ferror "Skipped ${thiszone} symlink for ${sourcetarfile}: not found."
               else
                  # CALCULATE DESTINATION TARBALL FILE
                  destinationtarfile="$( echo "${destinationdir}/$( basename "${sourcetarfile}" )" | sed -e 's!\/\+!\/!g;' )"

                  # PERFORM TARBALL SYMLINK
                  fileaction symlink "${sourcetarfile}" "${destinationtarfile}"
               fi
               ;;
            *) # no
               [ ]
               ;;
         esac

         # IF ZONE WAS UPDATED
         eval thisupdatescript=\${${thiszone}updatescript}
         if [[ thiszoneused -ne 0 ]];
         then
            if test "${noupdate}" = "1";
            then
               # told to not execute any update scripts at all.
               debuglev 1 && ferror "Skipping any execute scripts for ${thiszone}."
            else
               [[ -n "${thisupdatescript}" ]] && {
                  if [[ ! -x "${thisupdatescript}" ]];
                  then
                     ferror "Cannot execute the updatescript ${thisupdatescript}. Skipped."
                  else
                     # is executable 
                     debuglev 2 && ferror "Execute ${thisupdatescript}"
                     ! debuglev 4 && ${thisupdatescript}
                  fi
               }
            fi
         fi
        
      } # end if-not-input-zone
   done
#} | tee -a $logfile

# EMAIL LOGFILE
#$sendsh $sendopts "$server $scriptfile out" $logfile $interestedparties
