---
description: "Rewrite git commits in git history with an appropriate message"
---

Rewrite a git commit with an appropriate message. The commit message should follow the "Conventional Commits" format and use the following template. Do NOT add any "Generated with Claude Code" or "Co-Authored-By: Claude" footers.

```
<type>[optional scope]: <description>

[optional body]
```

IMPORTANT: You must analyze ONLY the difference. Do not use any memory from the conversation. Treat each commit as if you're seeing these changes for the first time with no context about how or why they were made.
