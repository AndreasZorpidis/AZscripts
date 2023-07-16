#####################################################
#                     AZscripts                     #
#                                                   #
# Description: A toolkit/collection of bash scripts #
#              for WordPress DevOps tasks.          #
#                                                   #
# Version: 1.2 (Prototype)                          #
# Author: Andreas Zorpidis                          #
# Website: andreaszorpidis.com                      #
# Repository: github.com/AndreasZorpidis/AZscripts  #
#                                                   #
# Licensed under the GNU General Public License     #
# Version 2 (GPL-2.0)                               #
#####################################################

#!/bin/bash

# Include the configuration file
source .az_config.sh

# Include functions
source .az_functions.sh

# Description of the script's functionality
print_heading_message "Migrate the production files and database into staging."

echo ""
echo "******************************************************"
echo "* Note: A full backup is needed in order to run this *"
echo "*       tool. You can use BackWPup to make those and *"
echo "*       send them to your staging server via FTP.    *"
echo "******************************************************"
echo ""

# Prompt the user for confirmation
prompt_confirmation

# Confirm twice for safety
prompt_confirmation

# Check if wp-cli is installed
check_wp_cli_installed

echo "******************************************************"
# Check if the backup file exists
echo "1) Checking if the backup file exists..."
ssh -i "${STAGING_SERVER_SSH_PRIVATE_KEY}" "${STAGING_SERVER_SSH_USER}@${STAGING_SERVER_SSH_HOST}" "cd ${STAGING_SERVER_BACKUP_PATH} && ls -1 *.zip >/dev/null 2>&1"
if [ $? -ne 0 ]; then
    echo "Backup file does not exist. Aborting script execution."
    exit 1
fi
echo "Backup file exists."
echo "******************************************************"

echo "******************************************************"
# Delete existing files on the staging server (except wp-config.php and .htaccess)
echo "2) Cleaning the staging server..."
ssh -i "${STAGING_SERVER_SSH_PRIVATE_KEY}" "${STAGING_SERVER_SSH_USER}@${STAGING_SERVER_SSH_HOST}" "cd ${STAGING_SERVER_WP_PATH} && find . ! -name 'wp-config.php' ! -name '.htaccess' ! -name 'robots.txt' -type f -exec rm -f {} \; -o -type d -exec rm -rf {} \;"
echo "Cleaned the staging server!"
echo "******************************************************"

echo "******************************************************"
# Copy the most recent production backup file to staging
echo "3) Copying the most recent file to staging..."

# Get the most recent .zip file
latest_zip_file=$(ssh -i "${STAGING_SERVER_SSH_PRIVATE_KEY}" "${STAGING_SERVER_SSH_USER}@${STAGING_SERVER_SSH_HOST}" "ls -t ${STAGING_SERVER_BACKUP_PATH}/*.zip | head -1")

# Check if a .zip file exists
if [ -z "$latest_zip_file" ]; then
    echo "No backup file found. Aborting script execution."
    exit 1
fi

# Extract the file name from the full path
zip_file_name=$(basename "$latest_zip_file")

# Copy the latest .zip file to staging
scp -i "${STAGING_SERVER_SSH_PRIVATE_KEY}" "${STAGING_SERVER_SSH_USER}@${STAGING_SERVER_SSH_HOST}:${latest_zip_file}" "${STAGING_SERVER_SSH_USER}@${STAGING_SERVER_SSH_HOST}:${STAGING_SERVER_WP_PATH}/${zip_file_name}"
echo "Copying completed!"
echo "******************************************************"

echo "******************************************************"
# Unzip the file on the staging server, excluding wp-config.php and .htaccess
echo "4) Unzipping the file on the staging server..."
ssh -i "${STAGING_SERVER_SSH_PRIVATE_KEY}" "${STAGING_SERVER_SSH_USER}@${STAGING_SERVER_SSH_HOST}" "cd ${STAGING_SERVER_WP_PATH} && unzip -x ${zip_file_name} -x wp-config.php -x .htaccess"
echo "Unzipped the file on the staging server!"
echo "******************************************************"

echo "******************************************************"
# Import the latest .sql file to staging and perform search-replace
echo "5) Importing the database to staging and performing search-replace from ${PRODUCTION_DOMAIN} to ${STAGING_DOMAIN}..."

# Find the latest .sql file
latest_sql_file=$(ssh -i "${STAGING_SERVER_SSH_PRIVATE_KEY}" "${STAGING_SERVER_SSH_USER}@${STAGING_SERVER_SSH_HOST}" "cd ${STAGING_SERVER_WP_PATH} && ls -t *.sql | head -1")

# Import the latest .sql file and perform search-replace
ssh -i "${STAGING_SERVER_SSH_PRIVATE_KEY}" "${STAGING_SERVER_SSH_USER}@${STAGING_SERVER_SSH_HOST}" "cd ${STAGING_SERVER_WP_PATH} && wp db import ${latest_sql_file} && wp search-replace ${PRODUCTION_DOMAIN} ${STAGING_DOMAIN} --all-tables"
check_error

echo "Imported the database to staging and performed search-replace!"
echo "******************************************************"

echo "******************************************************"
# Delete temporary files on the staging server
echo "6) Deleting temporary files on the staging server..."
ssh -i "${STAGING_SERVER_SSH_PRIVATE_KEY}" "${STAGING_SERVER_SSH_USER}@${STAGING_SERVER_SSH_HOST}" "cd ${STAGING_SERVER_WP_PATH} && rm ${zip_file_name} *.sql"
echo "Deleted temporary files on the staging server!"
echo "******************************************************"

# Execution completed
exec_completed