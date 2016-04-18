#!/bin/bash

actual_subdirectory="$1"
actual_date=$(date +%Y%m%d)
hdd_tempdir_for_oldbackup="/home/ethsri/Temp4BackupIomega"
actual_directory="${hdd_tempdir_for_oldbackup}/${actual_subdirectory}"
backup_path="/media/ethsri/Iomega HDD/Backup"

# check that backup tool is mounted


# Check that we have enough space on backup tool


# Do the backup
cp -rp /home/ethsri/Documents/Private/ "${backup_path}/Private_${actual_date}"

exit 2

# Check if the old backup exists


# Check if we have enough space on the own HDD


# Copy the old backup to the own HDD
cp -rp ${backup_path}/${actual_subdirectory} ${hdd_tempdir_for_oldbackup}/

find ${actual_directory} -type f -name "*'*" -exec rename "s/\'/-/" "{}" + ;

IFS=$'\n'
for myfile in $(find ${actual_directory} -iname \*.txt -o -iname \*.htm\* -o -iname \*.css); do if /usr/bin/file "${myfile}" | grep -q "with CRLF line terminators"; then sed -i 's/\r$//' "${myfile}" ; fi; done

cd /home/ethsri/Documents/Common/Scripts/DupliSeek
./dupliSeek.py -r /home/ethsri/Documents/ -s ${actual_directory} > ${hdd_tempdir_for_oldbackup}/duplicate_files.txt

grep Temp4BackupIomega ${hdd_tempdir_for_oldbackup}/duplicate_files.txt | xargs -I{} rm {}
find ${actual_directory} -type f -size 0 -delete
find ${actual_directory} -type d -empty -delete



cp -rp ${hdd_tempdir_for_oldbackup}/ /tmp/Private_${actual_date}