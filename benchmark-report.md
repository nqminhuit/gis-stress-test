Performance is run with:
- number of submodules: `10`
- number of branch per submodules: `10`
- number of files per submodules: `100`
- number of commit per submodules: `100`
- each file size: `52.0K`

```
command              min(ms)  mean(ms) max(ms) 
gis                  16       30       83      
branches             13       27       77      
branches_no_modules  13       31       108     
checkout             13       31       96      
fetch                140      167      195     
files                53       64       94      
status               15       35       114     
```

gis version: `gis 2.0.0-dev (commit 2730d45)`
git version: `git version 2.45.2`
hyperfine version: `hyperfine 1.18.0`
