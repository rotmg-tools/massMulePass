dos2unix $1 && sed "s/\"//g" $1 | sed "s/'//g" | sed "s/\://g" | sed "s/\,//g" | sed "s/var accounts = {//g" | sed "s/}//g" | sed '/^$/d' > $2
