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
print_heading_message "Export the local files and database for local use."

# Prompt the user for confirmation
prompt_confirmation

# Check if wp-cli is installed
check_wp_cli_installed

echo "******************************************************"
echo "1) Exporting a local backup of the database..."
local_export_database "${LOCAL_WP_PATH}" "${LOCAL_WP_DB}"
echo "******************************************************"

echo "******************************************************"
# Compress the local WordPress files, including wp-config.php, not excluding .htaccess and other files
echo "2) Compressing files and database..."
cd "${LOCAL_WP_PATH}" && tar -czf "${LOCAL_WP_FILES}" --exclude=".az_*.sh" --exclude=".vscode*" --exclude=".git*" --exclude="${LOCAL_WP_FILES}" .htaccess *
check_error
echo "******************************************************"

echo "******************************************************"
# Cleanup - delete local temporary files
echo "3) Deleting local temporary files..."
cd "${LOCAL_WP_PATH}" && rm "${LOCAL_WP_DB}"
echo "******************************************************"

# Execution completed
exec_completed