#!/bin/bash

if [[ -z "$1" ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"


DATA_ELEMENT=$($PSQL "select atomic_number, symbol, name, type, atomic_mass, melting_point_celsius, boiling_point_celsius,type_id from elements inner join properties using(atomic_number) inner join types using(type_id) where atomic_number::text='$1' or symbol='$1' or name='$1';")

if [[ -z $DATA_ELEMENT ]];
then
  echo "I could not find that element in the database."
  exit 0
fi

echo "$DATA_ELEMENT" | while IFS="|" read -r ATOMIC_NUMBER SYMBOL NAME TYPE ATOMIC_MASS MELTING BOILING TYPE_ID
do
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
done

