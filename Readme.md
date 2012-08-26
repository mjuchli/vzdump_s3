#vzdump_s3

##Description
vzdump_s3 is a bash script that handles your OpenVZ backup and sync it with Amazon S3. 

##Requirements

###Amazon S3
As a storage location we use in this script Amazon S3. In this case is an AWS Accound required to use this.

Find more informations about Amazon S3 [here](http://aws.amazon.com/de/s3/)

###OpenVZ
OpenVZ is the base of the idea behind this script. Find more informations about OpenVZ [here](http://wiki.openvz.org/Main_Page)

How to install OpenVZ and OpenVZ Web Panel take a look [here](http://www.howtoforge.com/virtual-multiserver-environment-with-dedicated-web-mysql-email-dns-servers-on-debian-squeeze-with-ispconfig-3)

###S3cmd
To be able save your backup on S3, this script needs s3cmd installed.

More informations [here](http://s3tools.org/s3cmd)

##Functionality

- Backup OpenVZ VM
- Directory handling
- Bzip2 compressing (optional)
- Handle number of backups
- Create Amazon S3 bucket
- Sync S3 bucket with backup folder

##Configuration
This is a short explanation of parameters you can configure inside the script.

####SERVER
Define which container you want to backup. Use either server "VID" or "--all". "VID" is absolutely recommended!

	SERVER="101"
	
Leave it blank if you execute script with parameter $1 (see usage below)

	SERVER=""

####BACKUP_NAME
Simply give your backup job a name. This will creates a folder as well.

	BACKUP_NAME="daily"

####BACKUP_COUNT
Set the number of backups you'd like to keep. For example if you make backup every day (cron) and define BACKUP_COUNT to 7 then you'll have backup for a week back. Older backups will be **deleted**!

	BACKUP_COUNT=7

####BACKUP_ROOT
This is the root of your backup location (local)

	BACKUP_ROOT="/home/backup/vz/" #BACKUP DIRECTORY (USE "/" IN THE END)

####BACKUP_PARAMETER
Here you can set "vzdump" specific parameter. **Expect of dumpdir!**
	
	BACKUP_PARAMETER="--suspend --compress --bwlimit 51200"

####BACKUP_BZIP2
If you want, you can set BACKUP_BZIP to 1 instead of using --compress in BACKUP_PARAMTER. Now your backup will be a tar.gzip2 instead of tar.gzip which saves about 10%. **Note that backup process will take longer now!**

	BACKUP_BZIP2=0

####BUCKET_NAME
Set the Amazon S3 Bucket name you want to save your backup in. If this bucket doesn't exist it'll be created. I always use my hostname!

	BUCKET_NAME=`hostname`


##Usage
Execute bash script (with container ID as parameter as an option)

	bash vzdump_s3.sh VID
	
	