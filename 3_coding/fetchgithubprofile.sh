#!/bin/bash


if [[ ! -z $1 && ! -z $2  ]]; 
then 
    echo ""
else 
     echo "Parameter value missing, exiting"	
     exit 1
fi



curl -s  -u $1:$token https://api.github.com/users/$2 > /tmp/userinfo.txt
if [ $? -eq 0 ];
then
userbio=`cat /tmp/userinfo.txt | grep bio | cut -d ":" -f 2 | tr -d ','`
usercomp=`cat /tmp/userinfo.txt | grep company | cut -d ":" -f 2 | tr -d ','`
usernm=`cat /tmp/userinfo.txt | grep name | grep -v null | cut -d ":" -f 2 | tr -d '",'`
userlc=`cat /tmp/userinfo.txt | grep location | cut -d ":" -f 2 | tr -d ','`
userpr=`cat /tmp/userinfo.txt | grep public_repos | cut -d ":" -f 2 | tr -d ','`
userfl=`cat /tmp/userinfo.txt | grep followers | grep -v url | cut -d ":" -f 2 | tr -d ','`


echo "GitHub user $2 fullname is $usernm and user company name is $usercomp. User bio is $userbio and user location is $userlc. User has $userpr public repo and $userfl followers."

else 
     echo "unable to fetch details"
     exit 1

fi 
