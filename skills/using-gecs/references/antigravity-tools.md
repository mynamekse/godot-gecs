# Antigravity Tool Mapping for GECS Skills

In Google Antigravity, skills activate automatically through semantic matching against the frontmatter `description` field.

| Capability | Antigravity Usage |
|---|---|
| Read File | Native `read_file` tool |
| Create File | Native `write_file` tool |
| Edit File | Native `edit_file` tool |
| Run Commands | Native `run_command` tool (PowerShell on Windows, Bash on POSIX) |
| Skill Discovery | Semantic trigger matching via `skills/<name>/SKILL.md` |

