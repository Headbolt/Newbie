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
#     A Pair of JAMF policies are required to accompany this script.
#       Policy 1 Is needed to reset the JAMF Management account password to something known
#       Policy 2 Is needed to reset the JAMF Management account password to an unknown complex password
#       Each policy needs its own specific custom trigger, that will be required in this script.
#
###############################################################################################################################################
#
# HISTORY
#
#	Version: 1.2 - 21/06/2022
#
#   - 15/04/2018 - V1.0 - Created by Headbolt
#
#   - 21/10/2019 - V1.1 - Updated by Headbolt
#							More comprehensive error checking and notation
#
#   - 21/06/2022 - V1.2 - Updated by Headbolt
#							Minor Tidying
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
#
MANAGEMENT="MANAGE" # Set the name of your usual JAMF Management Account Name eg. MANAGE
ZTI="Enrollment" # Set the name of your usual Default Zero Touch Build Account eg. Enrollment
FVadd="VAULT" # Set the name of your usual Default Filevault Admin eg. VAULT
#
NonCOMP="JAMF-NonComplex" # Set the Trigger Name of your Policy to set the JAMF Management Account
# to a Known Password incase it is used for the Admin User from Variable #8 eg. JAMF-NonComplex
#
COMP="JAMF-Complex" # Set the Trigger Name of your Policy to set the JAMF Management Account to an
# unknown complex Password incase it is used for the Admin User from Variable #9 eg. JAMF-Complex
#
os_ver=$(sw_vers -productVersion) # Grab the OS Version
IFS='.' read -r -a ver <<< "$os_ver" # Process the OS Version
fdestatus=$(sudo fdesetup status | grep "FileVault is" | awk '{print $3}' | tr -d .) # Check if FileVault is on or Not
#
ScriptName="append prefix here as needed - FV2 - Create Local Account" # Set the name of the script for later logging
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
# Initial Check Function
#
Check(){
#
# Function to grab information about all relevant accounts and display them for Reporting
#
if [[ "${ver[1]}" -ge 13 ]]
	then
		AdminCreds="-adminUser $adminUser -adminPassword $adminPass"
		/bin/echo "Processing, incorporating Secure Token as OS Version is $os_ver"
		/bin/echo # Outputs a blank line for reporting purposes
		/bin/echo "Grabbing Secure Token Status for $MANAGEMENT Account"
		JAMFstatus=$(sysadminctl -secureTokenStatus jamf 2>&1)
		JAMFtoken=$(echo $JAMFstatus | awk '{print $7}')
		/bin/echo "JAMF secureTokenStatus = $JAMFtoken"
		/bin/echo # Outputs a blank line for reporting purposes
		#
        if [ "${FVadd}" != "${User}" ]
			then
				/bin/echo "Grabbing Secure Token Status for $FVadd Account"
				#
				FVaddStatus=$(sysadminctl -secureTokenStatus $FVadd 2>&1)
				FVaddToken=$(echo $CRYPTOstatus | awk '{print $7}')
				#
				/bin/echo "$FVadd secureTokenStatus = $FVaddToken"
				/bin/echo # Outputs a blank line for reporting purposes
		fi
		# 
		/bin/echo "Grabbing Secure Token Status for $User Account"
		#
		NewUserStatus=$(sysadminctl -secureTokenStatus $User 2>&1)
		NewUserToken=$(echo $NewUserStatus | awk '{print $7}')
		#
		/bin/echo "$User secureTokenStatus = $NewUserToken"
		SectionEnd
		#
		if [ "${adminUser}" != "${ZTI}" ]
			then
				if [ "${adminUser}" == "${MANAGEMENT}" ]
					then
						FileSystem=$(diskutil info / | grep "File System Personality" | cut -c 30-)
						#
						if [ ${FileSystem} = "APFS" ]
							then
								#
								if [ $JAMFtoken != "ENABLED" ]
									then
										/bin/echo "Management Account Has No Secure Token"
										/bin/echo "Cannot Continue"
										SectionEnd
										ScriptEnd
										#
										exit 1
								else
									/bin/echo "File System is not APFS"
									/bin/echo "Ignoring Tokens"
									/bin/echo # Outputs a blank line for reporting purposes
								fi
						fi
				fi
				#
				if [ "${adminUser}" == "${FVadd}" ]
					then
						if [ $FVaddToken != "ENABLED" ]
							then
								/bin/echo "$FVadd Account Has No Secure Token"
								/bin/echo "Cannot Continue"
								#
								SectionEnd
								ScriptEnd
								#                
								exit 1
						fi
				fi
		fi
fi  
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
#/bin/echo # Outputting a Blank Line for Reporting Purposes
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
Check
#                
if [[ "${ver[1]}" -lt 13 ]]
	then
		#
		AdminCreds=""
		/bin/echo # Outputs a blank line for reporting purposes
		/bin/echo "Processing without incorporating Secure Token as OS Version is $os_ver"
		SectionEnd
fi
#
if [ "${adminUser}" == "${MANAGEMENT}" ]
	then
		#
		/bin/echo "Triggering Policy to set JAMF Management to a known non-complex Password"
		/bin/echo # Outputs a blank line for reporting purposes
		sudo /usr/local/bin/jamf policy -trigger $NonCOMP
		SectionEnd
fi
#    
/bin/echo "Creating $User Account"
/bin/echo "with the options $Options"
/bin/echo # Outputs a blank line for reporting purposes
sudo sysadminctl "$AdminCreds" -addUser "$User" -fullName "$User" -password "$Pass" "$Options"
#
SectionEnd
#
if [[ "${ver[1]}" -ge 13 ]]
	then
		/bin/echo "Re-Checking Secure Token Status for $User Account"
		NewUserStatus=$(sysadminctl -secureTokenStatus $User 2>&1)
		NewUserToken=$(echo $NewUserStatus | awk '{print $7}')
		#
		/bin/echo "$User secureTokenStatus = $NewUserToken"
		SectionEnd
fi
#
if [ "${FV2}" == "YES" ]
	then
		if [ "${fdestatus}" == "On" ]
			then
				if [[ "${ver[1]}" -lt 13 ]]
					then
						/bin/echo # Outputs a blank line for reporting purposes
						/bin/echo "Adding $User to FV2"
						/bin/echo '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>Username</key><string>'$adminUser'</string><key>Password</key><string>'$adminPass'</string><key>AdditionalUsers</key><array><dict><key>Username</key><string>'$User'</string><key>Password</key><string>'$Pass'</string></dict></array></dict></plist>' | fdesetup add -inputplist
						#
						/bin/echo # Outputs a blank line for reporting purposes
						/bin/echo "Checking Filevault Status of User $User"
						/bin/echo # Outputs a blank line for reporting purposes
						#
						if [ "$(fdesetup list | grep -ic "^${User},")" -eq '0' ]
							then
								/bin/echo "User $User is not FileVault Enabled"
							else
								/bin/echo "User $User is FileVault Enabled"
						fi
						SectionEnd
				fi
			else
				/bin/echo "Option to Enable User $User for FileVault Is Selected"
				/bin/echo "but FileVault is not Enabled"
				SectionEnd
		fi
fi
#	
if [ "${adminUser}" == "${MANAGEMENT}" ] # TEST
	then
		#
		/bin/echo "Triggering Policy to reset $MANAGEMENT account to an unknown complex Password"
		/bin/echo # Outputs a blank line for reporting purposes
		sudo /usr/local/bin/jamf policy -trigger $COMP
		SectionEnd
fi
#
if [ "${FV2}" == "YES" ]
	then
		if [ "${fdestatus}" == "On" ]
			then
				if [[ "${ver[1]}" -ge 13 ]]
					then
						/bin/echo # Outputs a blank line for reporting purposes
						echo "Re-Checking Secure Token Status for $FVadd Account"
						FVaddStatus=$(sysadminctl -secureTokenStatus $FVadd 2>&1)
						FVaddToken=$(echo $FVaddStatus | awk '{print $7}')
						/bin/echo # Outputs a blank line for reporting purposes
						/bin/echo "JAMF secureTokenStatus = $FVaddToken"
						/bin/echo # Outputs a blank line for reporting purposes
						/bin/echo "Re-Checking Secure Token Status for $FVadd Account"
						#
						FVaddStatus=$(sysadminctl -secureTokenStatus $FVadd 2>&1)
						FVaddToken=$(echo $FVaddStatus | awk '{print $7}')
						#
						/bin/echo # Outputs a blank line for reporting purposes
						/bin/echo "$FVadd secureTokenStatus = $FVaddToken"
						SectionEnd
				fi
		fi
fi
#
ScriptEnd
