#!/bin/bash

short_name=${0##*/}
actual_subdirectory="$1"
actual_date=$(date +%Y%m%d)
hdd_tempdir_for_oldbackup="/home/ethsri/Temp4BackupIomega"
actual_directory="${hdd_tempdir_for_oldbackup}/${actual_subdirectory}"
backup_path="/media/ethsri/Iomega HDD/Backup"

# Check command line parameters
if [ $# -ne 1 ]
then
    echo "ERROR! Wrong number of parameters."
    echo "Usage: ${short_name} <directory name under Backup on Iomega>"
    exit 1
fi

# check that backup tool is mounted


# Check that we have enough space on backup tool


echo "Making the backup..."

cp -rp /home/ethsri/Documents/Private/ "${backup_path}/Private_${actual_date}"
cp -rp /home/ethsri/Documents/Common/ "${backup_path}/Common_${actual_date}"

# Check if the old backup exists


# Check if we have enough space on the own HDD


echo "Copying the old backup to the own HDD..."
cp -rp "${backup_path}/${actual_subdirectory}" ${hdd_tempdir_for_oldbackup}/

echo "Getting rid of single quotes in filenames..."
find ${actual_directory} -type f -name "*'*" -exec rename "s/\'/-/" "{}" + ;

echo "Getting rid of MSDOS line endings in text files..."
IFS=$'\n'
for myfile in $(find ${actual_directory} -iname \*.txt -o -iname \*.htm\* -o -iname \*.css); do if /usr/bin/file "${myfile}" | grep -q "with CRLF line terminators"; then sed -i 's/\r$//' "${myfile}" ; fi; done

echo "Searching for duplicate files..."
cd /home/ethsri/Documents/Common/Scripts/DupliSeek
./dupliSeek.py -r /home/ethsri/Documents/ -s ${actual_directory} > ${hdd_tempdir_for_oldbackup}/duplicate_files.txt

echo "Removing found duplicate files in the HDD..."
grep Temp4BackupIomega ${hdd_tempdir_for_oldbackup}/duplicate_files.txt | xargs -I{} rm {}

echo "Deleting zero size files and empty directories..."
find ${actual_directory} -type f -size 0 -delete
find ${actual_directory} -type d -empty -delete
