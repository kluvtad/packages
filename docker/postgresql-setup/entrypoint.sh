#!/bin/bash

if [ -z "$MASTER_PGHOST" ] || [ -z "$MASTER_PGDATABASE" ] || [ -z "$MASTER_PGUSER" ] || [ -z "$MASTER_PGPASSWORD" ] ; then
  echo "Error: MASTER_PGHOST, MASTER_PGDATABASE, MASTER_PGUSER, and MASTER_PGPASSWORD environment variables must be set."
  exit 1
fi

export MASTER_PGPORT=${MASTER_PGPORT:-5432}

ls_env_to_var=(
  MASTER_PGHOST
  MASTER_PGPORT
  MASTER_PGDATABASE
  MASTER_PGUSER
  MASTER_PGPASSWORD
)

> /tmp/master_pg.yml
for var in "${ls_env_to_var[@]}"; do
  echo "$var: ${!var}" >> /tmp/master_pg.yml
done

ansible-playbook -i ./inventory/hosts.ini --extra-vars "@/tmp/master_pg.yml" ./playbook.yml