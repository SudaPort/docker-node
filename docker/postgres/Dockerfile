FROM postgres:9.5

COPY scripts/init.sh /docker-entrypoint-initdb.d/
RUN chmod u+x /docker-entrypoint-initdb.d/init.sh