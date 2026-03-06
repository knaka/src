---
description: Proofread a document, string or comments in code and correct.
user-invokable: true
---

When I ask to "/proof [instruction]", follow these instructions:

Proofread the natural language statements, strings or comments in this file and correct any errors. If you find a sentence written in Japanese, translate it into English and replace it. Do not search for or examine other files - work only on this file.

When `$_` is passed as an argument, the target is determined as follows:
- If text is selected, target the selected lines (tagged with `ide_selection`).
- Otherwise, target the currently open file (tagged with `ide_opened_file`).
