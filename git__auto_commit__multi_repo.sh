#!/bin/bash

# This script make auto commit for each given repo.
# Script must runs by root or other priveleged user.
# @author dev@dermanov.ru

# Add to cron:
# 1) put this script to $HOME/scripts/
# 2.0) every minute
# */1 * * * * $HOME/scripts/git__auto_commit__multi_repo.sh
# 2.1) every hour
#  0 * * * * $HOME/scripts/git__auto_commit__multi_repo.sh
#  @hourly $HOME/scripts/git__auto_commit__multi_repo.sh
# 2.2) every day at 7 AM
# * 7 * * * $HOME/scripts/git__auto_commit__multi_repo.sh

# Manual run from shell and send notify email:
# $HOME/scripts/git__auto_commit__multi_repo.sh | mail -s "git__auto_commit__multi_repo" "cron@domen.ru"

# Общие константы 
DATE=$(date +%d_%m_%y)

arRepos=(
    "/var/www/user1/data/www/site1.ru"
    "/var/www/user1/data/www/site2.ru"
    "/var/www/user2/data/www/site1.ru"
)

arReposUsers=(
    user1
    user1
    user2
)
 

# --- NEXT REPO ---

REPO_COUNT=${#arRepos[*]}

for index in ${!arRepos[*]}
do
   # just for pretty
   index_pretty=$(( $index + 1 ))

   REPO=${arRepos[$index]}  
   
   # TODO extract user from path
   # /var/www/USER/data/
   USER=${arReposUsers[$index]}  

    cd $REPO;

    GIT_STATUS=$(git status);
    HAS_UNTRACKED=$(echo $GIT_STATUS | egrep "Untracked|deleted|modified")

        
    if [ "$HAS_UNTRACKED" -ne "" ]; then
       echo ""
       echo "Repo: "$REPO 
       echo ""
       
        echo ""
        echo "--- GIT BRANCH ---"
        git branch
        

        echo ""
        echo ""
        echo "--- GIT LOG -- graph -5 ---"
        # git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -5
        git log --pretty=format:'%s (%cr) <%an>' --abbrev-commit -5
        
        echo "------"

        echo ""
        echo ""
        
        echo "--- GIT STATUS ---"
        git status

        echo " "

        echo  "--- GIT DIFF --stat ---" 
        git diff --stat
        
        # make an auto commit
        git add -A
        git commit -m "AUTO COMMIT untracked changes at "$DATE

        # todo push to remote repo
        
        echo "------"

        echo  "Auto commit created." 
        
        # fix owner user of repo after commit under root 
        chown $USER:$USER .git -R
    fi; 
    
done 