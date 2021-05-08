# it imports the base database structure and create the database for the tests

echo "*** CREATING DATABASE ***"

# create default database
psql --username "$POSTGRES_USER" <<EOSQL
  CREATE DATABASE horizon;
  CREATE DATABASE stellarcore;
  CREATE DATABASE stellarfee;
  CREATE DATABASE stellarvalidator;
  GRANT ALL PRIVILEGES ON DATABASE horizon TO "$POSTGRES_USER";
  GRANT ALL PRIVILEGES ON DATABASE stellarcore TO "$POSTGRES_USER";
  GRANT ALL PRIVILEGES ON DATABASE stellarfee TO "$POSTGRES_USER";
  GRANT ALL PRIVILEGES ON DATABASE stellarvalidator TO "$POSTGRES_USER";
EOSQL

echo "*** DATABASE CREATED! ***"