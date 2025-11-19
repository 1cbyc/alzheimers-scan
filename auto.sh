#!/bin/sh

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Pre-flight Checks ---

# 1. Check if inside a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: This script must be run inside a git repository."
    exit 1
fi

# --- Main Logic ---

# 1. Stage all changes to get a list of everything that's different.
#    This respects the .gitignore file.
git add .

# 2. Check if there are any staged changes. If not, we're done.
if git diff --staged --quiet; then
    echo "No changes to commit. Working directory is clean."
    exit 0
fi

# 3. Get the list of all staged files and their statuses.
#    We store this in a temporary file to safely loop over it later.
CHANGELIST_FILE=$(mktemp)
git diff --staged --name-status > "$CHANGELIST_FILE"

# 4. Unstage everything. We will now stage and commit each file one by one.
git reset > /dev/null

echo "Starting to commit changed files individually..."
echo "---"

# 5. Loop through the changelist file.
#    IFS=$'\t' is crucial for correctly parsing the tab-separated output.
while IFS=$'\t' read -r status from_path to_path; do
    filepath=""
    action=""
    subject=""
    scope=""
    type=""
    filename=""

    # Determine the correct action, commit type, and file paths based on the git status.
    case "$status" in
        A)
            filepath="$from_path"
            action="Add"
            type="feat" # A new file is typically a new feature
            ;;
        M|T) # M = Modified, T = Type Change (e.g. file to symlink)
            filepath="$from_path"
            action="Update"
            type="fix" # A modification is often a fix or refinement
            ;;
        D)
            filepath="$from_path"
            action="Remove"
            type="refactor" # Removing a file is a form of refactoring
            ;;
        R*) # Renames are RXXX, e.g., R100
            # For renames, we need to stage both old and new paths for git to track the move.
            git add "$from_path" "$to_path"
            filepath="$to_path" # The "current" path is the new one
            action="Rename"
            type="refactor" # Renaming is a refactor
            ;;
        C*) # Copies are CXXX, e.g., C100
            filepath="$to_path" # The new file
            action="Copy"
            type="feat"
            ;;
        *)
            # Fallback for any other status
            filepath="$from_path"
            action="Modify"
            type="chore"
            ;;
    esac

    # Stage the file(s) for this specific commit.
    # The 'Rename' case is handled above because it involves two paths.
    if ! [[ "$status" =~ ^R.* ]]; then
        git add "$filepath"
    fi

    # Generate a conventional commit message.
    scope=$(dirname "$filepath")
    if [ "$scope" = "." ]; then
        scope="root"
    fi

    # Create a descriptive subject line.
    if [[ "$status" =~ ^R.* ]]; then
        # Special case for renames to be more descriptive.
        old_filename=$(basename "$from_path")
        new_filename=$(basename "$to_path")
        subject="$type($scope): $action $old_filename to $new_filename"
    elif [[ "$status" =~ ^C.* ]]; then
        # Special case for copies.
        original_filename=$(basename "$from_path")
        new_filename=$(basename "$to_path")
        subject="$type($scope): $action $original_filename to $new_filename"
    else
        filename=$(basename "$filepath")
        subject="$type($scope): $action $filename"
    fi

    # Perform the commit, hiding the default git output for cleaner script output.
    git commit -m "$subject" > /dev/null

    echo "✅ Committed: $subject"

done < "$CHANGELIST_FILE"

# --- Cleanup ---

# Remove the temporary file.
rm "$CHANGELIST_FILE"

echo "---"
echo "All changed files have been committed individually."
