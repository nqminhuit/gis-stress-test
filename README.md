# How to

```bash
podman build -t gitbucket:4.41.0 .
podman run -d -p 9898:8080 --name gitbucket gitbucket:4.41.0
```
app is available at: http://localhost:9898/

or use official docker image:
```bash
docker run -d -p 8080:8080 ghcr.io/gitbucket/gitbucket:4.39.0
```

Sign in with `root/root`

create token: 143add06e3ea8a42a67f22fbcb88a2230728b731

create new repository with your token:
```
curl -X POST -H "Accept: application/json" -H "authorization: token 143add06e3ea8a42a67f22fbcb88a2230728b731" http://localhost:9898/api/v3/user/repos -d '{"name":"Hello-World-8","private":false}'
```

