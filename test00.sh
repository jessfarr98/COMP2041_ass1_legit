#!/bin/sh

#a simple subset0 test that tests the multiple possible behaviours of adding empty files and files with content.

touch test1 test2 test3
echo "test 1 line 1"  > test1
echo "test 2 line 1" > test2
chmod 755 ./legit.pl
./legit.pl init
#adding many files at a time, one of which is empty
./legit.pl add test1 test2 test3
./legit.pl commit -m "first commit"
./legit.pl log
./legit.pl show 0:test1
./legit.pl show 0:test2
./legit.pl show 0:test3
#adding when a file has not been changed
./legit.pl add test1
./legit.pl commit -m "adding and committing an unchanged file"
./legit.pl log
./legit.pl show 1:test1
touch test4
#numerical values in the file
echo 1 > test4
./legit.pl add test4
./legit.pl commit -m "add numerical file"
./legit.pl add test4
./legit.pl commit -m "test4 should not be committed"
./legit.pl show 2:test4
./legit.pl add
#adding a file that doesn't exist
./legit.pl add not_exist
./legit.pl log

#clean the directory 
rm test1 test2 test3 test4
rm -rf .legit
