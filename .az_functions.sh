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


print_heading_message() {
  local message="$1"
  echo "
#####################################################
# AZscripts v1.2 | Author: AndreasZorpidis.com      #
#####################################################
# Disclaimer: This tool might delete important data.#
#             Use at your own risk!                 #
#####################################################

 $message 
#####################################################
"
}

# Function to check for errors and exit if any occurred
check_error() {
    if [ $? -ne 0 ]; then
        echo "An error occurred. Exiting..."
        exit 1
    fi
}

check_wp_cli_installed() {
  if ! command -v wp &> /dev/null; then
    echo "wp-cli is not installed. Please install wp-cli before running this script."
    exit 1
  fi
}

# Function to prompt the user for confirmation
prompt_confirmation() {
    read -r -p "Press 'y' or 'yes' to continue, or any other key to exit: " response
    if [[ $response =~ ^(yes|y|Y|YES|Yes)$ ]]; then
        return 0
    else
        echo "Migration aborted."
        exit 0
    fi
}

local_export_database() {
    local input_path=$1
    local output_filename=$2
    echo "${input_path}\\${output_filename}"
    cd "${input_path}" && wp db export "${output_filename}" --default-character-set=utf8mb4 --add-drop-table
    check_error
}

local_search_replace() {
    local input_path=$1
    local input_domain=$2
    local output_domain=$3
    local output_filename=$4
    # Replace domain
    # sed -i "s/${LOCAL_DOMAIN}/${PRODUCTION_DOMAIN}/g" "${LOCAL_WP_PATH}"'\'"${PRODUCTION_WP_DB}"
    cd "${input_path}" && wp search-replace "${input_domain}" "${output_domain}" --export="${output_filename}" --all-tables
    check_error
}

patch_collation() {
    local input_path=$1
    local output_filename=$2
    sed -i 's/utf8mb4_unicode_520_ci/utf8mb4_unicode_ci/g' "${input_path}\\${output_filename}"
}

local_update_database() {
    local local_wp_path=$1

    # Check if wp-config.php exists
    wp_config_file="${local_wp_path}/wp-config.php"
    if [ ! -f "$wp_config_file" ]; then
        echo "wp-config.php not found in ${local_wp_path}. Aborting database update."
        exit 1
    fi

    # Update the WordPress database using WP-CLI
    cd "${local_wp_path}" && wp core update-db
}

local_import_database_backup() {
    local input_path=$1
    local input_filename=$2

    backup_file="${input_path}/${input_filename}"

    if [ -f "$backup_file" ]; then
    cd "${input_path}" && wp db import "${input_filename}"
    echo "Backup file imported successfully."
    else
    echo "Backup file not found. Skipping import."
    fi
}

exec_completed() {
    echo "******************************************************"  
    echo "*                Execution completed!                *"
    echo "******************************************************"
}