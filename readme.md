posh-tf
========

A set of PowerShell scripts which provide TF/PowerShell integration

### Prompt for TF workspaces
   The prompt within TF workspaces shows the current state of files (additions, modifications, and deletions) for the workspace and the TFS repository.

### Tab completion
   Provides tab completion for common commands when using `tf` and `tfpt`.
   E.g. `tf ch<tab>` --> `tf checkout`

Usage
-----

See `profile.example.ps1` as to how you can integrate the tab completion and/or TF prompt into your own profile.
Prompt formatting, among other things, can be customized using `$TFPromptSettings`.

Installing
----------

0. Verify you have PowerShell 2.0 or better with $PSVersionTable.PSVersion

1. Verify execution of scripts is allowed with `Get-ExecutionPolicy` (should be `RemoteSigned` or `Unrestricted`). If scripts are not enabled, run PowerShell as Administrator and call `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Confirm`.

2. Clone the posh-tf repository to your local machine.

3. From the posh-tf repository directory, run `.\install.ps1`.

4. Enjoy!

### The Prompt

PowerShell generates its prompt by executing a prompt function, if one exists. posh-tf defines such a function in profile.example.ps1 that outputs the current working directory followed by a status:

C:\Projects [+0 ~2 -0 | 1:(+0 ~8 -0)]>

By default, the status summary has the following format:

[+A ~B -C | E:(+F ~G -H)]

* ABCD represent the current pending workspace; EFGH represent the TFS repository
    * + = Added files
    * ~ = Modified files
    * - = Removed files

For example, a status of [+0 ~2 -1 | 2(+1 ~8 -0)] corresponds to the following status:

    Your workspace contains the following pending changes
        0 added files
        2 edited files
        1 deleted file

    TFS has 2 Changesets ready to pull into your workspace
    Those changesets consist of:
        1 new file
        8 edited files
        0 deleted files

You can optionally disable the TFS server status by including the following in your profile, which will cause it to only output up to the pipe.
```
$global:TFPromptSettings.EnableServerStatus = $false
```

You can also call the following function to retrieve the output the prompt parses in order to display the prompt.
```
Get-TfStatus -detailed
```

### Based on work by:

 - Keith Dahlby, http://solutionizing.net/
 - Mark Embling, http://www.markembling.info/
 - Jeremy Skinner, http://www.jeremyskinner.co.uk/
