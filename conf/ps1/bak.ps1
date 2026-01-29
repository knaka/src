function symlink {
  param (
    [string]$target
    , [string]$link_path
  )
  # Does not work in 5.1 // windows - Symlinks cannot be created in Powershell 5.1 but can be created by Powershell 7 and Command Prompt - Stack Overflow https://stackoverflow.com/questions/66609154/symlinks-cannot-be-created-in-powershell-5-1-but-can-be-created-by-powershell-7   
  #New-Item -ItemType SymbolicLink -Path $link_path -Target $target
  cmd.exe /c mklink "$link_path" "$target"
}

function aws_set_profile {
  param (
    [string]$prf
  )
  $env:AWS_PROFILE = $prf
}

New-Alias -Name aws-set-profile -Value aws_set_profile -Force

function cd {
  param (
    [string]$path
  )
  if (-not $path) {
    $path = $HOME
  }
  Set-Location $path
}

# powershell - How to turn off syntax highlighting in console? - Stack Overflow https://stackoverflow.com/questions/35246709/how-to-turn-off-syntax-highlighting-in-console
Set-PSReadLineOption -Colors @{
  # None               = 'Black'
  Comment            = 'Black'
  Keyword            = 'Black'
  String             = 'Black'
  Command            = 'Black'
  Number             = 'Black'
  Member             = 'Black'
  Operator           = 'Black'
  Type               = 'Black'
  Variable           = 'Black'
  Parameter          = 'Black'
  ContinuationPrompt = 'Black'
  Default            = 'Black'
}

# If the shell is PowerShell 7, not PowerShell 5
if ($PSVersionTable.PSVersion.Major -ge 7) {
  Set-PSReadLineOption -PredictionSource None
}

# How can I modify PowerShell tab-completion to proritise certain file types over others? - Stack Overflow https://stackoverflow.com/questions/75509668/how-can-i-modify-powershell-tab-completion-to-proritise-certain-file-types-over
if ($PSVersionTable.PSVersion.Major -ge 7) {

  # Get-Content function:TabExpansion2
  function TabExpansion2 {
    <# Options include:
        RelativeFilePaths - [bool]
            Always resolve file paths using Resolve-Path -Relative.
            The default is to use some heuristics to guess if relative or absolute is better.

      To customize your own custom options, pass a hashtable to CompleteInput, e.g.
            return [System.Management.Automation.CommandCompletion]::CompleteInput($inputScript, $cursorColumn,
                @{ RelativeFilePaths=$false }
    #>

    [CmdletBinding(DefaultParameterSetName = 'ScriptInputSet')]
    [OutputType([System.Management.Automation.CommandCompletion])]
    Param(
        [Parameter(ParameterSetName = 'ScriptInputSet', Mandatory = $true, Position = 0)]
        [AllowEmptyString()]
        [string] $inputScript,

        [Parameter(ParameterSetName = 'ScriptInputSet', Position = 1)]
        [int] $cursorColumn = $inputScript.Length,

        [Parameter(ParameterSetName = 'AstInputSet', Mandatory = $true, Position = 0)]
        [System.Management.Automation.Language.Ast] $ast,

        [Parameter(ParameterSetName = 'AstInputSet', Mandatory = $true, Position = 1)]
        [System.Management.Automation.Language.Token[]] $tokens,

        [Parameter(ParameterSetName = 'AstInputSet', Mandatory = $true, Position = 2)]
        [System.Management.Automation.Language.IScriptPosition] $positionOfCursor,

        [Parameter(ParameterSetName = 'ScriptInputSet', Position = 2)]
        [Parameter(ParameterSetName = 'AstInputSet', Position = 3)]
        [Hashtable] $options = $null
    )

    End
    {
        if ($psCmdlet.ParameterSetName -eq 'ScriptInputSet')
        {
            # return [System.Management.Automation.CommandCompletion]::CompleteInput(
            $completion = [System.Management.Automation.CommandCompletion]::CompleteInput(
                <#inputScript#>  $inputScript,
                <#cursorColumn#> $cursorColumn,
                <#options#>      $options)
        }
        else
        {
            # return [System.Management.Automation.CommandCompletion]::CompleteInput(
            $completion = [System.Management.Automation.CommandCompletion]::CompleteInput(
                <#ast#>              $ast,
                <#tokens#>           $tokens,
                <#positionOfCursor#> $positionOfCursor,
                <#options#>          $options)
        }

        # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_arrays?view=powershell-7.4&viewFallbackFrom=powershell-7.3#where
        # 比較演算子について - PowerShell | Microsoft Learn https://learn.microsoft.com/ja-jp/powershell/module/microsoft.powershell.core/about/about_comparison_operators?view=powershell-7.4
        $exeMatches, $nonExeMatches = $completion.CompletionMatches
            .Where({
              $_.CompletionText -Like "*.cmd" -Or
              $_.CompletionText -Like "*.exe" -Or
              $_.CompletionText -Like "*.bat"
            }, "Split")
        $completion.CompletionMatches = @()
        # Can be null.
        if ($null -ne $nonExeMatches) {
          $completion.CompletionMatches += @($nonExeMatches)
        }
        # Can be null.
        if ($null -ne $exeMatches) {
          $completion.CompletionMatches += @($exeMatches)
        }
        return $completion
    }
  }
}
