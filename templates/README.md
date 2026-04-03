# Templates

Copy-paste templates for setting up Claude Code in your Java project.

## CLAUDE.md.template

The main project briefing file that Claude loads at the start of every session.

**Setup (5 minutes):**
1. Copy to your Java project root as `CLAUDE.md`
2. Fill in the `[REPLACE: ...]` placeholders
3. Delete the comment block at the top

**What it does:**
- Tells Claude your Java/Spring Boot version so it uses the right idioms
- Points Claude to your build commands so it can verify changes
- Sets preferred skills for common tasks (review, test, security scan)
- Lists environment variables so Claude never hardcodes them
- Defines what Claude should NOT do in your project

## settings.json.template

Pre-approved shell commands so Claude doesn't prompt for permission on every build or test run.

**Setup:**
1. Copy to your Java project root as `.claude/settings.local.json`
2. Adjust the `allow` list to match your build tool (Maven or Gradle)
3. Keep the `deny` list — it blocks force-push, hard reset, and test-skip flags

**Note:** `settings.local.json` is gitignored by default. Use `settings.json` if you want to commit these approvals for the whole team.

## java-pr-review.yml

GitHub Actions workflow for automated Java PR reviews.

**Setup:**
1. Copy to `.github/workflows/java-pr-review.yml` in your Java project
2. Add `ANTHROPIC_API_KEY` to your repo secrets
3. Every PR touching `.java` or build files gets a security + performance + code quality review posted as a comment

See the [main README](../README.md#github-actions--automated-pr-review) for details.
