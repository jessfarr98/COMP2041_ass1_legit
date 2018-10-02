#!/bin/sh

#test script testing the behaviour of rm --cached from subset 1

touch test1 test2 test3
echo "test1 line 1"  > test1
echo "test2 line 1" > test2
echo "test3 line 1" > test3
echo "test4 line 1" > test4
echo "test5 line 1" > test5
chmod 755 ./legit.pl
./legit.pl init
./legit.pl add test1 test2 test5
./legit.pl commit -m "first"
#general case
./legit.pl rm --cached test1
