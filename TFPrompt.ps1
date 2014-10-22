$global:TFPromptSettings = New-Object PSObject -Property @{
    DefaultForegroundColor    = $Host.UI.RawUI.ForegroundColor

    BeforeText                = ' ['
    BeforeForegroundColor     = [ConsoleColor]::Yellow
    BeforeBackgroundColor     = $Host.UI.RawUI.BackgroundColor

    DelimText                 = ' |'
    DelimForegroundColor      = [ConsoleColor]::Yellow
    DelimBackgroundColor      = $Host.UI.RawUI.BackgroundColor

    AfterText                 = ']'
    AfterForegroundColor      = [ConsoleColor]::Yellow
    AfterBackgroundColor      = $Host.UI.RawUI.BackgroundColor

    LocalForegroundColor      = [ConsoleColor]::DarkGreen
    LocalBackgroundColor      = $Host.UI.RawUI.BackgroundColor
    
    ServerForegroundColor     = [ConsoleColor]::DarkRed
    ServerBackgroundColor     = $Host.UI.RawUI.BackgroundColor

    ShowStatusWhenZero        = $true

    EnablePromptStatus        = !$Global:TFMissing

    EnableServerStatus        = $true

    Debug                     = $false
}

function Write-Prompt($Object, $ForegroundColor, $BackgroundColor = -1) {
    if ($BackgroundColor -lt 0) {
        Write-Host $Object -NoNewLine -ForegroundColor $ForegroundColor
    } else {
        Write-Host $Object -NoNewLine -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
    }
}

function Write-TFStatus($status) {
    $s = $global:TFPromptSettings
    if ($status -and $s) {
        Write-Prompt $s.BeforeText -BackgroundColor $s.BeforeBackgroundColor -ForegroundColor $s.BeforeForegroundColor

        if($s.ShowStatusWhenZero -or $status.LocalAdded) {
            Write-Prompt "+$($status.LocalAdded) " -BackgroundColor $s.LocalBackgroundColor -ForegroundColor $s.LocalForegroundColor
        }
        if($s.ShowStatusWhenZero -or $status.LocalModified) {
            Write-Prompt "~$($status.LocalModified) " -BackgroundColor $s.LocalBackgroundColor -ForegroundColor $s.LocalForegroundColor
        }
        if($s.ShowStatusWhenZero -or $status.LocalDeleted) {
            Write-Prompt "-$($status.LocalDeleted)" -BackgroundColor $s.LocalBackgroundColor -ForegroundColor $s.LocalForegroundColor
        }
        
        if($s.EnableServerStatus -and ($s.ShowStatusWhenZero -or $status.Changesets)) {
            Write-Prompt $s.DelimText -BackgroundColor $s.DelimBackgroundColor -ForegroundColor $s.DelimForegroundColor
            Write-Prompt " $($status.Changesets):(" -BackgroundColor $s.ServerBackgroundColor -ForegroundColor $s.ServerForegroundColor
            if($s.ShowStatusWhenZero -or $status.ServerAdded) {
                Write-Prompt "+$($status.ServerAdded) " -BackgroundColor $s.ServerBackgroundColor -ForegroundColor $s.ServerForegroundColor
            }
            if($s.ShowStatusWhenZero -or $status.ServerModified) {
                Write-Prompt "~$($status.ServerModified) " -BackgroundColor $s.ServerBackgroundColor -ForegroundColor $s.ServerForegroundColor
            }
            if($s.ShowStatusWhenZero -or $status.ServerDeleted) {
                Write-Prompt "-$($status.ServerDeleted)" -BackgroundColor $s.ServerBackgroundColor -ForegroundColor $s.ServerForegroundColor
            }
            Write-Prompt ")" -BackgroundColor $s.ServerBackgroundColor -ForegroundColor $s.ServerForegroundColor
        }
        Write-Prompt $s.AfterText -BackgroundColor $s.AfterBackgroundColor -ForegroundColor $s.AfterForegroundColor
    }
}

if((Get-Variable -Scope Global -Name VcsPromptStatuses -ErrorAction SilentlyContinue) -eq $null) {
    $Global:VcsPromptStatuses = @()
}
function Global:Write-VcsStatus { $Global:VcsPromptStatuses | foreach { & $_ } }

# Add scriptblock that will execute for Write-VcsStatus
$Global:VcsPromptStatuses += {
    $Global:TFStatus = Get-TFStatus
    Write-TFStatus $TFStatus
}
