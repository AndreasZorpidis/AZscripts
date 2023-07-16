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
print_heading_message "Export the local files and database for staging use."

# Prompt the user for confirmation
prompt_confirmation

# Check if wp-cli is installed
check_wp_cli_installed

echo "******************************************************"
echo "1) Exporting a local backup of the database for production..."
local_export_database "${LOCAL_WP_PATH}" "${STAGING_WP_DB}"
echo "******************************************************"

echo "******************************************************"
echo "2) Performing search-replace from ${LOCAL_DOMAIN} to ${STAGING_DOMAIN}..."
local_search_replace "${LOCAL_WP_PATH}" "${LOCAL_DOMAIN}" "${STAGING_DOMAIN}" "${STAGING_WP_DB}"
echo "******************************************************"

echo "******************************************************"
# Compress the local WordPress files, excluding wp-config.php, .htaccess and other files
echo "3) Compressing files and database..."
cd "${LOCAL_WP_PATH}" && tar -czf "${STAGING_WP_FILES}" --exclude="wp-config.php" --exclude='.htaccess' --exclude='robots.txt' --exclude=".az_*.sh" --exclude=".vscode*" --exclude=".git*" --exclude="${STAGING_WP_FILES}" *
check_error
echo "******************************************************"

echo "******************************************************"
# Cleanup - delete local temporary files
echo "4) Deleting local temporary files..."
cd "${LOCAL_WP_PATH}" && rm "${STAGING_WP_DB}"
echo "******************************************************"

# Execution completed
exec_completed