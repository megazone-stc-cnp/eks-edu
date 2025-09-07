#!/bin/bash

# ==================================================================
if [ ! -d "tmp" ]; then
    mkdir -p tmp
fi
# linux: echo $(base64 -w 0 userdata.sh.data)
# python3 -c "import base64; print(base64.b64encode(open('userdata.sh.data', 'rb').read()).decode())"
if [[ "$OSTYPE" == "darwin"* ]]; then
  base64 ./tmp/userdata.sh.data | tr -d '\n'
else
  base64 -w 0 ./tmp/userdata.sh.data
fi