"""
DO NOT MANUALLY RUN THIS SCRIPT.
---------------------------------

This script is designed to generate and push a CL file that can be later compiled.
The body of the changelog is determined by the description of the PR that was merged.

If a commit is pushed without being associated with a PR, or if a PR is missing a CL,
the script is designed to exit as a failure. This is to help keep track of PRs without
CLs and direct commits. See the relating comments in the below source to disable this function.

This script depends on the tags.yml file located in the same directory. You can use that
file to configure the exact tags you'd like this script to use when generating changelog entries.
If this is being used in a /tg/ or Bee downstream, the default tags should work.

Expected environmental variables:
-----------------------------------
GIT_NAME: Username of the GitHub account to be used as the committer (User provided)
GIT_EMAIL: Email associated with the above (User provided)
GITHUB_REPOSITORY: GitHub action variable representing the active repo (Action provided)
GITHUB_TOKEN: A snowflake token generated by the action, this will allow the action to push the changes (User provided, action generated)
GITHUB_SHA: The SHA associated with the commit that triggered the action (Action provided)
"""
import io
import os
import re
from pathlib import Path

from github import Github, InputGitAuthor
from ruamel.yaml import YAML

# Regex patterns to match the changelog entries and their types
HEADER_RE = re.compile(r"(?::cl:|🆑)\s*\r?\n(.+)$", re.DOTALL)
ENTRY_RE = re.compile(r"^\s*[*-]?\s*(bugfix|wip|tweak|soundadd|sounddel|rscadd|rscdel|imageadd|imagedel|spellcheck|experiment|tgs):\s*(\S[^\n\r]+)\r?$", re.MULTILINE)

git_email = os.getenv("GIT_EMAIL")
git_name = os.getenv("GIT_NAME")
repo_name = os.getenv("GITHUB_REPOSITORY")
token = os.getenv("GITHUB_TOKEN")
sha = os.getenv("GITHUB_SHA")

git = Github(token)
repo = git.get_repo(repo_name)
commit = repo.get_commit(sha)
pr_list = commit.get_pulls()

if not pr_list.totalCount:
    print("Direct commit detected")
    exit(1)  # Change to '0' if you do not want the action to fail when a direct commit is detected

pr = pr_list[0]

pr_body = pr.body
pr_number = pr.number
pr_author = pr.user.login

write_cl = {}
changes = []

# Function to parse the body of the PR for changelog entries
def parse_body_changelog(body):
    content = HEADER_RE.search(body)
    if not content:
        return []

    content = content.group(1)
    matches = ENTRY_RE.findall(content)
    entries = []
    for match in matches:
        entry_type, description = match
        entries.append({"type": entry_type, "description": description.strip()})
    return entries

# Parse the PR body to get the changelog entries
changes = parse_body_changelog(pr_body)

if not changes:
    print("No CL found!")
    exit(1)  # Change to '0' if you do not want the action to fail when no CL is provided

write_cl["author"] = pr_author
write_cl["delete-after"] = True
write_cl["changes"] = changes

if write_cl["changes"]:
    yaml = YAML()
    changelog_path = Path(f"html/changelogs/AutoChangeLog-pr-{pr_number}.yml")
    
    with changelog_path.open("w") as cl_file:
        yaml.dump(write_cl, cl_file)

    # Push the newly generated changelog to the master branch so that it can be compiled
    repo.create_file(
        changelog_path.as_posix(),
        f"Automatic changelog generation for PR #{pr_number} [ci skip]",
        content=changelog_path.read_text(),
        branch="Bleeding-Edge",
        committer=InputGitAuthor(git_name, git_email),
    )
    print("Done!")
else:
    print("No CL changes detected!")
    exit(0)  # Change to a '1' if you want the action to count lacking CL changes as a failure
