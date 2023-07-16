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

# Define the staging server ssh details
STAGING_SERVER_SSH_USER="XXXXXX"
STAGING_SERVER_SSH_HOST="XX.XX.XX.XX"
STAGING_SERVER_SSH_PRIVATE_KEY="\.ssh\id_rsa"
STAGING_SERVER_WP_PATH="/var/www/vhosts/website.domain/staging.website.domain"
STAGING_SERVER_BACKUP_PATH="/var/www/vhosts/website.domain/backwpup/website.domain"

# Define the domains of the project
LOCAL_DOMAIN="website.local"
STAGING_DOMAIN="staging.website.domain"
PRODUCTION_DOMAIN="website.domain"

# Define the url of the project's repository
BITBUCKET_PROJECT_REPO="https://xxxxxxx@bitbucket.org/xxxxxxx/test.git"

# You can leave the values below as they are

# Names of the files created
LOCAL_WP_DB="export_local_db.sql"
LOCAL_WP_FILES="export_local_files.tar.gz"
STAGING_WP_DB="export_staging_db.sql"
STAGING_WP_FILES="export_staging_files.tar.gz"
PRODUCTION_WP_DB="export_production_db.sql"
PRODUCTION_WP_FILES="export_production_files.tar.gz"
LOCAL_WP_DB_BACKUP=".backup.sql"

# Detect the current path of the local WordPress installation
LOCAL_WP_PATH=$(pwd | sed 's|/c|C:|' | sed 's|/|\\|g')