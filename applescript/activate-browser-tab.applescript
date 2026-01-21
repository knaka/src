-- どうやら *.scpt はソースを持った compiled binary、*.applescript は plain text だ。いずれも open(1) のデフォルト動作は `Script Editor.app` で開く。実行には結局 osascript(1) が必要らしい // applescript - Why am I getting "Error -1,752" when trying to save in Script Editor? - Ask Different https://apple.stackexchange.com/questions/215488/why-am-i-getting-error-1-752-when-trying-to-save-in-script-editor

-- *.scpt は osadecompile(1) でソースを extract できる // macos - Is there a way to extract contents from AppleScript file without using AppleScript editor? - Ask Different https://apple.stackexchange.com/questions/132901/is-there-a-way-to-extract-contents-from-applescript-file-without-using-applescri

-- 各アプリのリファレンスは「スクリプトエディタ」から見られる。「用語説明」は “dictionary” の訳なので、いまいち意味不明 // macos - How do I find out the applescript commands available for a particular app? - Ask Different https://apple.stackexchange.com/questions/46521/how-do-i-find-out-the-applescript-commands-available-for-a-particular-app

on run args
	-- set _browser to "arc"
	set _browser to "chrome"
	set _url_prefix to item 1 of args
	if _browser is "chrome" then
		my activate_chrome_tab(_url_prefix)
	else if _browser is "arc" then
		my activate_arc_tab(_url_prefix)
	else
		display alert "Unknwon browser ”" & _browser & "” given."
	end if
end run

on activate_chrome_tab(_url)
	tell application "Google Chrome"
		-- application が activate に respond するとは書かれていないがなぁ…	
		activate
		-- 複数形は良い感じに使えるのかな
		-- contain された名前とローカル変数がよく（「クラス名」と？）衝突する模様。なので _ を後置したのだが、良い方法はないんだろうか
		local window_
		-- window n: A window.
		--   elements
		--     contains `tabs`, contained by `application`. ← 後者はどういう意味だ？
		repeat with window_ in windows
			set tab_index_ to 1
			-- URL (text) : The url visible to the user.
			repeat with tab_ in tabs of window_
				if URL of tab_ starts with _url or title of tab_ starts with _url then
					-- active tab index (integer) : The index of the active tab.
					-- タブは自分の位置（index）を持っていないみたいなんで、順にインクリするしかないのか？
					set active tab index of window_ to tab_index_
					-- index (integer) : The index of the window, ordered front to back.
					-- ウィンドウを最前面へ
					set index of window_ to 1
					-- early return
					return
				end if
				set tab_index_ to tab_index_ + 1
			end repeat
		end repeat
		-- `open location` に相当するリファレンスが見あたらない。`open` のサブ機能がリファレンスに記述されていないんだろうか
		--   open v : Open a document.
		-- early return しなかった（当該 URL のタブが見つからなかった）ら、open the URL
		open location _url
	end tell
end activate_chrome_tab
