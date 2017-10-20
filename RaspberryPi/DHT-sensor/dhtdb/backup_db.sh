#!/bin/sh

backuphome=/path/to/backupfolder
dbhome=/path/to/dbfolder
db=dbname
date=$(date +"%Y%m%d-%H%M")

echo ".dump" | sqlite3 $dbhome/$db | bzip2 --best > $backuphome/$db-$date\_dump.bz2

find $backuphome -type f -mtime +10 | xargs rm -rf
