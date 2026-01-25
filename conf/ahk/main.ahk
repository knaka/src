; Modifier:
;   #: Windows
;   !: Alt
;   ^: Ctrl
;   +: Shift

; ChgKey で Windows キーは右 Ctrl にマップしているので、Windows キー `#` は使われないはず

#Requires AutoHotkey v2.0
#SingleInstance force

; Not to loop mapping.
#UseHook

; ==========================================================================
;#region Helper functions

/**
 * Activate window by executable name, or launch if not running
 * @param {String} cmdPath - Path to the executable (e.g., "notepad.exe" or "C:\Program Files\App\app.exe")
 * @param {String} [launchArgs=""] - Optional command-line arguments including command itselfs
 */
ActivateOrRun(cmdPath, launchArgs := "") {
  SplitPath cmdPath, &base
  winTitle := "ahk_exe " base
  if WinExist(winTitle) {
    WinActivate(winTitle)
  } else {
    Run ((launchArgs = "")? cmdPath: launchArgs)
  }
}

ActivateChromeTab(domainPrefix) {
  if !WinExist("ahk_exe chrome.exe") {
    Run "chrome.exe"
    WinWait "ahk_exe chrome.exe"
  }
  WinActivate "ahk_exe chrome.exe"
  Sleep 100
  Send "^+a"
  Sleep 200
  SendText domainPrefix
  Sleep 100
  Send "{Enter}"
}

;#endregion  

; ==========================================================================
;#region Appication launching

; <!>!n:: ActivateOrRun("notepad.exe", "C:\foo.txt C:\bar.txt")

; List of Keys (Keyboard, Mouse and Controller) | AutoHotkey v2 https://www.autohotkey.com/docs/v2/KeyList.htm

; How to remove-uninstall Game Bar? - Microsoft Community https://answers.microsoft.com/en-us/xbox/forum/all/how-to-remove-uninstall-game-bar/77cfbfd5-1588-4d0f-b9c6-4c47ed899049
; Get-AppxPackage -PackageTypeFilter Bundle -Name "*Microsoft.XboxGamingOverlay*" | Remove-AppxPackage

; まともな自動化手段をください — セキュリティを強化するためのリモート デバッグ スイッチの変更  |  Blog  |  Chrome for Developers https://developer.chrome.com/blog/remote-debugging-port?hl=ja

; #Include JSON.ahk
; #Include Chrome.ahk

; Browser
<!>!b:: ActivateOrRun("chrome.exe", "--remote-debugging-port=9222")
; Editor
<!>!e:: ActivateOrRun("code.exe")
; Filer
<!>!f:: ActivateOrRun("explorer.exe")
; Shell
<!>!s:: ActivateOrRun("WindowsTerminal.exe", "wt.exe") ; ASCII.jp：Windows 11のコンソール処理について解説する https://ascii.jp/elem/000/004/141/4141418/
<!>!t:: ActivateChromeTab("x.com")
<!>!x:: ActivateChromeTab("claude.ai")

;#endregion  

; ===================================================s=======================
;#region Remapping

; WinActive - Syntax & Usage | AutoHotkey v2 https://www.autohotkey.com/docs/v2/lib/WinActive.htm
; #HotIf - Syntax & Usage | AutoHotkey v2 https://www.autohotkey.com/docs/v2/lib/_HotIf.htm

; Rotate Tab
<^Tab::Send "^{PgDn}"
<^+Tab::Send "^{PgUp}"

; Search next
>^g:: Send "{f3}"
+>^g:: Send "+{f3}"

<^m::Send "{Enter}"
<^g::Send "{Delete}"
<^h::Send "{Backspace}"

^\:: Send "+{Enter}"

; ろ
F13:: {
  SendText "``"
}

; ろ
+F13:: {
  SendText "~"
}

; ^ろ
^F13:: {
  SendText "````````"
  Send "+{Enter}+{Enter}"
  SendText "````````"
  Send "{Left}{Left}{Left}{Left}{Left}"
}

