#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

n=$(( ( $RANDOM % 1000 ) + 1 ))

echo "Enter your username:"
read NAME

# Buscar el USER_ID
USER_ID=$($PSQL "SELECT user_id FROM users WHERE user_name='$NAME';")

if [[ -z $USER_ID ]]
then
  echo "Welcome, $NAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(user_name) VALUES('$NAME');")

  USER_ID=$($PSQL "SELECT user_id FROM users WHERE user_name='$NAME';")
else
  USER_DATA=$($PSQL "SELECT count(*), MIN(guesses) FROM games WHERE user_id=$USER_ID;")

  echo "$USER_DATA" | while IFS="|" read GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took ${BEST_GAME:-0} guesses."
  done
fi

echo "Guess the secret number between 1 and 1000:"
NUM_GUESS=0
guessed=false

while [ "$guessed" = false ]
do
  read NUMBER

  if [[ ! $NUMBER =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    (( NUM_GUESS++ ))
    
    if (( NUMBER == n ))
    then
      echo "You guessed it in $NUM_GUESS tries. The secret number was $n. Nice job!"
      
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $NUM_GUESS);")
      guessed=true
    elif (( NUMBER < n ))
    then
      echo "It's higher than that, guess again:"
    else
      echo "It's lower than that, guess again:"
    fi
  fi
done