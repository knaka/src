-- どうやら *.scpt はソースを持った compiled binary、*.applescript は plain text だ。いずれも open(1) のデフォルト動作は `Script Editor.app` で開く。実行には結局 osascript(1) が必要らしい // applescript - Why am I getting "Error -1,752" when trying to save in Script Editor? - Ask Different https://apple.stackexchange.com/questions/215488/why-am-i-getting-error-1-752-when-trying-to-save-in-script-editor

-- *.scpt は osadecompile(1) でソースを extract できる // macos - Is there a way to extract contents from AppleScript file without using AppleScript editor? - Ask Different https://apple.stackexchange.com/questions/132901/is-there-a-way-to-extract-contents-from-applescript-file-without-using-applescri

-- 各アプリのリファレンスは「スクリプトエディタ」から見られる。「用語説明」は “dictionary” の訳なので、いまいち意味不明 // macos - How do I find out the applescript commands available for a particular app? - Ask Different https://apple.stackexchange.com/questions/46521/how-do-i-find-out-the-applescript-commands-available-for-a-particular-app

on run args
	set _browser to "chrome"
	if _browser is "chrome" then
		my activate_chrome_tab(args)
	else
		display alert "Unknown browser " & _browser & " given."
	end if
end run

on activate_chrome_tab(args_)
  -- chrome/browser/ui/cocoa/applescript/scripting.sdef - chromium/src.git - Git at Google https://chromium.googlesource.com/chromium/src.git/+/lkgr/chrome/browser/ui/cocoa/applescript/scripting.sdef
	-- application: “The application&apos;s top-level scripting object.”
	tell application "Google Chrome"
		activate
		local window_
		local url_prefix_
		-- Try each URL prefix in order
		repeat with url_prefix_ in args_
			-- window: “A window.”
			repeat with window_ in windows
				set tab_index_ to 1
				-- tab: “A tab.”
				repeat with tab_ in tabs of window_
					-- URL: “The url visible to the user.”
					if URL of tab_ starts with url_prefix_ or title of tab_ starts with url_prefix_ then
						-- active tab index (integer): “The index of the active tab.”
						set active tab index of window_ to tab_index_
						-- index (integer): “The index of the window, ordered front to back.”
						set index of window_ to 1
						-- early return when first match is found
						return
					end if
					set tab_index_ to tab_index_ + 1
				end repeat
			end repeat
		end repeat
		-- No matching tab found, open the first URL prefix
		-- open: “Open a document.”
		open location (item 1 of args_)
	end tell
end activate_chrome_tab
