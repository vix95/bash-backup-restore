#!/bin/bash

# default settings
NAME="name"
FULL_INTERVAL=30  # sec
INC_INTERVAL=5  # sec
PATH_TO_BACKUP="/home/vix/backup/to_backup"
BACKUP_DIR="/home/vix/backup/backup-dir"
TYPE="tar"
MAX_INTERVAL=0
INC_DAYS=2  # days
EXT_ARR=""
DATE=0
IS_RESTORE=false
IS_BACKUP=false
OUT_DIR="/home/vix/backup/out-dir"
FAIL_COUNT=0
BREAK_TIME=999999  # sec
CRON_ON=false

# colors
NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'

# functions
printDate()
{
	echo -n -e "${BLUE}["$(date +%Y-%m-%d%t%H:%M:%S)"] ${NC}"
}

setName()
{
	val=$(echo $arg | awk -F= '{print $NF}')
	NAME=$val
	printDate ; echo "set NAME: $NAME"
}

setFullInterval()
{
	val=$(echo $arg | awk -F= '{print $NF}')
	FULL_INTERVAL=$val
	printDate ; echo "set FULL INTERVAL: $FULL_INTERVAL"
}

setIncInterval()
{
	val=$(echo $arg | awk -F= '{print $NF}')
	INC_INTERVAL=$val
	printDate ; echo "set INCREMENTAL INTERVAL: $INC_INTERVAL"
}

setPath()
{
	val=$(echo $arg | awk -F= '{print $NF}')
	PATH_TO_BACKUP=$val
	printDate ; echo "set PATH: $PATH_TO_BACKUP"
}

setType()
{
	TYPE="gzip"
}

setFileTypes ()
{
	val=$(echo $arg | awk -F= '{print $NF}')
	arr=$(echo $val | tr "," "\n")

	i=0
	for x in $arr ; do
		if [ $i -eq 0 ] ; then
			EXT_ARR="$x\\"
		else
    		EXT_ARR="$EXT_ARR|$x\\"
		fi
		i=$(($i + 1))
	done
}

setBackupDir()
{
	val=$(echo $arg | awk -F= '{print $NF}')
	BACKUP_DIR=$val
	printDate ; echo "set BACKUP DIR: $BACKUP_DIR"
}

setDate()
{
	val=$(echo $arg | awk -F= '{print $NF}')
	pickdate="${val//[^0-9]/}"
	DATE=$pickdate
	printDate ; echo "set DATE: $DATE"
}

setOutDir()
{
	val=$(echo $arg | awk -F= '{print $NF}')
	OUT_DIR=$val
	printDate ; echo "set BACKUP DIR: $OUT_DIR"
}

setIncDays()
{
	val=$(echo $arg | awk -F= '{print $NF}')
	INC_DAYS=$val
	printDate ; echo "set INC DAYS: $INC_DAYS"
}

setBreakTime()
{
	val=$(echo $arg | awk -F= '{print $NF}')
	BREAK_TIME=$val
	printDate ; echo "set BREAK TIME: $BREAK_TIME"
}

printHelp()
{
	printf " Syntax: backup.sh [Type]... [Option]... [Name]...\n"
	printf "\n Key:\n"
	printf "\t --name='prefix backup name'\n"
	printf "\t --full-interval='time between full backups'\n"
	printf "\t --inc-interval='time between increment backups'\n"
	printf "\t --path='path to the directory from which the files will be backed up'\n"
	printf "\t --gzip='backup by gzip'\n"
	printf "\t --ext='list of file extensions; files from a given directory that have the given extension will be backed up'\n"
	printf "\t --backup-dir='a directory where backup files will be stored; location of the backup file'\n"
	printf "\t -h lub --help print help\n"
	printf "\t -v lub --version print version and author\n"
	printf "\t --date='the time for which to restore the backup (or the nearest one in the past containing the backup); date format: year_month_day_hour_minute'\n"
	printf "\t --out-dir='directory to which to restore the backup'\n"
	printf "\t --backup creates a backup\n"
	printf "\t --restore restore a backup\n"
	printf "\t --inc-days='max number of modification days'\n"
	printf "\t --break-time='the time after which the script should end'\n"
	printf "\t --show-settings print settings\n"
}

printVersion()
{
	printf "\n **************************************\n"
	printf " *                                    *\n"
	printf " *                                    *\n"
	printf " *      Full/Incremental Backup       *\n"
	printf " *                                    *\n"
	printf " *                                    *\n"
	printf " **************************************\n"
	printf " Description: Manually or auto full/incremental backup. Type -h/--help for more details."
	printf " Version: 1.0.0\n Author: Pawel Labuda\n Github: vix95\n"
	printf "_____________________________________________\n\n"
}

