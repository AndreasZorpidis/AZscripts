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
print_heading_message "Add the remote repository to the current project's folder without deleting the its files."

# Prompt the user for confirmation
prompt_confirmation

# Confirm twice for safety
prompt_confirmation

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Create a temporary directory inside the current directory
temp_dir=$(mktemp -d -p .)

# Clone the remote repository using Sourcetree
if command_exists sourcetree; then
  # Clone the repository using Sourcetree
  sourcetree --clone "$BITBUCKET_PROJECT_REPO" "$temp_dir"
  check_error
else
  # Clone the repository using Git
  git clone  --depth=1 "$BITBUCKET_PROJECT_REPO" "$temp_dir"
  check_error
fi

# Move the .git folder and its contents to the parent directory
cd "${LOCAL_WP_PATH}" && mv "$temp_dir/.git" .

# Delete the temporary folder
cd "${LOCAL_WP_PATH}" && rm -rf "$temp_dir"
check_error

echo "******************************************************"
echo "*         Remote repo added to the project!          *"
echo "******************************************************"

echo "******************************************************"
echo "*      You can now add this repo in SourceTree!      *"
echo "******************************************************"

# Execution completed
exec_completed