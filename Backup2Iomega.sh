#!/bin/bash
# This script makes the backup of the current Private and Common directory to IOmega, then copies Private back.
# After the successful copy, removes the old - the date is the command line parameter - directories from IOmega.

short_name=${0##*/}
old_backup_date="$1"
private_dir_on_iomega=Private_${old_backup_date}
actual_date=$(date +%Y%m%d)
hdd_tempdir_for_oldbackup="/home/ethsri/Temp4BackupIomega"
actual_directory="${hdd_tempdir_for_oldbackup}/${private_dir_on_iomega}"
BACKUP_PATH="/media/ethsri/Iomega HDD/Backup"
DIRS_TO_BACKUP="Common Private"

function exit_if_error {
    if [ $1 -ne 0 ]
    then
        echo "ERROR occurred during $2. Exiting..."
        exit 1
    fi
}

# Check command line parameters
if [ $# -ne 1 ]
then
    echo "ERROR! Wrong number of parameters."
    echo "Usage: ${short_name} <date of backup under Backup on Iomega>"
    exit 1
fi

# Check that backup tool is mounted
if [ ! -d "${BACKUP_PATH}" ]
then
    echo "ERROR! Iomega is not connected/mounted."
    exit 1
fi

# Check if the old backup exists
if [ ! -d "${BACKUP_PATH}/${private_dir_on_iomega}" ]
then
    echo "ERROR! File ${private_dir_on_iomega} does not exist in ${BACKUP_PATH}."
    exit 1
fi

# Check that we have enough space on backup tool

echo "Making the backup..."
for dir in ${DIRS_TO_BACKUP}
do
    cp -rp /home/ethsri/Documents/${dir}/ "${BACKUP_PATH}/${dir}_${actual_date}"
    exit_if_error $? "copying ${dir} to ${BACKUP_PATH}"
done

# Check if we have enough space on the own HDD


echo "Copying the old backup to the own HDD..."
cp -rp "${BACKUP_PATH}/${private_dir_on_iomega}" ${hdd_tempdir_for_oldbackup}/
exit_if_error $? "copying ${private_dir_on_iomega} to ${hdd_tempdir_for_oldbackup}"

echo "Removing old directories on the backup device..."
for dir in "${DIRS_TO_BACKUP}"
do
    if [ -d "${BACKUP_PATH}/${dir}_${old_backup_date}" ]
    then
        rm -rf "${BACKUP_PATH}/${dir}_${old_backup_date}"
    fi
done

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

