#!/bin/bash

# This worsk as long as we only release a single asset.
url_latest=$(wget -q -O - https://api.github.com/repos/distributed-technologies/yggdrasil/releases/latest | grep browser_download_url | cut -d \" -f 4 )

if !(cat helm_requirements.txt 2> /dev/null | grep $url_latest 1> /dev/null) then 
    echo "$url_latest nidhogg yggdrasil" > helm_requirements.txt
fi

