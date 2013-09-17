#!/bin/bash
# usage: bash md2txt.sh accounts.js mules.txt
# uses dos2unix

dos2unix $1 && sed "s/\"//g" $1 | sed "s/'//g" | sed "s/\://g" | sed "s/\,//g" | sed "s/var accounts = {//g" | sed "s/}//g" | sed '/^$/d' > $2
