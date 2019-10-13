<!-- markdownlint-disable MD026 -->
# :dizzy: SmartResponse.Framework :dizzy:

SmartResponse.Framework is a powershell module containing commands (cmdlets) intended primarily for use in LogRhythm SmartResponse Plugin development, but can also be used interactively.  

This is an open source, community-driven project. Pull requests and other contributions or feedback are welcome and encouraged!  Please review the contribution guidelines below.

:fire: **Everyone is encouraged to read and contribute to [open design issues](https://github.com/SmartResponse-Framework/SmartResponse.Framework/issues).**

## News: October, 2019

Currently the repository contains only a fraction of the content developed in the original module.  The purpose of this initial commit is to introduce the project to the community, and tackle any initial design considerations.

Release of additional features will follow at a measured pace to ensure they fit the needs of the community and are entirely environment indepdenent.  The module has generally been developed with domain / environment neutrality in mind (it is a framework, afterall) but there are some design decisions that were influenced by time and scope constraints at the initial time of development.

## Getting Started

Getting started is easy, if you have some familiarity with Git and PowerShell.

### Requirements

* OS Requirements: older versions *may* work, but have not been tested.
  * Windows 10 Build 1803 or newer
  * Windows Server 2012 R2 or newer
* PowerShell Version 5.1+
* Remote Server Administration Tools + ActiveDirectory PowerShell Module.

### Get and build the module

```powershell
PS> git clone https://github.com/SmartResponse-Framework/SmartResponse.Framework
PS> cd SmartResponse.Framework
PS> .\New-TestBuild.ps1
```

You should now have a working copy of the module in your current PowerShell environment!

:hammer: For more on how **module builds** work, please review the [Build Process](build/readme.md).

---------

## How to Contribute

SmartResponse.Framework has a `master` branch for stable releases and a `develop` branch for daily development. New features and fixes are always submitted to the `develop` branch.

This project follows standard [GitHub flow](https://guides.github.com/introduction/flow/index.html). Please learn and be familiar with how to use Git, how to create a fork of the repository, and how to submit a Pull Request. Contributors are likely willing to help you with using Git if you [ask questions in our slack](https://logrhythmcommunity.slack.com) channel `#smartresponse_framework`.

After you submit a PR, Project maintainers and contributors will review and discuss your changes, and provide constructive feedback. Once reviewed successfully, your PR will be merged into the `development` branch.

### Quick Guidelines

Here are a few simple rules and suggestions to remember when contributing to SmartResponse.Framework.

:no_entry: Do not commit code that you didn't personally write.

:no_entry: [Do not use Write-Output](https://github.com/PoshCode/PowerShellPracticeAndStyle/issues/#issuecomment-236727676).

:ballot_box_with_check: File names must match the cmdlet name exactly, or will not be imported by the module.

:ballot_box_with_check: Always use [**approved PowerShell verbs**](https://docs.microsoft.com/en-us/powershell/developer/cmdlet/proved-verbs-for-windows-powershell-commands)!

:ballot_box_with_check: Try to include Pester tests along with your changes, or relevant updates to existing Pester tests.

:ballot_box_with_check: Add [comment-based help](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-5.1) for your commands.

:heavy_check_mark: Please try to keep your PRs focused on a single topic and of a reasonable size.

:heavy_check_mark: Please try to write simple and descriptive commit messages.

:heavy_check_mark: Use or follow the general style provided by the templates found in the `docs` directory.

:heavy_check_mark: Try to use [standard cmdlet parameter names](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/andard-cmdlet-parameter-names-and-types?view=powershell-5.1) wherever possible.

:heavy_check_mark: Generally avoid the use of `[trap]` - use try/catch blocks instead. For more information on error handling, [this post is highly recommended](https://powershellexplained.com/2017-04-10-Powershell-exceptions-everything-you-ever-wanted-to-know).

### About Command Output

For *displaying information to a user*, use `Write-Host` or `Write-IfVerbose` (included in this module). Never use `Write-Output` in any situation, unless there is a very specific reason to do so.

Use of `Write-Host` has been a controversial topic, in particular because of the limitations in doing anything with the output (redirect to `stdout`, etc) and confusion around what goes into the PowerShell pipeline. For the purposes of conveying information, we do **not** want that text getting into the pipeline.

Starting in Windows PowerShell 5.0, `Write-Host` is a wrapper for `Write-Information`, which is a structured information stream and can therefore can be used to transmit structured data between a script and its callers. This makes `Write-Host` useful for console messages without losing redirection functionality, and most importantly will not interfere with the PowerShell pipeline.

Example of redirecting `Write-Host`

```powershell
PS> Write-Host "Somebody said today that I’m lazy. I nearly answered him." 6> c:\tmp\out.txt
```

The `Write-IfVerbose` command in the SmartResponse.Framework module is implemented using `Write-Host`. It is intended to replace `Write-Verbose`, which lacks the formatting capability of `Write-Host` - while still making use of the `-Verbose` parameter provided by `CmdletBinding`.

### Command Naming Convention

Cmdlets in SmartResponse.Framework follow a standard naming convention.

`[Verb]-[Module][Class][Description]`

| Part      | Description |
| ----------- | ----------- |
| `Verb` | The first part of the function follows the [approved verb list](https://docs.microsoft.com/en-us/powershell/developer/cmdlet/approved-verbs-for-windows-powershell-commands) published by Microsoft. |
| `Module` | The second portion of the function name indicates that it is part of the SmartResponse.Framework module|
| `Classification` | The optional third part identifies if the function is related to PSRemoting, ActiveDirectory, Azure, or LogRhythm functionality.|
| `Name` | The remaining portion of the function name is descriptive.|

**Example**: `Add-SrfRMGroupMember`

> Adds a group member to a host using PSRemoting.

### Licensing

The SmartResponse.Framework project is under the Microsoft Public License unless a portion of code is explicitly stated elsewhere. See the [LICENSE.txt](LICENSE.txt) file for more details.

The project accepts contributions in "good faith" that they are not bound to a conflicting license. By submitting a PR you agree to distribute your work under the Project's license and copyright.
