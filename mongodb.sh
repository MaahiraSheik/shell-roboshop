#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/shellscript-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

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
    echo -e "$G SUCCESS: $2 installed $N"  | tee -a $LOG_FILE
  else
    echo -e "$R FAILURE: $2 not installed $N"  | tee -a $LOG_FILE
    exit 1
  fi

# }
# USERID=$(id -u)
# R="\e[31m"
# G="\e[32m"
# Y="\e[33m"
# N="\e[0m"
# LOGS_FOLDER="/var/log/roboshop-logs"
# SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
# LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

# mkdir -p $LOGS_FOLDER
# echo "Script started executing at: $(date)" | tee -a $LOG_FILE

# # check the user has root priveleges or not
# if [ $USERID -ne 0 ]
# then
#     echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
#     exit 1 #give other than 0 upto 127
# else
#     echo "You are running with root access" | tee -a $LOG_FILE
# fi

# # validate functions takes input as exit status, what command they tried to install
# VALIDATE(){
#     if [ $1 -eq 0 ]
#     then
#         echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
#     else
#         echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE
#         exit 1
#     fi
# }


# cp mongo.repo /etc/yum.repos.d/mongodb.repo
# VALIDATE $? "Copying MongoDB repo"

# dnf install mongodb-org -y &>>$LOG_FILE
# VALIDATE $? "Installing mongodb server"

# systemctl enable mongod &>>$LOG_FILE
# VALIDATE $? "Enabling MongoDB"

# systemctl start mongod &>>$LOG_FILE
# VALIDATE $? "Starting MongoDB"

# sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
# VALIDATE $? "Editing MongoDB conf file for remote connections"

# systemctl restart mongod &>>$LOG_FILE
# VALIDATE $? "Restarting MongoDB"

cp mongo.repo /etc/yum.repos.d/mongodb.repo &>>$LOG_FILE
VALIDATE $? "copying mongodb repo"

dnf install -y mongodb-org &>>$LOG_FILE
VALIDATE $? "install mongodb"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "enable Mongodb service"
systemctl start mongod &>>$LOG_FILE
VALIDATE $? "strat Mongodb service"

sed -i -e 's/127.0.0.1 to 0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Editing mongodb conf file for remote connections"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "restart mongodb"