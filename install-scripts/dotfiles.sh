#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Modified by https://github.com/TomekBobrowicz for personal usage #
# Hyprland-Dots to download from Releases #

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

printf "${NOTE} Downloading / Checking for existing hyprland.tar.gz...\n"

# Check if HyprDots.tar.gz exists
if [ -f HyprDots.tar.gz ]; then
  printf "${NOTE} HyprDots.tar.gz found.\n"

  # Get the version from the existing tarball filename
  existing_version=$(echo HyprDots.tar.gz | grep -oP 'v\d+\.\d+\.\d+' | sed 's/v//')

  # Fetch the tag_name for the latest release using the GitHub API
  latest_version=$(curl -s https://api.github.com/repos/tomekbobrowicz/HyprDots/releases/latest | grep "tag_name" | cut -d '"' -f 4 | sed 's/v//')

  # Check if versions match
  if [ "$existing_version" = "$latest_version" ]; then
    echo -e "${OK} HyprDots.tar.gz is up-to-date with the latest release ($latest_version)."
    
    # Sleep for 10 seconds before exiting
    printf "${NOTE} No update found. Sleeping for 10 seconds...\n"
    sleep 10
    exit 0
  else
    echo -e "${WARN} HyprDots.tar.gz is outdated (Existing version: $existing_version, Latest version: $latest_version)."
    read -p "Do you want to upgrade to the latest version? (y/n): " upgrade_choice
    if [ "$upgrade_choice" = "y" ]; then
		echo -e "${NOTE} Proceeding to download the latest release." 2>&1 | tee -a "../Install-Logs/install-$(date +'%d-%H%M%S')_dotfiles.log"
		
		# Delete existing directories starting with HyprDots
      find . -type d -name 'HyprDots*' -exec rm -rf {} +
      rm -f HyprDots.tar.gz
      printf "${WARN} Removed existing HyprDots.tar.gz.\n"
    else
      echo -e "${NOTE} User chose not to upgrade. Exiting..." 2>&1 | tee -a "../Install-Logs/install-$(date +'%d-%H%M%S')_dotfiles.log"
      exit 0
    fi
  fi
fi

printf "\n"

printf "${NOTE} Downloading the latest hyprland source code release...\n"

# Fetch the tag name for the latest release using the GitHub API
latest_tag=$(curl -s https://api.github.com/repos/tomekbobrowicz/HyprDots/releases/latest | grep "tag_name" | cut -d '"' -f 4)

# Check if the tag is obtained successfully
if [ -z "$latest_tag" ]; then
  echo -e "${ERROR} Unable to fetch the latest tag information." 2>&1 | tee -a "../Install-Logs/install-$(date +'%d-%H%M%S')_dotfiles.log"
  exit 1
fi

# Fetch the tarball URL for the latest release using the GitHub API
latest_tarball_url=$(curl -s https://api.github.com/repos/tomekbobrowicz/HyprDots/releases/latest | grep "tarball_url" | cut -d '"' -f 4)

# Check if the URL is obtained successfully
if [ -z "$latest_tarball_url" ]; then
  echo -e "${ERROR} Unable to fetch the tarball URL for the latest release." 2>&1 | tee -a "../Install-Logs/install-$(date +'%d-%H%M%S')_dotfiles.log"
  exit 1
fi

# Get the filename from the URL and include the tag name in the file name
file_name="HyprDots-${latest_tag}.tar.gz"

# Download the latest release source code tarball to the current directory
if curl -L "$latest_tarball_url" -o "$file_name"; then
  # Extract the contents of the tarball
  tar -xzf "$file_name" || exit 1

  # delete existing Hyprland-Dots
  rm -rf HyprDots

  # Identify the extracted directory
  extracted_directory=$(tar -tf "$file_name" | grep -o '^[^/]\+' | uniq)

  # Rename the extracted directory to HyprDots
  mv "$extracted_directory" HyprDots || exit 1

  cd "HyprDots" || exit 1

  # Set execute permission for copy.sh and execute it
  chmod +x copy.sh
  ./copy.sh 

  echo -e "${OK} Latest Dotfiles release downloaded, extracted, and processed successfully. Check HyprDots folder for more detailed install logs" 2>&1 | tee -a "../Install-Logs/install-$(date +'%d-%H%M%S')_dotfiles.log"
else
  echo -e "${ERROR} Failed to download the latest Dotfiles release." 2>&1 | tee -a "../Install-Logs/install-$(date +'%d-%H%M%S')_dotfiles.log"
  exit 1
fi

clear