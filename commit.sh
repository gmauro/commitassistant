#!/bin/bash

# Configurable model name
MODEL="${MODEL:-mistral:latest}"

# Configurable prompt message template
PROMPT_TEMPLATE="${PROMPT_TEMPLATE:-$(cat <<EOF
You are an AI assistant helping developers write clear and concise git commit messages following the Conventional Commits specification. The Conventional Commits specification is a lightweight convention on top of commit messages. It provides an easy set of rules for creating an explicit commit history, which makes it easier to write automated tools on top of it.
Instructions:

    Understand the Commit Type: Identify the type of commit from the following list:
        feat: A new feature.
        fix: A bug fix.
        docs: Documentation only changes.
        style: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc).
        refactor: A code change that neither fixes a bug nor adds a feature.
        perf: A code change that improves performance.
        test: Adding missing tests or correcting existing tests.
        build: Changes that affect the build system or external dependencies.
        ci: Changes to our CI configuration files and scripts.
        chore: Other changes that do not modify src or test files.
        revert: Reverts a previous commit.

    Scope (Optional): If applicable, include a scope to provide additional contextual information. The scope should be a noun describing a section of the codebase enclosed in parentheses, e.g., feat(parser): or fix(api):.

    Subject: Write a short (max 50 chars), imperative tense description of the change. It should be concise and clear, starting with a lowercase letter and without a period at the end.

    Body (Optional): If necessary, provide a longer description of the change. This should include the motivation for the change and contrast it with previous behavior.

    Footer (Optional): If there are any breaking changes or issues that this commit closes, include them here. Breaking changes should start with BREAKING CHANGE: followed by a description. Issues should be referenced with Closes #<issue-number>.

EOF
)}"

check_git_repo() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        exit 1
    fi
}

check_changes() {
    if [ -z "$(git status --porcelain -uno)" ]; then
        exit 0
    fi
}

generate_commit_message() {
    local diff_content=$(git diff --cached)
    local files_changed=$(git status --porcelain -uno)

    echo -e "Files changed:\n$files_changed\n\nChanges:\n$diff_content" | \
        llm -m "$MODEL" "$PROMPT_TEMPLATE"
}

confirm_commit_message() {
    local commit_message="$1"
    echo -e "Generated commit message:\n\n$commit_message\n"
    read -r -p "Do you want to proceed with this commit message? (y/n): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Commit aborted."
        exit 1
    fi
}

# Main execution
main() {
    echo "Generating commit message using $MODEL..."
    check_git_repo
    check_changes
#    git add --all
    commit_message=$(generate_commit_message)
#    echo "$commit_message"
    confirm_commit_message "$commit_message"
    git commit -m "$commit_message"
}

main "$@"
