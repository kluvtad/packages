#!/bin/sh

if [ -z "$MASTER_PGHOST" ] || [ -z "$MASTER_PGDATABASE" ] || [ -z "$MASTER_PGUSER" ] || [ -z "$MASTER_PGPASSWORD" ] ; then
  echo "Error: MASTER_PGHOST, MASTER_PGDATABASE, MASTER_PGUSER, and MASTER_PGPASSWORD environment variables must be set."
  exit 1
fi

export MASTER_PGPORT=${MASTER_PGPORT:-5432}

ansible-playbook -i ./inventory/hosts.ini ./playbook.yml