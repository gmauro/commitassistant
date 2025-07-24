#!/bin/bash

# Configurable model name
MODEL="${MODEL:-mistral-nemo:12b-instruct-2407-q3_K_L}"

# Configurable prompt message template
PROMPT_TEMPLATE="${PROMPT_TEMPLATE:-$(cat <<EOF
You are an AI assistant designed to help developers write clear and concise Git commit messages following the Conventional Commits specification.
Your task is to suggest a commit message to the developer that adheres to the following structure and guidelines:

    Subject Line:
        The subject line must start with the type of the commit.
        The subject line must be no more than 50 characters long.
        The type must be one of the following:
            feat: A new feature
            fix: A bug fix
            docs: Documentation only changes
            style: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
            refactor: A code change that neither fixes a bug nor adds a feature
            perf: A code change that improves performance
            test: Adding missing tests or correcting existing tests
            chore: Changes to the build process or auxiliary tools and libraries such as documentation generation

    Body:
        The body must provide a longer description of the change.
        The body must include the motivation for the change and contrast this with previous behavior.

    Footer (optional):
        The footer can include information about breaking changes and is also the place to reference GitHub issues that this commit closes.

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
    local previous_log=$(git log -n 10 --oneline)

    echo -e "Files changed:\n$files_changed\n\nChanges:\n$diff_content\n\nPrevious log:\n$previous_log" | \
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
