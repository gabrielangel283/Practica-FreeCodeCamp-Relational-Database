#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Borrar los datos que ya existen
echo $($PSQL "TRUNCATE teams, games")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != 'year' ]]
  then
    # Agregar equipos
    TEAM_WINNER_ID=$($PSQL "SELECT DISTINCT(team_id) FROM teams WHERE name='$WINNER'")
    TEAM_OPPONENT_ID=$($PSQL "SELECT DISTINCT(team_id) FROM teams WHERE name='$OPPONENT'")
    if [[ -z $TEAM_WINNER_ID ]]
    then
      INSERT_TEAM_A=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM_A=='INSERT 0 1' ]]
      then
        echo "Se agrego el equipo -> $WINNER"
      fi
    fi
    if [[ -z $TEAM_OPPONENT_ID ]]
    then
      INSERT_TEAM_B=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM_B=='INSERT 0 1' ]]
      then
        echo "Se agrego el equipo -> $OPPONENT"
      fi
    fi
  fi
done

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != 'year' ]]
  then
    # Agregar juegos
    TEAM_WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    TEAM_OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    
    INSERT_GAME=$($PSQL "INSERT INTO games(year,winner_id,opponent_id,winner_goals,opponent_goals,round) VALUES($YEAR,$TEAM_WINNER_ID,$TEAM_OPPONENT_ID,$WINNER_GOALS,$OPPONENT_GOALS,'$ROUND')")

    if [[ $INSERT_GAME=='INSERT 0 1' ]]
    then
      echo "Se inserto el juego -> $YEAR - $ROUND: $WINNER VS $OPPONENT"
    fi
  fi
done

