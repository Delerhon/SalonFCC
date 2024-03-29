#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

SERVICE_MENU() {
  #prints a given string on function call
  if [[ $1 ]]
  then
    echo -e "$1"
  fi

  # request service list
  SERVICES=$($PSQL "SELECT service_id, name FROM services")

  # print service list
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  GET_SERVICE
}

GET_SERVICE() {
  #echo -e "\nWhich service do you want?"
  read SERVICE_ID_SELECTED

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  
  if [[ -z $SERVICE_NAME ]]
  then
    SERVICE_MENU "\nI could not find that service. What would you like today?"
  fi
  GET_PHONE_NUMBER
}

GET_PHONE_NUMBER() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]]
  then
    GET_NAME
  fi
  GET_TIME
}

GET_NAME() {
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  CUSTOMER_INSERTED=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  # echo -e "\n$CUSTOMER_INSERTED"
  if [[ ! $CUSTOMER_INSERTED == 'INSERT 0 1' ]]
  then
    EXIT "Customer could not added. Exit"
  fi
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  GET_TIME
}

GET_TIME() {
  echo -e "\nWhat time would you like your$SERVICE_NAME,$CUSTOMER_NAME?"
  read SERVICE_TIME
  # time should be a valid time in 23:59 format
  if [[ -z $SERVICE_TIME ]] # =~ ^([0-1][0-9]|[2][0-3]):([0-5][0-9])|([1-9]|[1][1-2])(am|pm)$ ]]
  then
    EXIT "Service Time is not a valit 23:59 format. Exit"
  fi
  INSERT_APPOINTMENT
}

INSERT_APPOINTMENT() {
  APPOINTMENT_INSERTED=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  if [[ ! $APPOINTMENT_INSERTED == "INSERT 0 1" ]]
  then
    EXIT "Appointment could not be added. Exit"
  fi
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  EXIT "I have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME."
}

EXIT() {
  if [[ $1 ]]
  then 
    echo -e "\n$1"
  fi
  # echo -e "\nThank for using the service, have a nice day!\n\n\n"
  exit
}

SERVICE_MENU "Welcome to My Salon, how can I help you?\n"
