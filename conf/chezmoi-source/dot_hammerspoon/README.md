# Hammerspoon Configuration

## Hammerspoonが扱える自動化の種類

Hammerspoonは強力な自動化ツールですが、扱えるインターフェースには制限があります。

### Hammerspoonが直接扱えるもの

1. **Accessibility API (GUI Scripting相当)**
   - `hs.axuielement` - UI要素（ボタン、メニュー、テキストフィールドなど）へのアクセス
   - `hs.eventtap` - キーボード/マウスイベントの監視・生成
   - 低レベルなUI操作

2. **Application Control**
   - `hs.application` - アプリケーションの起動、終了、アクティブ化
   - `hs.window` - ウィンドウの配置、リサイズ、管理
   - システムレベルのアプリケーション制御

3. **その他システム機能**
   - ホットキー管理 (`hs.hotkey`)
   - URL起動 (`hs.urlevent`)
   - 通知 (`hs.notify`)
   - など

### Hammerspoonが直接扱えないもの

**アプリ固有のスクリプティングAPI (sdef)**
- 各アプリケーションが`.sdef`ファイルで定義している独自のオブジェクトモデル
- 例:
  - Google Chromeの`windows`, `tabs`, `URL`, `title`など
  - Mailの`messages`, `mailboxes`など
  - Finderの`folders`, `files`など

これらのアプリ固有APIにアクセスするには、AppleScriptまたはJavaScript for Automation (JXA)を経由する必要があります。

## 実装パターン

### パターン1: Hammerspoon単体で完結

ウィンドウ配置、ホットキー、キーストローク送信など、システムレベルの操作。

```lua
-- キーストロークの送信
hs.hotkey.bind({"cmd", "shift"}, "h", function()
  hs.eventtap.keyStrokes("hello")
end)
```

### パターン2: ハイブリッド実装

アプリ固有のAPI操作が必要な場合、HammerspoonからAppleScript/JXAを呼び出す。

```lua
function activateChromeTab(urlPrefixes)
  local chrome = hs.application.find("Google Chrome")

  -- Hammerspoonで処理できる部分
  if not chrome then
    hs.urlevent.openURL(urlPrefixes[1])
    return
  end
  chrome:activate()

  -- アプリ固有API（タブ操作）はJXAで処理
  local script = string.format([[...]], hs.json.encode(urlPrefixes))
  hs.osascript.javascript(script)
end
```

## AppleScriptとの比較

### AppleScriptが扱える2つの仕組み

1. **Application Scripting (sdef API)**
   - アプリが公開しているオブジェクトモデル
   - 高レベルで意味的な操作
   - 例: `tell application "Google Chrome"` → `windows`, `tabs`

2. **GUI Scripting (System Events経由)**
   - Accessibility APIを使った物理的なUI操作
   - 低レベルで直接的な操作
   - 例: `tell application "System Events"` → `click button`

### まとめ

- **Hammerspoon**: Accessibility API + アプリケーション制御（限定的）
- **AppleScript/JXA**: Accessibility API + アプリケーション制御 + アプリ固有API（完全）

Hammerspoonは「外から見えるUI」や「システムレベルの操作」は得意だが、「アプリ内部のデータ構造」にアクセスするには、AppleScript/JXAを経由する必要がある。

両者を組み合わせることで、最も効率的な自動化を実現できる。
