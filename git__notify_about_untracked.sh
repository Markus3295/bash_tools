#!/bin/bash

# This script send report to email about untarcked changes in repo.
# @author dev@dermanov.ru

# Add to cron:
# 1) put this script to $HOME/scripts/
# 2.0) every minute
# */1 * * * * $HOME/scripts/git__notify_about_untracked.sh
# 2.1) every hour
#  0 * * * * $HOME/scripts/git__notify_about_untracked.sh
#  @hourly $HOME/scripts/git__notify_about_untracked.sh
# 2.2) every day at 7 AM
# * 7 * * * $HOME/scripts/git__notify_about_untracked.sh


# CONFIG 
REPO="/var/www/origin/data/www/tickboom.ru"
#USER=bitrix
TMP_EMAIL_FILE="/tmp/git__untracked_repo1.txt"
EMAIL_TO="fayl05@mail.ru"
EMAIL_SUBJECT="ALARM! Untracked changes on [tickboom.ru]"
SEND_DIFF_DETAILES=N


# SCRIPT BODY
cd $REPO;

GIT_STATUS=$(git status);
HAS_UNTRACKED=$(echo $GIT_STATUS | egrep "Untracked|deleted|modified")


if [ "$HAS_UNTRACKED" = "" ]; then
    echo "Where is no edited files."
else
    echo "" > $TMP_EMAIL_FILE
    echo "--- GIT BRANCH ---" >> $TMP_EMAIL_FILE
    git branch >> $TMP_EMAIL_FILE
    

    echo "" >> $TMP_EMAIL_FILE
    echo "" >> $TMP_EMAIL_FILE
    echo "--- GIT LOG -- graph -5 ---" >> $TMP_EMAIL_FILE
    # git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -5
    git log --pretty=format:'%s (%cr) <%an>' --abbrev-commit -5 >> $TMP_EMAIL_FILE
    
    echo "------" >> $TMP_EMAIL_FILE

    echo "" >> $TMP_EMAIL_FILE
    echo "" >> $TMP_EMAIL_FILE
    
    echo "--- GIT STATUS ---" >> $TMP_EMAIL_FILE
    git status >> $TMP_EMAIL_FILE

    echo " " >> $TMP_EMAIL_FILE

    echo  "--- GIT DIFF --stat ---"  >> $TMP_EMAIL_FILE
    git diff --stat >> $TMP_EMAIL_FILE
    
    if [ "$SEND_DIFF_DETAILES" = Y ]; then
        echo " " >> $TMP_EMAIL_FILE
        echo  "--- GIT DIFF (full) ---"  >> $TMP_EMAIL_FILE
        git diff >> $TMP_EMAIL_FILE
    fi;
        
    # make an auto commit
    #git add -A
    #git commit -m "AUTO COMMIT untracked changes at "$DATE

    # todo push to remote repo
    
    echo "------" >> $TMP_EMAIL_FILE
    
    # send notify email
    cat $TMP_EMAIL_FILE | mail -s "$EMAIL_SUBJECT" $EMAIL_TO
    
    echo "Report about edited files sended to email."

    
    #echo  "Auto commit created." 
    
    # fix owner user of repo after commit under root 
    #chown $USER:$USER .git -R
fi; 

echo "-------------------------"

echo "All done."