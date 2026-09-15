---
name: pr-review
description: Review a GitHub pull request the way this user does it. Use when asked to review, look at, or give feedback on a PR, or when given a PR number or URL. Checks the PR out locally in the current jj workspace, explains the change in plain terms, discusses it with the user, then drafts and posts a review with line-anchored comments and an approve or request-changes verdict.
argument-hint: "<PR number or URL> [repo]"
---

# PR review

This is a conversation that ends in a posted review, not a report. The user
wants to understand the PR the way a colleague would explain it at a
whiteboard, talk it through, and then post something an author can act on.
Nothing goes to GitHub until the user says post.

Repo mechanics follow the `jj` skill. Read it if you have not.

## 1. Get the PR into the workspace

1. `gh pr view <n> --json number,title,body,author,isDraft,baseRefName,headRefName,headRefOid,isCrossRepository,url,files,commits,reviews,comments`
   and the line comments from `gh api /repos/{owner}/{repo}/pulls/<n>/comments`.
   Read the description and every linked issue before reading any code. The
   description is the author's claim about intent; the review measures the
   code against it. Read every earlier review and comment, including the
   user's own, and the author's replies: the review builds on that discussion
   rather than restarting it.
2. Note where you are: `jj log -r @ --no-graph -T 'change_id'`. You return
   here at the end.
3. Same-repo PR: `jj git fetch -b <headRefName>`, then
   `jj new <headRefName>@origin`. You now have an empty `@` on top of the PR
   head, so the whole tree is on disk to read with its context. The author's
   bookmark is immutable in this config; do not rewrite anything.
4. Fork PR (`isCrossRepository`): jj cannot fetch it without adding the fork as
   a remote. Work from `gh pr diff <n>` and `gh pr view` instead, and say so.
5. The diff GitHub shows is `gh pr diff <n>`. For per-commit structure,
   `jj log -r '<baseRefName>@origin..<headRefName>@origin'`.

## 2. Understand, then explain

Read the whole diff plus enough surrounding code to know what the changed
functions are for and who calls them. Look at the codebase's own conventions
for the areas touched: CLAUDE.md or similar files in the changed directories,
neighboring code that solves the same kind of problem, existing tests. Do not
run tests, linters, type checkers, or builds: the author and CI cover that, and
it is not what this review is for. Having the code on disk is for reading it
with its context, not for verifying it mechanically.

Then tell the user, in prose, in this order:

- **What the PR is trying to accomplish**, in one or two sentences, in the
  user's terms rather than the author's. If the description and the code
  disagree, say what the code actually does.
- **How it does it.** Walk the change in the order that makes it make sense,
  which is usually not file order: the core mechanism first, then what had to
  change around it, then tests and plumbing. Name the key decisions the author
  made and any alternatives they evidently rejected.
- **Where it falls short**, judged against the PR's own goal and the
  codebase's own practices. For each issue: what it is, why it matters for
  what this PR is trying to do, and what you would do instead. Cite the
  codebase's convention when the issue is one, by pointing at the file that
  establishes it. Say which issues you consider blocking and which are
  judgment calls, and why.
- **How earlier feedback was handled**, when there is any. For each point a
  reviewer raised before, whether the author addressed it, pushed back, or
  left it, and whether the resolution actually holds up in the code. This is
  what the user needs most when it is their own earlier review.
- **What is out of scope**: pre-existing problems you noticed that the PR did
  not create. Mention them to the user; they do not go in the review unless
  the user wants them there.

No severity labels, emoji, or tables of findings. Do not flag things a linter
or formatter would catch, or matters of taste the codebase has not settled.

## 3. Discuss

Now the user will ask questions, push back, or want to look at something. Stay
in the workspace, read more code, trace call paths, explain. Update your view
of the issues as you go and say when you change your mind. When the user
disagrees and the code still supports your reading, say so and show the
evidence rather than folding; the user is deciding what to post, not looking
for agreement. Do not draft the review until the user moves toward it.

## 4. Draft the review

The verdict is almost always one of two:

- **Approve** means the PR is ready to merge, possibly after the author acts on
  some comments, and the user does not need another look. Comments under an
  approval are at the author's discretion. If a few are things the user
  strongly recommends fixing before merge, say so in the body, still without
  making them blocking.
- **Request changes** means there is a finite, identifiable set of changes the
  user wants made, and the user wants a second look at how they were
  addressed. The body lists that set so the author knows exactly what clears
  it.
- **Comment only** is for draft PRs (`isDraft`) and early work, or when the
  user explicitly does not want to give a verdict. Do not default to it.

Draft in two parts and show both to the user:

- **Line comments**, one per issue that lives at a specific place in the diff.
  Anchor to the new file's line numbers (`side: RIGHT`); use `side: LEFT` with
  old line numbers only for a deleted line. Use `start_line` for a range. The
  line must be inside a diff hunk or GitHub rejects the whole review. Take new
  line numbers from the checked-out file (`grep -n` in the workspace), not by
  counting from hunk headers, then confirm the line is in a hunk of
  `gh pr diff`. Each comment: the issue, why it matters here, and the
  suggestion, in the user's voice. Author-facing, so no references to the
  conversation.
- **Body**: as short as the verdict allows. The verdict in plain words, then
  only what does not anchor to a line: cross-cutting concerns, the enumerated
  change set for a request-changes, or the strongly-recommended items under an
  approve. If a point cannot be tied to a line, it goes here with its file
  path, not in a forced line comment. An approval with nothing cross-cutting
  to say can be one sentence.

The posted review is actionable text only. No opening praise, no summary of
what the PR does back to its author, no restating what it gets right, no
remarks about tests passing or checks being green, and no mention of anything
mechanical having been run or not run. Every sentence should tell the author
something to do, decide, or know about a problem. If a line comment can be
one sentence, it is one sentence.

Show the draft in prose, never as a payload: the verdict, the body, then each
line comment as `path:line` followed by its text. Iterate until the user says
post.

## 5. Post

Post the body, verdict, and all line comments as one review, so the author
gets a single notification and the comments arrive attached to the verdict.
If a GitHub MCP server with a create-review tool is available, use it. Otherwise
one API call does it:

```sh
gh api --method POST /repos/{owner}/{repo}/pulls/<n>/reviews --input review.json
```

where `review.json`, written in the scratchpad directory, holds `commit_id`
(the `headRefOid` from step 1, so comments pin to the revision you reviewed),
`event` (`APPROVE`, `REQUEST_CHANGES`, or `COMMENT`), `body`, and `comments`,
each with `path`, `line`, `side`, optional `start_line`, and `body`. If GitHub
rejects it, the usual cause is a line outside the diff; fix the anchor or move
that comment into the body, and post again. Confirm with the review URL.

## 6. Return

`jj edit <the change id from step 1>`. jj abandons the empty review `@` on its
own when you edit away from it. Tell the user you are back where they were.
