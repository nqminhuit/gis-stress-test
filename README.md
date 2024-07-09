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
source run.sh
```
Observe repositores at: http://localhost:9898/

# Report sample

Performance is run with:
- number of submodules: `10`
- number of branch per submodules: `10`
- number of files per submodules: `100`
- number of commit per submodules: `100`
- each file size: `52.0K`

```
command              min(ms)  mean(ms) max(ms) 
gis                  17       34       83      
branches             15       35       85      
branches_no_modules  14       30       112     
checkout             14       34       93      
fetch                112      157      238     
files                56       69       100     
status               17       35       88      
```

gis version: `gis 2.0.0-dev (commit 2730d45)`
git version: `git version 2.45.2`
hyperfine version: `hyperfine 1.18.0`

CPU info:
```
CPU op-mode(s):                     32-bit, 64-bit
CPU(s):                             8
On-line CPU(s) list:                0-7
Model name:                         Intel(R) Core(TM) i7-8665U CPU @ 1.90GHz
CPU family:                         6
CPU max MHz:                        4800.0000
CPU min MHz:                        400.0000
NUMA node0 CPU(s):                  0-7
Vulnerability Mmio stale data:      Mitigation; Clear CPU buffers; SMT vulnerable
```
