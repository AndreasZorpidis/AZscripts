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
print_heading_message "Migrate the staging files and database into local."

# Prompt the user for confirmation
prompt_confirmation

# Confirm twice for safety
prompt_confirmation

# Check if wp-cli is installed
check_wp_cli_installed

echo "******************************************************"
# Replace domain and export the staging database
echo "1) Performing search-replace from ${STAGING_DOMAIN} to ${LOCAL_DOMAIN}..."
ssh -i "${STAGING_SERVER_SSH_PRIVATE_KEY}" "${STAGING_SERVER_SSH_USER}@${STAGING_SERVER_SSH_HOST}" "cd ${STAGING_SERVER_WP_PATH} && wp search-replace ${STAGING_DOMAIN}  ${LOCAL_DOMAIN} --export='${STAGING_WP_DB}' --all-tables"
check_error
echo "******************************************************"

echo "******************************************************"
# Compress the staging WordPress files, excluding wp-config.php and other files
echo "2) Compressing files and database..."
ssh -i "${STAGING_SERVER_SSH_PRIVATE_KEY}" "${STAGING_SERVER_SSH_USER}@${STAGING_SERVER_SSH_HOST}" "cd ${STAGING_SERVER_WP_PATH} && tar -czf ${STAGING_WP_FILES} --exclude='wp-config.php' --exclude='.htaccess' --exclude='robots.txt' --exclude='.az_*.sh' --exclude='.vscode*' --exclude='.git*' --exclude='${STAGING_WP_FILES}' *"
check_error
echo "******************************************************"

echo "******************************************************"
# Delete existing files on the local (except wp-config.php)
echo "3) Cleaning the local..."
find . -type f ! -name 'wp-config.php' ! -name '.az_*.sh' ! -name '.git*' ! -name '.htaccess' ! -name 'robots.txt' ! -name '.vscode' ! -name '*.backup.sql' -exec rm -f {} \; -o -type d \( ! -name '.git' ! -name '.gitignore' \) -exec rm -rf {} \;
echo "******************************************************"

echo "******************************************************"
# Transfer the compressed files and database to the staging server using rsync
echo "4) Transferring the files and database to the local..."
scp -i "${STAGING_SERVER_SSH_PRIVATE_KEY}" "${STAGING_SERVER_SSH_USER}@${STAGING_SERVER_SSH_HOST}:${STAGING_SERVER_WP_PATH}/${STAGING_WP_FILES}" "${LOCAL_WP_PATH}"
check_error
echo "******************************************************"

echo "******************************************************"
# Extract the files to local
echo "5) Extracting the files to local..."
tar -xzf "${STAGING_WP_FILES}"
check_error
echo "******************************************************"

echo "******************************************************"
echo "6) Exporting a local backup of the database..."
local_export_database "${LOCAL_WP_PATH}" "${LOCAL_WP_DB_BACKUP}"
echo "******************************************************"

echo "******************************************************"
# Import the database to local
echo "7) Importing the database to local..."
cd "${LOCAL_WP_PATH}" && wp db import "${STAGING_WP_DB}"
check_error
echo "******************************************************"

echo "******************************************************"
# Delete temporary files on the staging server
echo "8) Deleting temporary files on the staging server..."
ssh -i "${STAGING_SERVER_SSH_PRIVATE_KEY}" "${STAGING_SERVER_SSH_USER}@${STAGING_SERVER_SSH_HOST}" "cd ${STAGING_SERVER_WP_PATH} && rm ${STAGING_WP_DB} ${STAGING_WP_FILES}"
echo "******************************************************"

echo "******************************************************"
# Cleanup - delete local temporary files
echo "9) Deleting local temporary files..."
cd "${LOCAL_WP_PATH}" && rm "${STAGING_WP_DB}" "${STAGING_WP_FILES}"
echo "******************************************************"

# Execution completed
exec_completed