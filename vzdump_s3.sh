#!/bin/bash
#=======================================================================
#
#          FILE:  vzdump_s3.sh
#
#         USAGE:  bash vzdump_s3.sh
#
#   DESCRIPTION:  vzdump_s3 is a bash script that handles your 
#		  OpenVZ backup and sync it with Amazon S3
#
#       OPTIONS:  See configuration tag
#  REQUIREMENTS:  s3cmd, vzdump
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Marc Juchli
#       COMPANY:  Codag GmbH
#       VERSION:  1.0
#       CREATED:  25/08/12 17:46:08 CEST
#      REVISION:  ---
#=======================================================================

#-----------------------------------------------------------------------
# CONFIGURATION
#-----------------------------------------------------------------------
SERVER="102" #USE EITHER SERVER "VID" OR "--all"

BACKUP_NAME="daily" #NAME OF THE BACKUP JOB
BACKUP_COUNT=5 #NUMBER OF BACKUPS TO KEEP
BACKUP_ROOT="/home/backup/vz/" #BACKUP DIRECTORY (USE "/" IN THE END)

BUCKET_NAME=`hostname` #S3 BUCKET NAME

#-----------------------------------------------------------------------
# MAKE A DIRECTORY STRUCTURE
#-----------------------------------------------------------------------
if [ "$SERVER" = "--all" ]; then
	BACKUP_FOLDER=$BACKUP_ROOT$BACKUP_NAME
else
	BACKUP_FOLDER=$BACKUP_ROOT$SERVER/$BACKUP_NAME
fi

#-----------------------------------------------------------------------
# CREATE BACKUP FOLDER IF NOT EXISTS AND cd
#-----------------------------------------------------------------------
mkdir -p $BACKUP_FOLDER
cd $BACKUP_FOLDER/

#-----------------------------------------------------------------------
# MAKE VZDUMP IN VID RELATED FOLDER OR GLOBAL FOLDER FOR --all
#-----------------------------------------------------------------------
vzdump --suspend --dumpdir $BACKUP_FOLDER $SERVER

#-----------------------------------------------------------------------
# CHECK IF BUCKET ALREADY EXISTS
#-----------------------------------------------------------------------
BUCKET_LIST=`s3cmd ls | awk -v FS=" " '{print $3}' | awk -v FS="//" '{print $2}'`
NEW_BUCKET=1
for f in $BUCKET_LIST; do 
	if [ "$f" = "$BUCKET_NAME" ]; then
		NEW_BUCKET=0
		break
	fi 
done

#-----------------------------------------------------------------------
# CREATE BUCKET IF NOT EXISTS
#-----------------------------------------------------------------------
if [ "$NEW_BUCKET" = 1 ]; then
	 s3cmd mb s3://$BUCKET_NAME
fi

#-----------------------------------------------------------------------
# KEEP LATEST FILES, DELETE OLD FILES (BACKUP_COUNT)
#-----------------------------------------------------------------------
FILES_KEEP=$((BACKUP_COUNT*2)) #EVERY VZDUMP HAS A LOG FILE
if [ `ls -1 | wc -l` -gt $FILES_KEEP ]; then
	(ls -t|head -n $FILES_KEEP;ls)|sort|uniq -u|xargs rm
fi

#-----------------------------------------------------------------------
# INSTEAD OF USE --compress IN VZDUMP WE MAKE bzip2 NOW SAVING ABOUT 10%
#-----------------------------------------------------------------------
bzip2 *.tar

#-----------------------------------------------------------------------
# AT LAST SYNC WITH S3 BUCKET
#-----------------------------------------------------------------------
s3cmd sync --skip-existing $BACKUP_ROOT s3://$BUCKET_NAME
