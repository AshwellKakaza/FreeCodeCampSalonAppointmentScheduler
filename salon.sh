#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"


MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  LIST_OF_SERVICES=$($PSQL "SELECT service_id, name from services order by service_id");

  echo "$LIST_OF_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED;

  SERVICE_ID_SELECTED=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_ID_SELECTED ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"  
    read CUSTOMER_PHONE;
    FIND_CUSTOMER=$($PSQL "select phone, name from customers where phone ='$CUSTOMER_PHONE'")
    if [[ -z $FIND_CUSTOMER ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_RECORD=$($PSQL "insert into customers(phone,name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi
    CUSTOMER_NAME=$($PSQL "select name from customers where phone ='$CUSTOMER_PHONE'") 
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone ='$CUSTOMER_PHONE'")

    SERVICE_NAME_SELECTED=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
    echo -e "\nWhat time would you like your $SERVICE_NAME_SELECTED, $CUSTOMER_NAME?"
    read SERVICE_TIME;

    INSERT_APPOINTMENT=$($PSQL "insert into appointments(customer_id,service_id,time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED,'$SERVICE_TIME')")

    SERVICE_NAME_SELECTED_FORMATTED=$(echo $SERVICE_NAME_SELECTED | sed 's/ |/"/')
    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/ |/"/')

    echo -e "\nI have put you down for a $SERVICE_NAME_SELECTED_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."  
  fi


}

MAIN_MENU "Welcome to My Salon, how can I help you?\n"