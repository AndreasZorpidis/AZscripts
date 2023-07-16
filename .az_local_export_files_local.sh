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
print_heading_message "Export the local files for local use."

# Prompt the user for confirmation
prompt_confirmation

# Check if wp-cli is installed
check_wp_cli_installed

echo "******************************************************"
# Compress the local WordPress files, including wp-config.php, not excluding .htaccess and other files
echo "1) Compressing files..."
cd "${LOCAL_WP_PATH}" && tar -czf "${LOCAL_WP_FILES}" --exclude=".az_*.sh" --exclude=".vscode*" --exclude=".git*" --exclude="${LOCAL_WP_FILES}" .htaccess *
check_error
echo "******************************************************"

# Execution completed
exec_completed