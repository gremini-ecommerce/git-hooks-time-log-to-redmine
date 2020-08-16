checkSettings()
{
  varName=$1
  
  if [ "${!varName}" == "" ]; then
    echo "Please define ${varName} in your .bashrc";
    exit;
  fi

}

getBranchName()
{
  echo $(git rev-parse --abbrev-ref HEAD)
}

getIssueID()
{
  branchName=$(getBranchName)

  issueID=`echo $branchName | rev | cut -d "-" -f 1 | rev`

  echo $issueID
}

getUserID()
{
  userFile="~/.redmine/user.json"
  eval userFile=${userFile}
  
  if [ -f $userFile ]; then
    cat $userFile | jq -r ".user.id"
    return;
  fi

  curl -s -H "Content-Type: application/json" -X GET -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" ${REDMINE_URL}/my/account.json > $userFile
  
  cat $userFile | jq -r ".user.id"
}

updateIssue()
{
  curl -H "Content-Type: application/json" -X PUT --data-binary "@${redmineIssueFile}" -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" ${REDMINE_URL}/issues/${issueID}.json
}

getIssue()
{
  curl -s -H "Content-Type: application/json" -X GET -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" ${REDMINE_URL}/issues/${issueID}.json
}

logTimeEntry()
{
  curl -s -H "Content-Type: application/json" -X POST --data-binary "@${redmineIssueFile}" -H "X-Redmine-API-Key: ${REDMINE_API_KEY}" ${REDMINE_URL}/time_entries.json
}

if [ ! -d ~/.redmine ]; then
  mkdir -p ~/.redmine
fi  

jqIsInstalled=`which jq | wc -m`

if [ $jqIsInstalled -eq 0 ]; then
  echo Please install "jq";
  exit;
fi

checkSettings REDMINE_API_KEY
checkSettings REDMINE_URL
checkSettings REDMINE_IN_PROGRESS_STATUS_ID
checkSettings REDMINE_ACTIVITY_ID

issueID=$(getIssueID)

re='^[0-9]+$'
if ! [[ "${issueID}" =~ $re ]] ; then
   echo "Could not detect issue ID";
   exit;
fi

timeIssueFile="~/.redmine/${issueID}.time"
eval timeIssueFile=${timeIssueFile}

redmineIssueFile="~/.redmine/${issueID}.json"
eval redmineIssueFile=${redmineIssueFile} #not working without this. ~ not working in curl --data-binary

userID=$(getUserID)

