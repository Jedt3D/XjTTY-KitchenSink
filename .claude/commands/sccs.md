Milestone completion: Summarize, update docs, and commit.

Do the following steps in order:

1. **Summarize** — Write a short summary of what was accomplished in this milestone (what was built, what was fixed, what's new). Show it to the user.

2. **Update CLAUDE.md** — Update the project's `CLAUDE.md` at the project root with:
   - Current project status and completed phases
   - Key architecture decisions and patterns
   - Known Xojo gotchas encountered and resolved
   - Keep it concise and useful for future sessions

3. **Update changelog.md** — Append a new entry to `changelog.md` at the project root with:
   - Date and version/phase
   - What was added, changed, or fixed
   - Follow Keep a Changelog format

4. **Git commit** — Stage all relevant changes and create a commit:
   - Stage modified and new files (skip any temp/build artifacts)
   - Write a clear commit message summarizing the milestone
   - Include `Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>`

Do NOT push to remote. Show the user the commit hash when done.
