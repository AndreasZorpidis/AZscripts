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
print_heading_message "Clone the remote repository inside local project's folder (this will delete the project's files)."

# Prompt the user for confirmation
prompt_confirmation

# Confirm twice for safety
prompt_confirmation

echo "******************************************************"
# Delete existing files on local (except of wp-config.php)
echo "1) Cleaning the local project directory..."
find . -type f ! -name 'wp-config.php' ! -name '.az_*.sh' ! -name '.git*' ! -name '.htaccess' ! -name 'robots.txt' ! -name '.vscode' ! -name '*.backup.sql' -exec rm -f {} \; -o -type d \( ! -name '.git' ! -name '.gitignore' \) -exec rm -rf {} \;
echo "******************************************************"

echo "******************************************************"
# Cloning the remote project into the local directory
echo "2) Cloning the remote project into the local directory..."

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
  git clone "$BITBUCKET_PROJECT_REPO" "$temp_dir"
  check_error
fi

# Move all contents of the temporary folder to the parent directory
cd "${LOCAL_WP_PATH}" && shopt -s dotglob  # Include hidden files and folders in glob expansion
cd "${LOCAL_WP_PATH}" && cp -R "$temp_dir"/* .

# Delete the temporary folder
cd "${LOCAL_WP_PATH}" && rm -rf "$temp_dir"
check_error

echo "******************************************************"

echo "******************************************************"
echo "*    Remote repo cloned to the project directory!    *"
echo "******************************************************"

echo "******************************************************"
echo "*      You can now add this repo in SourceTree!      *"
echo "******************************************************"

# Execution completed
exec_completed