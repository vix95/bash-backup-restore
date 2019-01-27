# backup.sh
A script for creating full or incremental backups. Based on sleep method or corn.

## CRON
Step by step how to run script by cron

> $ crontab -e<br />
> */1 * * * * bash /home/vix/backup/backup.sh --backup --cron<br />
> $ sudo /etc/init.d/cron start<br />
> $ sudo /etc/init.d/cron stop<br />

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
> $ bash backup.sh<br />
> $ bash backup.sh --backup --name='newname'<br />
> $ bash backup.sh --backup --full-interval=15<br />
> $ bash backup.sh --backup --inc-interval=1<br />
> $ bash backup.sh --backup --path='/home/vix/backup/randomdir'<br />
> $ bash backup.sh --backup --backup-dir='/home/vix/backup/new-backup-dir'<br />
> $ bash backup.sh --backup --gzip<br />
> $ bash backup.sh --backup --ext=php,js<br />
> $ bash backup.sh --restore<br />
> $ bash backup.sh --restore --name=111<br />
> $ bash backup.sh --restore --out-dir='/home/vix/backup/new_out-dir'<br />
> $ bash backup.sh --backup --name='new_backup' --full-interval=10 --inc-interval=4<br />
> $ bash backup.sh --backup<br />
> $ bash backup.sh --backup --path='/home/vix/backup/random_dir'<br />
> $ bash backup.sh --backup --path='/home/vix/backup/random_dir' --name='new_backup'<br />
> $ bash backup.sh --backup --inc-days=1<br />
> $ bash backup.sh --backup --break-time=20<br />
> $ bash backup.sh --show-settings<br />
> $ bash backup.sh --restore --date=2019_01_26_22_32<br />
