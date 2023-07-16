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
print_heading_message "Migrate the local database into staging."

# Prompt the user for confirmation
prompt_confirmation

# Check if wp-cli is installed
check_wp_cli_installed

echo "******************************************************"
echo "1) Exporting a local backup of the database..."
local_export_database "${LOCAL_WP_PATH}" "${LOCAL_WP_DB_BACKUP}"
echo "******************************************************"

echo "******************************************************"
echo "2) Performing search-replace from ${LOCAL_DOMAIN} to ${STAGING_DOMAIN}..."
local_search_replace "${LOCAL_WP_PATH}" "${LOCAL_DOMAIN}" "${STAGING_DOMAIN}" "${LOCAL_WP_DB}"
echo "******************************************************"

echo "******************************************************"
# Compress the local database
echo "3) Compressing the database..."
cd "${LOCAL_WP_PATH}" && tar -czf "${LOCAL_WP_FILES}" --exclude="wp-config.php" --exclude='.htaccess' --exclude='robots.txt' --exclude=".az_*.sh" --exclude=".vscode*" --exclude=".git*" "${LOCAL_WP_DB}"
check_error
echo "******************************************************"

echo "******************************************************"
# Transfer the compressed database to the staging server
echo "5) Transferring the compressed database to the staging server..."
scp -i "${STAGING_SERVER_SSH_PRIVATE_KEY}" "${LOCAL_WP_PATH}/${LOCAL_WP_FILES}" "${STAGING_SERVER_SSH_USER}@${STAGING_SERVER_SSH_HOST}:${STAGING_SERVER_WP_PATH}"
check_error
echo "******************************************************"

echo "******************************************************"
# Unzip the database on the staging server
echo "6) Extracting the database to the staging server..."
ssh -i "${STAGING_SERVER_SSH_PRIVATE_KEY}" "${STAGING_SERVER_SSH_USER}@${STAGING_SERVER_SSH_HOST}" "cd ${STAGING_SERVER_WP_PATH} && tar -xzf ${LOCAL_WP_FILES}"
check_error
echo "******************************************************"

echo "******************************************************"
# Import the staging database
echo "7) Importing the database to the staging server..."
ssh -i "${STAGING_SERVER_SSH_PRIVATE_KEY}" "${STAGING_SERVER_SSH_USER}@${STAGING_SERVER_SSH_HOST}" "cd ${STAGING_SERVER_WP_PATH} && wp db import ${LOCAL_WP_DB}"
check_error
echo "******************************************************"

echo "******************************************************"
# Delete temporary files on the staging server
echo "8) Deleting temporary files on the staging server..."
ssh -i "${STAGING_SERVER_SSH_PRIVATE_KEY}" "${STAGING_SERVER_SSH_USER}@${STAGING_SERVER_SSH_HOST}" "cd ${STAGING_SERVER_WP_PATH} && rm ${LOCAL_WP_DB} ${LOCAL_WP_FILES}"
echo "******************************************************"

echo "******************************************************"
# Cleanup - delete local temporary files
echo "9) Deleting local temporary files..."
cd "${LOCAL_WP_PATH}" && rm "${LOCAL_WP_DB}" "${LOCAL_WP_FILES}"
echo "******************************************************"

# Execution completed
exec_completed