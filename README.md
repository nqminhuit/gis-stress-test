# Prepare

```bash
podman build -t gitbucket:4.41.0 .
podman run -d -p 9898:8080 --name gitbucket gitbucket:4.41.0
```
app is available at: http://localhost:9898/

or use official docker image:
```bash
podman run -d -p 8080:8080 ghcr.io/gitbucket/gitbucket:4.39.0
```

Sign in with `root/root`

create new repository with basic auth token (root:root):
```
curl -X POST -H "Accept: application/json" -H "authorization: Basic cm9vdDpyb290" http://localhost:9898/api/v3/user/repos -d '{"name":"Hello-World","private":false}'
```

# Run performance test inside container

```bash
podman build -t gis-stress-test scripts/ -f scripts/Containerfile
podman run -d --rm --name gis-stress-test gis-stress-test
```
