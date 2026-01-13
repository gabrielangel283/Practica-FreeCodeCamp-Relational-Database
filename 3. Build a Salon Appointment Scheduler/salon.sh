#! /bin/bash

echo "~~~~~ MY SALON ~~~~~";
echo "";
echo "Welcome to My Salon, how can I help you?"
echo "";

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -q -c ";
valido=false;

while [[ $valido == false ]]; do

  $PSQL "SELECT service_id || ') ' || name FROM services ORDER BY service_id;";
  read SERVICE_ID_SELECTED;

  service_name=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED" | xargs);

  if [[ -z $service_name ]]; then
    echo "";
  else
    valido=true;
  fi
done;

echo "";

# seguir con la logica con el SERVICE_ID_SELECTED
# Pedir teléfono
echo -e "What's your phone number?"
read CUSTOMER_PHONE
echo ""

# Buscar cliente
CUSTOMER_ID=$($PSQL \
"SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'" | xargs)

# Si no existe
if [[ -z $CUSTOMER_ID ]]; then
  echo -e "I don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  echo ""

  CUSTOMER_ID=$($PSQL \
  "INSERT INTO customers(name, phone)
   VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')
   RETURNING customer_id" | xargs)
else
  # Si existe, obtener nombre
  CUSTOMER_NAME=$($PSQL \
  "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID" | xargs)
fi

echo $CUSTOMER_ID;

# Pedir hora
echo -e "What time would you like your cut, $CUSTOMER_NAME?"
read SERVICE_TIME
echo ""

# Insertar cita
INSERT_APPOINT=$($PSQL \
"INSERT INTO appointments(customer_id, service_id, time)
 VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# Mensaje final
echo "I have put you down for a $service_name at $SERVICE_TIME, $CUSTOMER_NAME."
