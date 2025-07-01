### For Dev
```
$ docker build -t test .
$ docker rm githook && docker run -it --env-file $PWD/.env -p 8080:8080 -v $PWD:/workspace --name githook test
```

