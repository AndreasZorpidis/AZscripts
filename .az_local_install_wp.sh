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
print_heading_message "Install the WordPress core in local."

# Prompt the user for confirmation
prompt_confirmation

# Confirm twice for safety
prompt_confirmation

# Check if wp-cli is installed
check_wp_cli_installed

echo "******************************************************"
# Installing the WordPress core
echo "1) Installing the WordPress core..."

# # Check if the target directory already exists
# if [ -d "${LOCAL_WP_PATH}" ]; then
#     echo "WordPress is already installed in ${LOCAL_WP_PATH}. Aborting installation."
#     exit 1
# fi

# Create the target directory
mkdir -p "${LOCAL_WP_PATH}"

# Change to the target directory
cd "${LOCAL_WP_PATH}" || exit 1

# Download the latest WordPress release using cURL or wget
if command -v curl &> /dev/null; then
    echo "Downloading WordPress using cURL..."
    curl -O https://wordpress.org/latest.tar.gz
elif command -v wget &> /dev/null; then
    echo "Downloading WordPress using wget..."
    wget https://wordpress.org/latest.tar.gz
else
    echo "cURL or wget is required to download WordPress. Please install either of them and rerun the script."
    exit 1
fi

# Extract the downloaded WordPress archive
echo "Extracting WordPress..."
tar -xf latest.tar.gz

# Move the extracted WordPress files to the target directory
mv wordpress/* ./

# Clean up temporary files
rm -rf wordpress latest.tar.gz

echo "******************************************************"

# Execution completed
exec_completed