createDir()
{
	if [ ! -e $BACKUP_DIR ] ; then 
		mkdir -p $BACKUP_DIR
	fi
}

createOutDir()
{
	if [ ! -e $OUT_DIR ] ; then 
		mkdir -p $OUT_DIR
	fi
}

sendAlert()
{
	if [ $? = 0 ] ; then
		printf "\n" ; printDate ; printf "${GREEN}Success $1 backup!\n${NC}\tBackup has been created\n\t[$PATH_TO_BACKUP -> $BACKUP_DIR]\n" 
		printf "\t[$2]\n"
	else
		printf "\n" ; printDate ; printf "${RED}Error! Backup has not been done!\n${NC}"
		FAIL_COUNT=$(($FAIL_COUNT + 1))
	fi
}

doFullBackup()
{
	DATE=$(date +%Y_%m_%d_%H_%M)
	printDate ; echo -e "${YELLOW}Full backup in progress...${NC}" ; printf "\n"
	
	if [ "$TYPE" = "tar" ] ; then
		if [ "$EXT_ARR" = "" ] ; then
			tar -P -cpvf $BACKUP_DIR/$NAME"_full_"$DATE.tar $PATH_TO_BACKUP
		else
			find $PATH_TO_BACKUP -type f -regex ".*/.*\.\($EXT_ARR)" | xargs tar -P -cpvf $BACKUP_DIR/$NAME"_full_"$DATE.tar
			#find . -type f \( -name \*\.php -o -name \*\.js -o -name \*\.css -o -name \*\.inc \)
			#find -type f -regex ".*/.*\.\(js\|php\)"
		fi
	elif [ "$TYPE" = "gzip" ] ; then
		if [ "$EXT_ARR" = "" ] ; then
			tar -P -zcpvf $BACKUP_DIR/$NAME"_full_"$DATE.tgz $PATH_TO_BACKUP
		else
			find $PATH_TO_BACKUP -type f -regex ".*/.*\.\($EXT_ARR)" | xargs tar -P -zcpvf $BACKUP_DIR/$NAME"_full_"$DATE.tgz
		fi
	fi

	sendAlert "full" $NAME"_full_"$DATE
}

doIncBackup()
{
	DATE=$(date +%Y_%m_%d_%H_%M)
	printDate ; echo -e "${YELLOW}Incremental backup max from $INC_DAYS days in progress...${NC}" ; printf "\n"

	if [ "$TYPE" = "tar" ] ; then
		if [ "$EXT_ARR" = "" ] ; then
			tar -cp -v --newer-mtime "$INC_DAYS days ago" -P -f $BACKUP_DIR/$NAME"_incr_"$DATE.tar $PATH_TO_BACKUP
		else
			find $PATH_TO_BACKUP -type f -regex ".*/.*\.\($EXT_ARR)" | xargs tar -cp -v --newer-mtime "$INC_DAYS days ago" -P -f $BACKUP_DIR/$NAME"_incr_"$DATE.tar
		fi
	elif [ "$TYPE" = "gzip" ] ; then
		if [ "$EXT_ARR" = "" ] ; then
			tar -zcp -v --newer-mtime "$INC_DAYS days ago" -P -f $BACKUP_DIR/$NAME"_incr_"$DATE.tgz $PATH_TO_BACKUP
		else
			find $PATH_TO_BACKUP -type f -regex ".*/.*\.\($EXT_ARR)" | xargs tar -zcp -v --newer-mtime "$INC_DAYS days ago" -P -f $BACKUP_DIR/$NAME"_incr_"$DATE.tgz
		fi
	fi

	sendAlert "incremental" $NAME"_incr_"$DATE
}

