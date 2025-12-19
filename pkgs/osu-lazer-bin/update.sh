#!/usr/bin/env -S nix shell nixpkgs#curl nixpkgs#jq nixpkgs#xxd -c bash
set -eu

OUT_FILE="pkgs/osu-lazer-bin/data.json"
releases="$(curl -fsSL "https://api.github.com/repos/ppy/osu/releases")"

sri_hash() {
    algo=${1%%:*}
    hex=${1#*:}
    echo "$algo-$(echo "$hex" | xxd -r -p | base64)"
}

process_release() {
    suffix=$1

    release=$(echo "$releases" | jq -c --arg suffix "$suffix" \
        'sort_by(.published_at) | reverse | map(select(.name | endswith($suffix))) | first')

    if [ "$release" = "null" ]; then
        echo "No release found with suffix $suffix" >&2
        exit 1
    fi

    version=$(echo "$release" | jq -r '.name')
    published_at=$(echo "$release" | jq -r '.published_at')
    das_hash=$(sri_hash "$(echo "$release" | jq -r '.assets[] | select(.name=="osu.app.Apple.Silicon.zip") | .digest')")
    di_hash=$(sri_hash "$(echo "$release" | jq -r '.assets[] | select(.name=="osu.app.Intel.zip") | .digest')")
    ai_hash=$(sri_hash "$(echo "$release" | jq -r '.assets[] | select(.name=="osu.AppImage") | .digest')")

    jq -n --arg v "$version" --arg pa "$published_at" --arg das "$das_hash" --arg di "$di_hash" --arg ai "$ai_hash" \
        '{version: $v, "published-at": $pa, "darwin-apple-silicon-hash": $das, "darwin-intel-hash": $di, "appimage-hash": $ai}'
}

lazer_json=$(process_release "-lazer")
tachyon_json=$(process_release "-tachyon")

jq -n --argjson lazer "$lazer_json" --argjson tachyon "$tachyon_json" \
    '{latest: if $lazer["published-at"] > $tachyon["published-at"] then "lazer" else "tachyon" end, lazer: $lazer, tachyon: $tachyon}' > "$OUT_FILE"
