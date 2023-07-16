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
print_heading_message "Export the local database for production use."

# Prompt the user for confirmation
prompt_confirmation

# Check if wp-cli is installed
check_wp_cli_installed

echo "******************************************************"
echo "1) Exporting a local backup of the database for production..."
local_export_database "${LOCAL_WP_PATH}" "${PRODUCTION_WP_DB}"
echo "******************************************************"

echo "******************************************************"
echo "2) Performing search-replace from ${LOCAL_DOMAIN} to ${PRODUCTION_DOMAIN}..."
local_search_replace "${LOCAL_WP_PATH}" "${LOCAL_DOMAIN}" "${PRODUCTION_DOMAIN}" "${PRODUCTION_WP_DB}"
echo "******************************************************"

echo "******************************************************"
echo "3) Patching the database collation..."
patch_collation "${LOCAL_WP_PATH}" "${PRODUCTION_WP_DB}"
echo "******************************************************"

# Execution completed
exec_completed