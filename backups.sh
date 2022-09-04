#!/bin/bash
# BASIC BACKUP UTILITY
#
# Author: Wadih K.
# This script was made to simplify the task of using
# rsync for backups and saving space using snapshots.

RSYNC="/usr/bin/rsync"
DPOINT="/backups"
CONF="/etc/backups.conf"
LOGGER="logger -i -t backup.sh"
RSYNC_USER="root"

# Number of snapshots to retain
SNAPSHOTS=7

###############################################
# Checking for all prerequisites 

# Check Conf file
if [ ! -f $CONF ]
	then
		printf "Conf file not found [$CONF]\n"
		$LOGGER "Conf file not found [$CONF]"
		exit 0
fi

# Check Backup directory
if [ -d $DPOINT.0 ]
	then
		printf "Initial backup directory found [$DPOINT.0]\n"
		$LOGGER "Initial backup directory found [$DPOINT.0]"
	else
		printf "Initial backup directory not found [creating]\n";
		$LOGGER "Initial backup directory not found [creating]";
		mkdir $DPOINT.0
fi

###############################################
# Start snapshot creation
printf "Starting snapshot creation...\n"
$LOGGER "Starting snapshot creation..."
if [ -d $DPOINT.$SNAPSHOTS ]
	then
		rm -rf $DPOINT.$SNAPSHOTS
fi

while [ $SNAPSHOTS -gt 0 ]
	do
		next=`expr $SNAPSHOTS - 1`
		if [ -d $DPOINT.$next ]
			then
				printf "Snapping $DPOINT.$next --> $DPOINT.$SNAPSHOTS\n"
				$LOGGER "Snapping $DPOINT.$next --> $DPOINT.$SNAPSHOTS"
				if [ $next -eq 0 ]
					then
						cp -al $DPOINT.$next $DPOINT.$SNAPSHOTS
					else
						mv $DPOINT.$next $DPOINT.$SNAPSHOTS
				fi	
		fi
		SNAPSHOTS=$next
	done		

###############################################
# Start full backup
printf "Starting full backup...\n"
$LOGGER "Starting full backup..."
for cline in `cat $CONF | grep -v ^#`
	do
		BHOST=`echo $cline | awk -F "|" '{print$1}'`
		DIRS=`echo $cline | awk -F "|" '{print$2}' | sed 's/\,/ /g'`
		if [ ! -e "$DPOINT.0/$BHOST" ]
			then
				printf "$DPOINT.0/$BHOST does not exist [creating]\n"
				$LOGER "$DPOINT.0/$BHOST does not exist [creating]"
				mkdir $DPOINT.0/$BHOST
		fi

		printf "Backing up $BHOST...\n"
		$LOGGER "Backing up $BHOST..."
		for cdir in $DIRS
			do
				RDIR=`echo $cdir | sed 's/\!.*$//'`

				if [[ "${cdir}" =~ \(!\) ]]
					then
						cln=`echo $cdir | awk -F $RDIR '{print$2}'`
						EX=`echo $cln | sed 's/\!/ --exclude=/g'`
						cdir=$RDIR
					else
						EX=""
				fi

				printf "\tSyncing [$cdir]\n";
				$RSYNC -aqRS --partial $RSYNC_USER@$BHOST:"$cdir" $DPOINT.0/$BHOST/ --delete $EX
				if [ $? != 0 ]
					then
						printf "Rsync failed [$BHOST:$cdir]\n";
						$LOGGER "Rsync failed [$BHOST:$cdir]";
					else
						printf "Rsync complete [$BHOST:$cdir]\n";
						$LOGGER "Rsync complete [$BHOST:$cdir]";
				fi
		done
	done
	
ftime=`date`
printf "\nBackup has completed. [$ftime]\n"
$LOGGER "Backup completed"

exit 0
