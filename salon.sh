#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
MESSAGE="Welcome to My Salon, how can I help you?"
SERVICE_NAME=''

while [[ -z $SERVICE_NAME ]]
do
  echo "$MESSAGE"

  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while IFS="|" read ID NAME 
  do 
    echo "$ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MESSAGE="The option should be a number.Please choose again"
  else
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_NAME ]]
    then 
      MESSAGE="I could not find that service. What would you like today?"
    fi
  fi
done


echo "What's your phone number?"
read CUSTOMER_PHONE
ID_CUSTOMER=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
if [[ -z $ID_CUSTOMER  ]]
then
  echo "I don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  $PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')"
  ID_CUSTOMER=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'") 
else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = '$ID_CUSTOMER' ")
fi
echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME
$PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($ID_CUSTOMER,$SERVICE_ID_SELECTED,'$SERVICE_TIME')" > /dev/null #Evitar resultado INSERT 0 1
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."



