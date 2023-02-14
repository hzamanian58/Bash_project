#!/bin/bash
#all=$(cat test.1.col)

## read a log file from user
read -p 'please enter your filename: ' LOG_FILE
read -p 'please enter Start date you want to search logs: for example\
	Year-Month-Day   \
	"2023-01-20": ' Start_date_user
read -p 'please enter End date you want to search logs: for example\
	Year-Month-Day   \
	"2023-01-25": ' End_date_user

echo "your start date is: $Start_date_user " 
echo "your End date is: $End_date_user " 

START_SEARCH_DATE=$(date --date "$Start_date_user" '+%d/%b/%Y')
END_SEARCH_DATE=$(date --date "$End_date_user" '+%d/%b/%Y')


echo "Start-search-date is: $START_SEARCH_DATE"
echo "End-search-date is: $END_SEARCH_DATE"

datediff() {
    d1=$(date -d "$Start_date_user" +%s)
    d2=$(date -d "$End_date_user" +%s)
    LENGTH_DATE=$(( (d2 - d1) / 86400 ))
}

datediff

echo "length date is $LENGTH_DATE"

while [[ $LENGTH_DATE -ge 0 ]]; do
	echo " length date is: $LENGTH_DATE"
	grep $START_SEARCH_DATE $LOG_FILE >> search.log
	Start_date_user=$(date --date "$Start_date_user +1days")
	START_SEARCH_DATE=$(date --date "$Start_date_user" '+%d/%b/%Y')
	LENGTH_DATE=$(( $LENGTH_DATE - 1 ))
done