doRestore()
{
	if [ $DATE -eq 0 ] ; then
		DATE=$(date +%Y%m%d%H%M)
	fi

	LATEST=9999999999
	RESTORE_FILE=""
	
	printf "\nList of backups:\n"
	for file in $BACKUP_DIR/* ; do
		echo "$(basename "$file")"
		arr=$(echo "$(basename "$file")" | tr "_" "\n")
		arr=$(echo "$arr" | tr "." "\n")

		pickdate="${arr//[^0-9]/}"
		
		TARGET=$pickdate
		#TARGET=$(date -d "${pickdate:0:8} ${pickdate:8:2}:${pickdate:10:2}" +%Y%m%d%H%M)
		MINUTES=$(( ($DATE - $pickdate) ))
		
		if [[ $file == *$NAME* ]] ; then
			if [ $MINUTES -eq 0 ] ; then
				LATEST=$MINUTES
				RESTORE_FILE=$file
				break
			elif [ $MINUTES -lt $LATEST ] ; then 
				LATEST=$MINUTES
				RESTORE_FILE=$file
			fi
		fi

		if [ $LATEST -lt 0 ] ; then
			break
		fi
	done
	
	if [ "$RESTORE_FILE" = "" ] ; then
		printf "\n" ; printDate ; printf "${RED}Not found backup with pattern\n${NC}"
	else
		printf "\n" ; printDate ; printf "${YELLOW}Restore in process...\n${NC}" ; printf "\n${GREEN}Restored:\n${NC}"
		createOutDir
		tar -C $OUT_DIR -xvf $RESTORE_FILE
		printf "\n" ; printDate ; printf "${GREEN}Successfully restored ${NC}\n[$RESTORE_FILE] -> [$OUT_DIR]\n"
	fi
}

setMaxInt()
{
	if [ FULL_INTERVAL -gt INC_INTERVAL ] ; then
		MAX_INTERVAL=FULL_INTERVAL
	else
		MAX_INTERVAL=INC_INTERVAL
	fi
}

showSettings()
{
	printf "\t${YELLOW}Settings:${NC}\n"
	printf "\t${YELLOW}NAME: ${NC}${NAME}\n"
	printf "\t${YELLOW}FULL_INTERVAL: ${NC}${FULL_INTERVAL}\n"
	printf "\t${YELLOW}INC_INTERVAL: ${NC}${INC_INTERVAL}\n"
	printf "\t${YELLOW}PATH_TO_BACKUP: ${NC}${PATH_TO_BACKUP}\n"
	printf "\t${YELLOW}BACKUP_DIR: ${NC}${BACKUP_DIR}\n"
	printf "\t${YELLOW}TYPE: ${NC}${TYPE}\n"
	printf "\t${YELLOW}MAX_INTERVAL: ${NC}${MAX_INTERVAL}\n"
	printf "\t${YELLOW}INC_DAYS: ${NC}${INC_DAYS}\n"
	printf "\t${YELLOW}EXT_ARR: ${NC}${EXT_ARR}\n"
	printf "\t${YELLOW}IS_RESTORE: ${NC}${IS_RESTORE}\n"
	printf "\t${YELLOW}IS_BACKUP: ${NC}${IS_BACKUP}\n"
	printf "\t${YELLOW}OUT_DIR: ${NC}${OUT_DIR}\n"
	printf "\t${YELLOW}BREAK_TIME: ${NC}${BREAK_TIME}\n"
}

# script heart
# check all args
if [ ! $# -eq 0 ] ; then
	for arg in $@ ; do
	   	case "$arg" in 
			--name*) setName $arg ;;
			-h|--help) printHelp ;;
			-v|--version) printVersion ;;
			--full-interval*) setFullInterval ;;
			--inc-interval*) setIncInterval ;;
			--path*) setPath ;;
			--gzip) setType ;;
			--ext*) setFileTypes ;;
			--backup-dir*) setBackupDir ;;
			--restore) IS_RESTORE=true ;;
			--date*) setDate ;;
			--out-dir*) setOutDir ;;
			--backup) IS_BACKUP=true ;;
			--inc-days*) setIncDays ;;
			--break-time*) setBreakTime ;;
			--show-settings) showSettings ;;
			--cron) CRON_ON=true ;;
			*) echo "Bad argument, check -h/--help" ;;
		esac
	done
else
	echo "Type arguments..."
fi

if [ $IS_RESTORE = true ] ; then
	doRestore
fi

if [ $IS_BACKUP = true ] ; then
	if [ $# -eq 1 ] ; then
		printDate ; echo "Running backup in default settings"
	fi

	if [ $CRON_ON = true ] ; then
		createDir
		doFullBackup
		doIncBackup
	else
		# like as cron
		times=1
		while true ; do
			if [ $(($times % FULL_INTERVAL)) -eq 0 ] ; then
				createDir
				doFullBackup
			fi

			if [ $(($times % INC_INTERVAL)) -eq 0 ] ; then
				createDir
				doIncBackup
			fi

			sleep 1
			times=$(($times + 1))

			#if [ $times -eq $MAX_INTERVAL ] ; then
			#	times=0
			#fi

			if [ $FAIL_COUNT -eq 5 ] ; then
				printf "\n" ; printDate ; echo -e "${RED}Backup has aborder, too many backup FAILS${NC}"
				break
			fi

			if [ $BREAK_TIME -eq $times ] ; then
				printf "\n" ; printDate ; echo -e "${GREEN}Script has done${NC}"
				break
			fi
		done
	fi
fi
