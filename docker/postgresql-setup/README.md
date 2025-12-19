## Local dev
0. RUn db
```bash
$ docker run -p 5432:5432 -e POSTGRES_DB=postgres -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=ahihi123  postgres:17.4-bookworm
```

1. Create `.env`
```properties
MASTER_PGHOST=localhost
MASTER_PGPORT=5432
MASTER_PGDATABASE=postgres
MASTER_PGUSER=postgres
MASTER_PGPASSWORD=ahihi123
```
2. Build docker
```bash
$ docker build -t test .
```
3. Run for dev
```bash
$ docker run -it --network=host --env-file=.env -v $PWD:/workspace --entrypoint bash test
```

## Configurations
1. Users
- Create user files in `./configs/users`, with filenames ending in `.yml`
- For each user file, a corresponding user will be created. The user's name will match the file name.
- The user config is taken from the file content - see [docs link](https://docs.ansible.com/ansible/latest/collections/community/postgresql/postgresql_user_module.html#ansible-collections-community-postgresql-postgresql-user-module). Include:
    + `comment`
    + `configuration`
    + `conn_limit`
    + `expires`
    + `role_attr_flags`
- For each user, there must be a corresponding env var for the password, following the pattern is `PG_USER_PASSWORD_{USERNAME}`
2. Databases
- Create database files in `./configs/databases`, with filenames ending in `.yml`
- For each file, a corresponding database will be created. The database's name will match the file name.
- The database config is taken from the file content - see [docs link](https://docs.ansible.com/ansible/latest/collections/community/postgresql/postgresql_db_module.html#ansible-collections-community-postgresql-postgresql-db-module). Include:
    + `comment`
    + `conn_limit`
    + `owner`
    + `template`
