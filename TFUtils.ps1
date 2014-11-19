$scriptPath = Split-Path (Resolve-Path $myInvocation.MyCommand.Path)

function Get-TFStatus {
    param([switch] $detailed)
    $settings = $Global:TFPromptSettings
    if($settings.Debug) {
        $sw = [Diagnostics.Stopwatch]::StartNew(); Write-Host ''
    } else {
        $sw = $null
    }
    $enabled = (-not $settings) -or $settings.EnablePromptStatus
    $hasTfs = $false
    if ($enabled) {
        $filesystemProvider = (Get-Location | Select Provider).Provider.Name -like 'FileSystem'
        if (!$filesystemProvider) { return }
        dbg 'Checking Workspace' $sw
        if ($settings.EnableServerStatus) {
            $tfsStatus = tf @$scriptPath\GetBothStatus.tfc
        } else {
            $tfsStatus = tf @$scriptPath\GetLocalStatus.tfc
        }
        $isWorkspace = $tfsStatus -match "Workspace"
        dbg 'Finished Checking Workspace and getting status' $sw
    }
    if ($enabled -and $isWorkspace)
    {
        $filesAdded = 0
        $filesDeleted = 0
        $filesModified = 0
        $changesets = 0
        $behindAdded = 0
        $behindDeleted = 0
        $behindModified = 0
        
        if ($tfsStatus -notcontains "There are no pending changes.") {
            $filesAdded = ([regex]"\s+Change\s+\:\sadd").Matches($tfsStatus).Count
            $filesDeleted = ([regex]"\s+Change\s+\:\sdelete").Matches($tfsStatus).Count
            $filesModified = ([regex]"\s+Change\s+\:\sedit").Matches($tfsStatus).Count
        }
        if ($settings.EnableServerStatus -and $tfsStatus -notcontains "No history entries were found for the item and version combination specified.") {
            $changesets = ([regex]"Changeset:\s+\d+").Matches($tfsStatus).Count
            $behindAdded = ([regex]"\s+(add)\s+\$").Matches($tfsStatus).Count
            $behindDeleted = ([regex]"\s+(delete).*\s+\$").Matches($tfsStatus).Count
            $behindModified = ([regex]"\s+(edit)\s+\$").Matches($tfsStatus).Count
        }

        if (!$detailed) {
            $result = [pscustomobject]@{
                LocalAdded      = $filesAdded
                LocalModified   = $filesModified
                LocalDeleted    = $filesDeleted
                Changesets      = $changesets
                ServerAdded     = $behindAdded
                ServerModified  = $behindModified
                ServerDeleted   = $behindDeleted
            }
        } else {
            $result = $tfsStatus           
        }

        dbg 'Finished' $sw
        if($sw) { $sw.Stop() }
        return $result
    }
}
