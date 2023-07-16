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
print_heading_message "Migrate the staging database into local."

# Prompt the user for confirmation
prompt_confirmation

# Confirm twice for safety
prompt_confirmation

# Check if wp-cli is installed
check_wp_cli_installed

# DATABASE MIGRATION 

echo "******************************************************"
# Replace domain and export the staging database
echo "1) Performing search-replace from ${STAGING_DOMAIN} to ${LOCAL_DOMAIN}..."
ssh -i "${STAGING_SERVER_SSH_PRIVATE_KEY}" "${STAGING_SERVER_SSH_USER}@${STAGING_SERVER_SSH_HOST}" "cd ${STAGING_SERVER_WP_PATH} && wp search-replace ${STAGING_DOMAIN}  ${LOCAL_DOMAIN} --export='${STAGING_WP_DB}' --all-tables"
check_error
echo "******************************************************"

echo "******************************************************"
# Compress the staging WordPress database
echo "2) Compressing the database..."
ssh -i "${STAGING_SERVER_SSH_PRIVATE_KEY}" "${STAGING_SERVER_SSH_USER}@${STAGING_SERVER_SSH_HOST}" "cd ${STAGING_SERVER_WP_PATH} && tar -czf ${STAGING_WP_FILES} --exclude='wp-config.php' --exclude='.htaccess' --exclude='robots.txt' --exclude='.az_*.sh' --exclude='.vscode*' --exclude='.git*' ${STAGING_WP_DB}"
check_error
echo "******************************************************"

echo "******************************************************"
# Transfer the compressed staging WordPress database
echo "3) Transferring the database to the local..."
scp -i "${STAGING_SERVER_SSH_PRIVATE_KEY}" "${STAGING_SERVER_SSH_USER}@${STAGING_SERVER_SSH_HOST}:${STAGING_SERVER_WP_PATH}/${STAGING_WP_FILES}" "${LOCAL_WP_PATH}"
check_error
echo "******************************************************"

echo "******************************************************"
# Delete temporary files on the staging server
echo "4) Deleting temporary files on the staging server..."
ssh -i "${STAGING_SERVER_SSH_PRIVATE_KEY}" "${STAGING_SERVER_SSH_USER}@${STAGING_SERVER_SSH_HOST}" "cd ${STAGING_SERVER_WP_PATH} && rm ${STAGING_WP_DB} ${STAGING_WP_FILES}'"
echo "******************************************************"

echo "******************************************************"
echo "5) Exporting a local backup of the database..."
local_export_database "${LOCAL_WP_PATH}" "${LOCAL_WP_DB_BACKUP}"
echo "******************************************************"

echo "******************************************************"
# Extract the database to local
echo "6) Extracting the database to local..."
cd "${LOCAL_WP_PATH}" && tar -xzf "${STAGING_WP_FILES}"
check_error
echo "******************************************************"

echo "******************************************************"
# Import the database to local
echo "7) Importing the database to local..."
cd "${LOCAL_WP_PATH}" && wp db import "${STAGING_WP_DB}"
check_error
echo "******************************************************"

echo "******************************************************"
# Delete temporary files on local
echo "8) Deleting temporary files on local..."
cd "${LOCAL_WP_PATH}" && rm "${STAGING_WP_DB}" "${STAGING_WP_FILES}"
echo "******************************************************"

# Execution completed
exec_completed