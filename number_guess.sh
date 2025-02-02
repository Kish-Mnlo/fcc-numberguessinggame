#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guessing_game --no-align --tuples-only -c"

ASK_USERNAME() {
  echo Enter your username:
  read USERNAME

  RETURNING_USER=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
  if [[ -z $RETURNING_USER ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  else
    GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users USING(user_id) WHERE username='$USERNAME'")
    BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games INNER JOIN users USING(user_id) WHERE username='$USERNAME'")
    echo "Welcome back, $RETURNING_USER! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
}

PLAY_GAME() {
  RANDOM_INT=$(( 1 + $RANDOM % 1000 ))
  SECRET_NUM=$RANDOM_INT
  GUESS=1
  echo "Guess the secret number between 1 and 1000:"
  while read NUM
  do
    if [[ ! $NUM =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
    fi
    if [[ $NUM -gt $SECRET_NUM ]]
    then
      echo "It's lower than that, guess again:"
    fi
    if [[ $NUM -lt $SECRET_NUM ]]
    then
      echo "It's higher than that, guess again:"
    fi  
    if [[ $NUM -eq $SECRET_NUM ]]
    then
      break;
    fi
    GUESS=$(( $GUESS + 1 ))
  done
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  INSERT_RESULTS=$($PSQL "INSERT INTO games(guesses, user_id) VALUES($GUESS, $USER_ID)")
}

ASK_USERNAME
PLAY_GAME
TRIES=$GUESS
echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUM. Nice job!"
