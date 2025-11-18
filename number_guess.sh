#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -tA -c"
RND=$((1 + $RANDOM % 1000))

# ask for user name
echo -e "Enter your username: "
read USER_NAME

# get user from database
USER_ID=$($PSQL "SELECT user_id FROM users WHERE user_name='$USER_NAME';")

# if user not in database
if [[ -z $USER_ID ]]
then
  # create new user
  echo "Welcome, $USER_NAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(user_name) VALUES('$USER_NAME');")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE user_name='$USER_NAME';")
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID;")
else
  # get user data from database
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID;")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID;")
  echo "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo -e "Guess the secret number between 1 and 1000:"
read USER_GUESS
no_guess=1

# check if input is numeric
re='^[0-9]+$'
while ! [[ $USER_GUESS =~ $re ]]
do
  echo -e "That is not an integer, guess again:"
  read USER_GUESS
  ((no_guess++))
done

# guessing loop
while [[ $USER_GUESS -ne $RND ]]
do
  if [[ $USER_GUESS -gt $RND ]]
  then 
    echo -e "It's lower than that, guess again:"
  else
    echo -e "It's higher than that, guess again:"
  fi

  read USER_GUESS
  ((no_guess++))

  # check if input is numeric
  while ! [[ $USER_GUESS =~ $re ]]
  do
    echo -e "That is not an integer, guess again:"
    read USER_GUESS
    ((no_guess++))
  done
done

# update best_game value
if [[ -z $BEST_GAME ]]
then
  SET_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game=$no_guess WHERE user_id=$USER_ID;")
else
  if [[ $no_guess -le $BEST_GAME ]]
  then 
    SET_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game=$no_guess WHERE user_id=$USER_ID;")
  fi
fi

echo "You guessed it in $no_guess tries. The secret number was $RND. Nice job!"

echo -e "Games Played: $GAMES_PLAYED"
NEW_GAMES_PLAYED=$((GAMES_PLAYED + 1))
echo -e "Games Played new: $NEW_GAMES_PLAYED"
SET_BEST_GAME_RESULT=$($PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED WHERE user_id=$USER_ID;")