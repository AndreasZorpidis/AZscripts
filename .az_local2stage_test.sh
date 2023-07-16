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
print_heading_message "Test the SSH connection with staging."

# Test SSH connection
echo "******************************************************"
echo "Testing SSH connection to staging server..."
ssh -o BatchMode=yes -i "${STAGING_SERVER_SSH_PRIVATE_KEY}" "${STAGING_SERVER_SSH_USER}@${STAGING_SERVER_SSH_HOST}" "echo Message from staging: SSH connection successful!"
if [ $? -eq 0 ]; then
  echo "Message from local: SSH connection test successful!"
else
  echo "Message from local: SSH connection test failed!"
fi
echo "******************************************************"

# Execution completed
exec_completed