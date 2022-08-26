#!/bin/bash

set -euo pipefail

while ! nc -z mongodb 27017; do
  sleep 0.1
done

echo Starting dub registry
export PATH="/opt/dub-registry:/dub:$PATH"
cd /opt/dub-registry

if [[ -e /dub/settings.json ]] ; then
    ln -s /dub/settings.json /opt/dub-registry/settings.json
fi

# start the registry
./dub-registry --bind 0.0.0.0 --p 9095
