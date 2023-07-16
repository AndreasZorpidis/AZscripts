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
print_heading_message "Migrate the local files into staging."

# Prompt the user for confirmation
prompt_confirmation

# Check if wp-cli is installed
check_wp_cli_installed

echo "******************************************************"
# Compress the local WordPress files, excluding wp-config.php, .htaccess and other files
echo "1) Compressing files..."
cd "${LOCAL_WP_PATH}" && tar -czf "${LOCAL_WP_FILES}" --exclude="wp-config.php" --exclude='.htaccess' --exclude='robots.txt' --exclude=".az_*.sh" --exclude=".vscode*" --exclude=".git*" --exclude="${LOCAL_WP_FILES}" *
check_error
echo "******************************************************"

echo "******************************************************"
# Delete existing files on the staging server (except wp-config.php and htaccess)
echo "2) Cleaning the staging server..."
ssh -i "${STAGING_SERVER_SSH_PRIVATE_KEY}" "${STAGING_SERVER_SSH_USER}@${STAGING_SERVER_SSH_HOST}" "cd ${STAGING_SERVER_WP_PATH} && find . ! -name 'wp-config.php' ! -name '.htaccess' ! -name 'robots.txt' -type f -exec rm -f {} \; -o -type d -exec rm -rf {} \;"
echo "******************************************************"

echo "******************************************************"
# Transfer the compressed files to the staging server
echo "3) Transferring the files to the staging server..."
scp -i "${STAGING_SERVER_SSH_PRIVATE_KEY}" "${LOCAL_WP_PATH}/${LOCAL_WP_FILES}" "${STAGING_SERVER_SSH_USER}@${STAGING_SERVER_SSH_HOST}:${STAGING_SERVER_WP_PATH}"
check_error
echo "******************************************************"

echo "******************************************************"
# Unzip the files on the staging server
echo "4) Extracting the files to the staging server..."
ssh -i "${STAGING_SERVER_SSH_PRIVATE_KEY}" "${STAGING_SERVER_SSH_USER}@${STAGING_SERVER_SSH_HOST}" "cd ${STAGING_SERVER_WP_PATH} && tar -xzf ${LOCAL_WP_FILES}"
check_error
echo "******************************************************"

echo "******************************************************"
# Delete temporary files on the staging server
echo "5) Deleting temporary files on the staging server..."
ssh -i "${STAGING_SERVER_SSH_PRIVATE_KEY}" "${STAGING_SERVER_SSH_USER}@${STAGING_SERVER_SSH_HOST}" "cd ${STAGING_SERVER_WP_PATH} && rm ${LOCAL_WP_FILES}"
echo "******************************************************"

echo "******************************************************"
# Cleanup - delete local temporary files
echo "6) Deleting local temporary files..."
cd "${LOCAL_WP_PATH}" && rm "${LOCAL_WP_DB}" "${LOCAL_WP_FILES}"
echo "******************************************************"

# Execution completed
exec_completed