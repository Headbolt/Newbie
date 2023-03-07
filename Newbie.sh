#!/bin/bash
#
###############################################################################################################################################
#
# ABOUT THIS PROGRAM
#
#	Newbie.sh
#	https://github.com/Headbolt/Newbie
#
#   This Script is designed for use in JAMF
#
#   - This script will ...
#			Create an account, with a Secure Token
#
###############################################################################################################################################
#
# HISTORY
#
#	Version: 1.3 - 07/03/2023
#
#	15/04/2018 - V1.0 - Created by Headbolt
#
#	21/10/2019 - V1.1 - Updated by Headbolt
#				More comprehensive error checking and notation
#					
#	21/06/2022 - V1.2 - Updated by Headbolt
#				Minor Tidying
#
#	07/03/2023 - V1.3 - Updated by Headbolt
#				Major Tidying to remove a lot of lines no longer required for more recent MacOS releases
#				Introduction of Bootstrap token has made a lot of this far far simpler
#
###############################################################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
###############################################################################################################################################
#
User="${4}" # Grab the username for the user we want to create from JAMF variable #4 eg. username
Pass="${5}" # Grab the password for the user we want to create from JAMF variable #5 eg. password
FV2="${6}" # Grab the option of whether to enable this user for FileVault from JAMF variable #6 eg. YES / NO
Options="${7}" # Grab the options to set for this user from JAMF variable #7 eg. -UID 81 -admin -shell /usr/bin/false -home /private/var/VAULT
adminUser="${8}" # Grab the username for the admin user we will use to change the password from JAMF variable #8 eg. username
adminPass="${9}" # Grab the password for the admin user we will use to change the password from JAMF variable #9 eg. password
AdminCreds="-adminUser $adminUser -adminPassword $adminPass" # Construct the Admin creds into 1 simple to use variable
#
ScriptName="MacOS | Create Local Account" # Set the name of the script for later logging
#
####################################################################################################
#
#   Checking and Setting Variables Complete
#
###############################################################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
###############################################################################################################################################
#
# Defining Functions
#
###############################################################################################################################################
#
# Debug Function
#
Debug(){
#
SectionEnd
/bin/echo 'Debug Mode'
/bin/echo # Outputting a Blank Line for Reporting Purposes
/bin/echo 'Command being run is "'$SysAdminCommand'"'
#
}
#
###############################################################################################################################################
#
# Section End Function
#
SectionEnd(){
#
/bin/echo # Outputting a Blank Line for Reporting Purposes
/bin/echo  ----------------------------------------------- # Outputting a Dotted Line for Reporting Purposes
/bin/echo # Outputting a Blank Line for Reporting Purposes
#
}
#
###############################################################################################################################################
#
# Script End Function
#
ScriptEnd(){
/bin/echo Ending Script '"'$ScriptName'"'
/bin/echo # Outputting a Blank Line for Reporting Purposes
/bin/echo  ----------------------------------------------- # Outputting a Dotted Line for Reporting Purposes
/bin/echo # Outputting a Blank Line for Reporting Purposes
#
}
#
###############################################################################################################################################
#
# End Of Function Definition
#
###############################################################################################################################################
# 
# Begin Processing
#
####################################################################################################
#
/bin/echo # Outputs a blank line for reporting purposes
SectionEnd
#
/bin/echo 'Creating User "'$User'"'
/bin/echo "with the options $Options"
/bin/echo # Outputs a blank line for reporting purposes
#
# Construct Final command to be run
SysAdminCommand="sysadminctl "$AdminCreds" -addUser "$User" -fullName "$User" "${Options}" -password "$Pass""
$SysAdminCommand # Run Command
#
# Debug # Debug Function used to check what command gets run in the logs incase of issues.
#
SectionEnd
/bin/echo "Checking Secure Token Status for $User Account"
NewUserStatus=$(sysadminctl -secureTokenStatus $User 2>&1)
NewUserToken=$(echo $NewUserStatus | awk '{print $7}')
/bin/echo '"'$User'" secureTokenStatus = '$NewUserToken''
#
SectionEnd
ScriptEnd
