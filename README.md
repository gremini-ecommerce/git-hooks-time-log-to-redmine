
# git-hooks-time-log-to-redmine

Using these git hooks, you can automate your time logging to Redmine.

In your `~/.bashrc` you have to add the following lines

`export REDMINE_API_KEY=8f08c48f0168fc1......`  
`export REDMINE_URL=https://your.redmine-url.com`  
`export REDMINE_IN_PROGRESS_STATUS_ID=...#You can find it at REDMINE_URL/issue_statuses`  
`export REDMINE_ACTIVITY_ID=...#the activity ID for the time entry. You can find it at REDMINE_URL/enumerations`


The [jq](https://stedolan.github.io/jq/) utility needs to be installed.

# How it works

You have to copy `pre-commit`, `post-checkout` and `functions.sh` files to your .git/hooks folder.

Your branch must end with `-issueID`. Eg: `featurex-1234`  
The hooks will detect the issueID at the end of the branch name.  
When you checkout that branch, the `post-checkout` hook will check if the issue is assigned to someone.
If it is NOT assigned, then it will **automatically assign the issue to you** and will set its status to **In progress** .
In any case, the hook will register the time when the checkout was made (in `~/.redmine/issueID.time`).

When you make a commit, the `pre-commit` hook will calculate the diff between the time of the checkout (or the previous commit) and the current time. It will then ask you to confirm your time entry. You can disagree with the calculation and enter your own time. Eg:

`Log 0:15 on issue 1234? (Y/n)`  
**n**  
`Log your time (enter 0 to skip)`  
**0:05**  
`Logging 0:05`
