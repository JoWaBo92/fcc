#! /bin/bash
if [[ $1 ]]; then
  PSQL="psql --username=freecodecamp --dbname=periodic_table --no-align --tuples-only -c"
  ELEMENT_ID=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number::text='$1' OR symbol='$1' OR name='$1';")
  if [[ -z $ELEMENT_ID ]]
  then
    echo "I could not find that element in the database."
  else
    NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number='$ELEMENT_ID';")
    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number='$ELEMENT_ID';")
    MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number='$ELEMENT_ID';")
    MELTING=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number='$ELEMENT_ID';")
    BOILING=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number='$ELEMENT_ID';")
    TYPE_ID=$($PSQL "SELECT type_id FROM properties WHERE atomic_number='$ELEMENT_ID';")
    TYPE=$($PSQL "SELECT type FROM types WHERE type_ID='$TYPE_ID';")

    echo -e "The element with atomic number $ELEMENT_ID is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
  fi
else
  echo "Please provide an element as an argument."
fi


