#!/bin/bash

#script to update current time and date from google (i hate setting it by myself every damn time and kde isnt helping)

Date=$(curl -v --silent https://google.com/ 2>&1 \
   | grep Date | sed -e 's/< Date: //'); date +"%Y%m%d" 

Time=$(curl -v --silent https://google.com/ 2>&1 \
   | grep Date | sed -e 's/< Date: //'); date "+%H%M%S" 

sudo date +%Y%m%d -s "$Date"
#sudo date +%T  -s "$Time"