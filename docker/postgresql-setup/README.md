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