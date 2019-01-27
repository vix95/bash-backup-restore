# backup.sh
A script for creating full or incremental backups. Based on sleep method or corn.

## CRON
Step by step how to run script by cron

> $ crontab -e
> */1 * * * * bash /home/vix/backup/backup.sh --backup --cron
> $ sudo /etc/init.d/cron start
> $ sudo /etc/init.d/cron stop

## Manual
A script has methods:
- change backup name
- change full or incremental interval in seconds
- change path to the directory from which the files will be backed up
- change a directory where backup files will be stored; location of the backup file
- select the backup method, tar or gzip
- change days number to incremental backup
- set the list of extensions to backup
- restore backups
- do backups
- change path to restore location
- stop script after x times fails
- stop script after x seconds
- color the aletrs and notifications
- print help and version methods
- create dir in case if isn't available
- searching for the most recent backup to be restored form a given time interval
- run script in default arguments in case arguments aren't provided
- run script in cron mode

## Examples
Some examples to test script.
> $ bash backup.sh
> $ bash backup.sh --backup --name='newname'
> $ bash backup.sh --backup --full-interval=15
> $ bash backup.sh --backup --inc-interval=1
> $ bash backup.sh --backup --path='/home/vix/backup/randomdir'
> $ bash backup.sh --backup --backup-dir='/home/vix/backup/new-backup-dir'
> $ bash backup.sh --backup --gzip
> $ bash backup.sh --backup --ext=php,js
> $ bash backup.sh --restore
> $ bash backup.sh --restore --name=111
> $ bash backup.sh --restore --out-dir='/home/vix/backup/new_out-dir'
> $ bash backup.sh --backup --name='new_backup' --full-interval=10 --inc-interval=4
> $ bash backup.sh --backup
> $ bash backup.sh --backup --path='/home/vix/backup/random_dir'
> $ bash backup.sh --backup --path='/home/vix/backup/random_dir' --name='new_backup'
> $ bash backup.sh --backup --inc-days=1
> $ bash backup.sh --backup --break-time=20
> $ bash backup.sh --show-settings
> $ bash backup.sh --restore --date=2019_01_26_22_32
