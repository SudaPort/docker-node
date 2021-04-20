# it imports the base database structure and create the database for the tests

echo "*** CREATING DATABASE ***"

# create default database
psql --username postgres <<EOSQL
  CREATE DATABASE horizon;
  CREATE DATABASE stellar;
  GRANT ALL PRIVILEGES ON DATABASE horizon TO "$POSTGRES_USER";
  GRANT ALL PRIVILEGES ON DATABASE stellar TO "$POSTGRES_USER";
EOSQL

echo "*** DATABASE CREATED! ***"