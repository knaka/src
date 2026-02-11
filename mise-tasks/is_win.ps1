#!/usr/bin/env pwsh -NoProfile

if ($IsWindows) {
  Write-Output "This is Windows."
} elseif ($IsMacOS) {
  Write-Output "No. This is MacOS."
} elseif ($IsLinux) {
  Write-Output "No. This is Linux."
} else {
  Write-Output "This is a OS."
}
