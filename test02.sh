#!/bin/sh

#test script testing the behaviour of show using subset 0 commands

touch test1 test2 test3
echo "test1 line 1" > test1
echo "test2 line 1" > test2
echo "test3 line 1" > test3
chmod 755 ./legit.pl
./legit.pl init
./legit.pl add test1 test2
./legit.pl commit -m "first"
./legit.pl show 0:test1
./legit.pl show 0:test2
./legit.pl show 0:test3
./legit.pl show 1:test1
./legit.pl add test3 
./legit.pl commit -m "second"
./legit.pl show 1:test1
./legit.pl show 1:test2
./legit.pl show 1:test3
./legit.pl show 0:test3
#in the index
./legit.pl show :test1
./legit.pl show :test2
./legit.pl show :test4
echo "test4 line 1" > test4
./legit.pl add test4
./legit.pl show :test4

#error message testing
echo "show a"
./legit.pl show a
echo "show test1"
./legit.pl show test1
echo "show 0:a"
./legit.pl show 0:a
echo "show 2:test1"
./legit.pl show 2:test1
echo "show a:test1"
./legit.pl show a:test1
echo "show a:a"
./legit.pl show a:a
echo "show"
./legit.pl show

#error message when no commits have occurred
rm -rf .legit/commits
./legit.pl show 0:test1


rm test1 test2 test3
rm -rf .legit
