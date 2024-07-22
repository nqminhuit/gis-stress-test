#!/bin/bash

# "0aa49f31fa36b19e45fdb48026b01cb5e10a24f2"
# "742ebe69eabddcc668ab5713e9a62f481dd93ea9"
# "2730d45cf7711509c17488b2f8f18d8185c46401"
# "36a126dda951352465a1e19b688dc76ce5bc8efd"
# "af04688cb235783f8b9d0036ade315a9df644fb0"
# "de1156d0f2e5a39ccc829ee430f309d1f1112a85"
# "4a1ba21271ee534b1904b40373eea3ced3d4232e"
# "ff556b951bd003326bf9202b289a489f23d64457"
# "d350be0ff4147cfc77e3b41024397cb9942910f3"
# "e284373f2819fc4136954e8d50adbe8c75cf33e5"
# "eceef9b7ca4eb497204090e992bd2711871c4cff"
# "ad25eea6735d0d9a86ba507fa56da9332e011e80"
# "0c6ed79efe07ddd7f6eeab7b789bdeae15d5cdc4"
# "4cfe04dfa1e9ca93f56dd69250bfe40ff6133966"
# "a73ea05ef4a0b2589cbe52b34a167ae7ca9052a2"
# "bd33a8d559d86301fc77b66232c9cfc1d6ae5c43"
# "5aa5ca5a97acc7abd9606dcb10c7c01e52693b5f"
commits=(
    "ed69429ac554a0fde15bbdc5d52fd3d587f18f74"
    "7991cb330e096155747a476db6f8b00a251634af"
    "4a79b70840aa776c33443725e795ddf58beda038"
)


for c in $commits
do {
        curl -L -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $1" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/nqminhuit/gis-stress-test/actions/workflows/stress-test-small.yml/dispatches -d '{"ref":"master", "inputs":{"commit":"'"$c"'"}}'
        sleep 60
    }
done
