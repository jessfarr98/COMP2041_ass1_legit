#!/bin/sh

#testing the behaviour of commit using subset0 features

touch test1 test2 test3 test4
echo "test_file 1" > test1
echo "test_file 2" > test2
echo "test_file 3" > test3
echo "test_file 4" > test4
chmod 755 ./legit.pl
./legit.pl init
./legit.pl add test1 test2 
./legit.pl commit -m "first"
#commit without adding
./legit.pl commit -m "try again"
#expected output: nothing to commit, no directory produced
./legit.pl show 1:test1
#unknown commit '1'
#change one of the files in the prev commit/index then commit
echo "line 2" >> test1
./legit.pl add test1 test2
./legit.pl commit -m "second"
./legit.pl show 1:test1
./legit.pl show 1:test2
#add files that haven't been changed
./legit.pl add test1 test2
./legit.pl commit -m "unchanged"
#expected output: nothing to commit
./legit.pl show 2:test1
#add files that haven't been added yet
./legit.pl add test3
./legit.pl commit -m "third"
./legit.pl log
./legit.pl show 2:test1
./legit.pl show 2:test2
./legit.pl show 2:test3
./legit.pl add test4

#test the possible input errors
./legit.pl commit
./legit.pl commit -y "non-existent flag"
#just the -m flag
./legit.pl commit -m
./legit.pl commit --m "invalid"
#the -a flag
./legit.pl commit -m -a "wrong order of flags"
./legit.pl commit -a "invalid"
./legit.pl commit --a -m "invalid"
./legit.pl commit -a -m
./legit.pl log

#error message when the .legit rep hasn't been initialised

rm test1 test2 test3 test4
rm -rf .legit
