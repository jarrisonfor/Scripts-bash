#!/bin/bash
chat_id="chatid"
token="tokenbot"
msg="$1"
curl -s -F chat_id=$chat_id -F text="$msg" https://api.telegram.org/bot$token/sendMessage > /dev/null