#HotIf WinActive("ahk_exe WindowsTerminal.exe")
; Vertical Move
<^p::Send "{Up}"
<^n::Send "{Down}"

; Rotate Tab
<^Tab::Send "^{Tab}"
+<^Tab::Send "+^{Tab}"

; Find
>^f::Send "+^{f}"

; New Tab
<!T::Send "^+{T}"
>^T::Send "^+{T}"
#HotIf

; 左右
<^s::Send "{Left}"
<^d::Send "{Right}"
; 左右選択
+<^s::Send "+{Left}"
+<^d::Send "+{Right}"
; ワード
<^a::Send "^{Left}"
<^f::Send "^{Right}"
; ワード選択
+<^a::Send "+^{Left}"
+<^f::Send "+^{Right}"
; 行頭・行末
<^>^a::Send "{Home}"
<^>^f::Send "{End}"
; 行頭・行末選択
<^>^+f::Send "+{End}"
<^>^+a::Send "+{Home}"

#HotIf !WinActive("ahk_exe WindowsTerminal.exe")
; 上下
<^e::Send "{Up}"
<^x::Send "{Down}"
; 上下選択
<^+e::Send "+{Up}"
<^+x::Send "+{Down}"
; ページ
<^r::Send "{PgUp}"
<^c::Send "{PgDn}"
; ページ選択
<^+r::Send "+{PgUp}"
<^+c::Send "+{PgDn}"
; 文頭・文末
<^>^r::Send "^{Home}"
<^>^c::Send "^{End}"
; 文頭・文末選択
<^>^+r::Send "^+{Home}"
<^>^+c::Send "^+{End}"
#HotIf

#HotIf WinActive("ahk_exe Code.exe")
; Multi-Cursor
<^+w:: Send "!^{Up}"
<^+z:: Send "!^{Down}"
; Rename...
+>^n::Send "{f2}"
; Open は、Shift + 右 Ctrl で、Ctrl + P を send
+>^o:: Send "^{p}"
#HotIf

;#endregion  

; ==========================================================================
;#region  左 Alt + key を Ctrl + key にマップ（Mac の左 Cmd + key 相当のマップ）

<!a:: Send "^{a}"
<!b:: Send "^{b}"
<!c:: Send "^{c}"
<!d:: Send "^{d}"
<!e:: Send "^{e}"
<!f:: Send "^{f}"
<!g:: Send "^{g}"
<!h:: Send "^{h}"
<!i:: Send "^{i}"
<!j:: Send "^{j}"
<!k:: Send "^{k}"
<!l:: Send "^{l}"
<!m:: Send "^{m}"
<!n:: Send "^{n}"
<!o:: Send "^{o}"
<!p:: Send "^{p}"
<!q:: Send "^{q}"
<!r:: Send "^{r}"
<!s:: Send "^{s}"
<!t:: Send "^{t}"
<!u:: Send "^{u}"
<!v:: Send "^{v}"
<!w:: Send "^{w}"
<!x:: Send "^{x}"
<!y:: Send "^{y}"
<!z:: Send "^{z}"

;#endregion  

; ==========================================================================
;#region  右 Ctrl + key を Ctrl + key にマップ（Mac の右 Cmd + key 相当のマップ）

>^a:: Send "^{a}"
>^b:: Send "^{b}"
>^c:: Send "^{c}"
>^d:: Send "^{d}"
>^e:: Send "^{e}"
>^f:: Send "^{f}"
; >^g:: Send "^{g}" ; Search next にマップ
>^h:: Send "^{h}"
>^i:: Send "^{i}"
>^j:: Send "^{j}"
>^k:: Send "^{k}"
;>^l:: Send "^{l}" ; Hibernate にマップ
>^l:: {
  Run "shutdown /h"
}
>^m:: Send "^{m}"
>^n:: Send "^{n}"
>^o:: Send "^{o}"
>^p:: Send "^{p}"
>^q:: Send "^{q}"
>^r:: Send "^{r}"
>^s:: Send "^{s}"
>^t:: Send "^{t}"
>^u:: Send "^{u}"
>^v:: Send "^{v}"
>^w:: Send "^{w}"
>^x:: Send "^{x}"
>^y:: Send "^{y}"
>^z:: Send "^{z}"

