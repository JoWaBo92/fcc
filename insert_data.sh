#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "$($PSQL "TRUNCATE TABLE games, teams;")"

cat games.csv | while IFS="," read YEAR RND WIN OPP WIN_G OPP_G
do
  if [[ $YEAR != year ]]
  then
    echo $YEAR, $RND, $WIN, $OPP, $WIN_G, $OPP_G

    # Winner ID
    WIN_ID="$($PSQL "SELECT team_id FROM teams WHERE name= '$WIN';")"
    # If not found
    if [[ -z $WIN_ID ]]
    then
      # Insert winner team
      INSERT_WIN_RESULT="$($PSQL "INSERT INTO teams(name) VALUES('$WIN');")"
      if [[ $INSERT_WIN_RESULT == 'INSERT 0 1' ]]
      then
        echo Inserted into teams: $WIN
      fi
      # Get new winner ID
      WIN_ID="$($PSQL "SELECT team_id FROM teams WHERE name= '$WIN';")"
    fi

    # Opponent ID
    OPP_ID="$($PSQL "SELECT team_id FROM teams WHERE name= '$OPP';")"
    # If not found
    if [[ -z $OPP_ID ]]
    then
      # Insert opponent team
      INSERT_OPP_RESULT="$($PSQL "INSERT INTO teams(name) VALUES('$OPP');")"
      if [[ $INSERT_OPP_RESULT == 'INSERT 0 1' ]]
      then
        echo Inserted into teams: $OPP
      fi
      # Get new opponent ID
      OPP_ID="$($PSQL "SELECT team_id FROM teams WHERE name= '$OPP';")"
    fi

    # Insert game
    INSERT_GAME_RESULT="$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR', '$RND', $WIN_ID, $OPP_ID, $WIN_G, $OPP_G);")"
    if [[ $INSERT_GAME_RESULT == 'INSERT 0 1' ]]
    then
      echo Inserted into games: $YEAR, $RND: $WIN - $OPP: $WIN_G - $OPP_G 
    fi
  fi
done