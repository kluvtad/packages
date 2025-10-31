## Local dev
1. Create `.env`
```properties
MASTER_PGHOST=localhost
MASTER_PGPORT=5432
MASTER_PGDATABASE=postgres
MASTER_PGUSER=postgres
MASTER_PGPASSWORD=...
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
- Create user files in `./users`, with filenames ending in `.yml`
- For each user file, a corresponding user will be created. The user's name will match the file name.
- The user config is taken from the file content - see [docs link](https://docs.ansible.com/ansible/latest/collections/community/postgresql/postgresql_user_module.html#ansible-collections-community-postgresql-postgresql-user-module). Include:
    + `comment`
    + `configuration`
    + `conn_limit`
    + `expires`
    + `role_attr_flags`
- For each user, there must be a corresponding env var for the password, following the pattern is `PG_USER_PASSWORD_{USERNAME}`