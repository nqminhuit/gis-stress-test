# Gitbucket Howto

Build and deploy:
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
podman kube play --replace deploy.yaml --build; podman logs -f stress-test-scripts
```
Observe repositores at: http://localhost:9898/

# Report sample

====================== POST REPORT ======================
Performance is run with:
- number of submodules: `10`
- number of branch per submodules: `10`
- number of files per submodules: `100`
- number of commit per submodules: `100`
- each file size: `100.0K`


command              min(ms)  mean(ms) max(ms)
gis                  8        32       111
branches             7        22       77
branches_no_modules  6        26       89
checkout             9        29       87
fetch                30       47       88
files                34       50       90
status               9        32       92


gis version: `2.0.0-dev`
git version: `git version 2.45.2`
hyperfine version: `hyperfine 1.18.0`