;#endregion  

; ==========================================================================
;#region 機能

; 左 Alt + / → Ctrl + / (Comment)
<!/:: Send "^{/}"

; Hash value in 7 digits
+>^h:: {
  n := Random(0, 268435455)
  SendText Format("{:07x}", n)
}

; Date serial (YYYYMMDD + day progress percentage)
+>^s:: {
  now := A_NowUTC
  hour := Integer(SubStr(now, 9, 2))
  minute := Integer(SubStr(now, 11, 2))
  dayProgress := Format("{:02d}", ((hour * 60 + minute) * 100) // (24 * 60))
  SendText FormatTime(now, "yyyyMMdd") dayProgress
}

; ISO 8601 datetime (local time with timezone)
+>^d:: {
  now := A_Now
  utc := A_NowUTC
  ; Calculate timezone offset in minutes
  tzOffsetMinutes := DateDiff(now, utc, "Minutes")
  tzHours := Abs(tzOffsetMinutes) // 60
  tzMins := Mod(Abs(tzOffsetMinutes), 60)
  tzSign := tzOffsetMinutes >= 0 ? "+" : "-"
  ; Format: YYYY-MM-DDTHH:MM:SS+HH:MM
  iso8601 := FormatTime(now, "yyyy-MM-ddTHH:mm:ss") . tzSign . Format("{:02d}:{:02d}", tzHours, tzMins)
  SendText iso8601
}

; Open and Closing Quotation Marks, then move to left
![:: Send "“”{Left}"

; &Variable Expansion (parameter expansion)
!v:: Send '"${{}}{}}"{Left}{Left}'

; &Command Substitution \"$(...)\"
!c:: Send '"$()"{Left}{Left}'

;#endregion  

; ==========================================================================
;#region JetBrains

#HotIf WinActive("ahk_exe Idea64.exe")
<^Tab::Send "!{Right}"
<^+Tab::Send "!{Left}"
>^:: Send "^{f4}"
<!w:: Send "^{f4}"
>^w:: Send "^{f4}"

; Go to file...
+>^o::Send "^+{n}"
; Rename...
+>^n::Send "+{f6}"
; Replace...
>^r::Send "^{h}"
; Find in files...
+>^f::Send "^+{f}"
; Replace in files... (Not assigned in default)
+>^r::Send "^+{r}"
; Clone Caret Above / Below (Not assigned in default)
<^+w::Send "^+{w}"
<^+z::Send "^+{z}"
; Copilot Apply ... → Alt  + Tab
#HotIf

;#endregion  

; ==========================================================================
;#region Mouse


LAlt & LButton:: Send "^{LButton}"

;#endregion  

; ==========================================================================
;#region IME

; Autohotkey v2.0のIME制御用 関数群 IMEv2.ahk #AutoHotkey - Qiita https://qiita.com/kenichiro_ayaki/items/d55005df2787da725c6f
; k-ayaki/IMEv2.ahk: Autohotkey v2.0 でIMEを制御する関数群 https://github.com/k-ayaki/IMEv2.ahk
#include imev2.ahk

; オン・オフ
>!Space:: IME_SET(1)
<^Space:: IME_SET(0)

; 右 Cmd + Space で Escape
>^Space:: Send "{Escape}"

; 左 Cmd + Space で backtick
<!Space:: {
  IME_SET(0)
  Send Chr(0x60)
}

; 左 Cmd + Shift + Space で Tilde
<!+Space:: {
  IME_SET(0)
  Send Chr(0x7e)
}

<^`::  {
  SendText "Hello"
}

;#endregion
