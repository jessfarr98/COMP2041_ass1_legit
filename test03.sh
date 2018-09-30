#!/bin/sh

#test script testing behaviour when no required directories exist

touch test1 test2 test3
echo "test1 line 1" > test1
echo "test2 line 1" > test2
echo "test3 line 1" > test3
chmod 755 ./legit.pl
./legit.pl add test1 test2  #correct
./legit.pl commit -m "first"		#correct
./legit.pl show 0:test1		#correct
./legit.pl log
./legit.pl add test3
./legit.pl commit -m
./legit.pl commit -y "invalid input"
./legit.pl commit --m "first"
./legit.pl commit
./legit.pl init
./legit.pl add test1 test2
./legit.pl show 0:test1
./legit.pl show a:test1
./legit.pl show :test1
./legit.pl show :test2
./legit.pl show :test3
./legit.pl show a
./legit.pl show a:a
rm -rf ./legit
./legit.pl show 0:test1
rm test1 test2 test3

