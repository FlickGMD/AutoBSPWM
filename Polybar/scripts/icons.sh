#!/bin/bash

declare -i counter=0

discord(){
  echo " "
}

htb(){
  echo "󰆧 "
}

close(){
 echo " "
}

while getopts "dhx" arg; do
  case $arg in
  d)let counter+=1;;
  h)let counter+=2;;
  x)let counter+=3
  esac
done

if [[ $counter -eq 1 ]]; then
  discord
elif [[ $counter -eq 2 ]]; then
  htb
elif [[ $counter -eq 3 ]]; then
  close
fi
