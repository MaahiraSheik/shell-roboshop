#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/shellscript-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD
mkdir -p $LOGS_FOLDER
echo "script started executing at: $(date)" &>>$LOG_FILE

if [ $USERID -ne 0 ]
then
echo -e "$R ERROR: please run with this root access $N" | tee -a $LOG_FILE
exit 1
else
echo "your is running with root access"  | tee -a $LOG_FILE
fi

VALIDATE(){
    if [ $1 -eq 0 ]; then
    echo -e "$2 is... $G Success $N"  | tee -a $LOG_FILE
  else
    echo -e "$2 is... $R Failure $N"  | tee -a $LOG_FILE
    exit 1
  fi
}

dnf module disable nodejs -y &>>LOG_FILE
VALIDATE $? "Disabling Default nodeje:20"

dnf module enable nodejs:20 -y &>>LOG_FILE
VALIDATE $? "enabling nodejs:20"

dnf install nodejs -y &>>LOG_FILE
VALIDATE $? "Installling Nodejs:20"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Create Sytem User"

mkdir /app &>>LOG_FILE
VALIDATE $? "createing App directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "Downloading the catalogue"

cd /app 
unzip /tmp/catalogue.zip
VALIDATE $? "Unzipping the catalogue"

cd /app 
npm install &>>LOG_FILE
VALIDATE $? "Installing dependencies"

cp SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "copying Catalogue service"

systemctl daemon-reload &>>LOG_FILE
VALIDATE $? "daemon reload"

systemctl enable catalogue  &>>LOG_FILE
VALIDATE $? "enable catalogue reload"
systemctl start catalogue &>>LOG_FILE
VALIDATE $? "start cataloguw reload"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongodb repo"

dnf install mongodb-mongosh -y &>>LOG_FILE
VALIDATE $? "installing mongodb client"

mongosh --host mongodb.miasha84s.site </app/db/master-data.js
VALIDATE $? "load master data"


