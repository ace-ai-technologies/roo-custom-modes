# This script automates the process of proposing an update to the custom_modes.yaml file.
# It creates a new branch, commits the changes, pushes the branch, and creates a pull request.

param (
    [Parameter(Mandatory=$true)]
    [string]$CommitMessage
)

$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

# --- Configuration ---
$repoDir = "C:\Users\GAMING\Documents\GitHub\ace\delamain\delamain-federal\roo_custom_modes_repo"
$targetFile = "." # Stage all changes in the repository
$repoOwner = "ace-ai-technologies"
$repoName = "roo-custom-modes"
$baseBranch = "main"

# --- Functions ---

function Write-Log {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $message"
    Write-Host $logMessage
}

# --- Main Logic ---

try {
    # Navigate to the repository directory
    Set-Location -Path $repoDir

    Write-Log "Navigated to repository directory: $repoDir"

    # Ensure we are on the main branch and up-to-date
    Write-Log "Checking out main branch and pulling latest changes..."
    git checkout $baseBranch
    git pull origin $baseBranch

    # Create a new branch with a unique name
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $newBranchName = "reflector-update-$timestamp"
    Write-Log "Creating new branch: $newBranchName"
    git checkout -b $newBranchName

    # Add the modified file
    Write-Log "Adding '$targetFile' to the staging area..."
    git add $targetFile

    # Check if there are any actual changes staged for commit.
    # `git diff --staged --quiet` exits with 0 if no changes, 1 if there are changes.
    git diff --staged --quiet
    if ($LASTEXITCODE -eq 0) {
        Write-Log "No actual changes detected in '$targetFile' after staging. Nothing to commit."
        Write-Log "Cleaning up temporary branch '$newBranchName'."
        git checkout $baseBranch
        git branch -D $newBranchName
        Write-Log "Exiting gracefully."
        exit 0 # Exit with success code, as there's no error
    }

    # Commit the changes
    Write-Log "Committing changes with message: '$CommitMessage'"
    git commit -m $CommitMessage

    # Push the new branch to the remote repository
    Write-Log "Pushing branch '$newBranchName' to origin..."
    git push -u origin $newBranchName

    # Create a pull request
    Write-Log "Creating pull request..."
    $prTitle = "Proposed Update: $CommitMessage"
    $prBody = "This is an automated pull request from the Reflector AI mode. It contains updates to the `custom_modes.yaml` file."
    gh pr create --title $prTitle --body $prBody --base $baseBranch --repo "$repoOwner/$repoName"
    
    Write-Log "SUCCESS: Pull request created for branch '$newBranchName'."

} catch {
    Write-Log "ERROR: An error occurred during the update proposal process. Error: $_"
    exit 1
} finally {
    # Return to the original directory
    Set-Location -Path "C:\Users\GAMING\Documents\GitHub\ace\delamain\delamain-federal"
}