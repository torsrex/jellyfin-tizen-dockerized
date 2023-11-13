#!/usr/bin/expect -f
set timeout -1
spawn tizen package -t wgt -o . -s jellyfin -- .buildResult
expect "Author password:"
send "1234\r"
expect "Yes: (Y), No: (N) ?"
send -- "Y\r"
expect eof