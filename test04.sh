#!/bin/sh

#test script that tests the behaviour of commit -a from subset1

touch test1 test2 test3
echo "test1 line 1"  > test1
echo "test2 line 1" > test2
chmod 755 ./legit.pl
./legit.pl init
./legit.pl add test1 test2
./legit.pl commit -m "first"
./legit.pl add test3
echo "test3 line1" > test3
./legit.pl commit -a -m "second"
./legit.pl log
./legit.pl show 1:test1
./legit.pl show 1:test3
./legit.pl show :test3

#error testing
echo "test1 line2" >> test1
./legit.pl add test1
./legit.pl commit -a
./legit.pl commit -m -a "invalid"
./legit.pl commit -a "invalid"
./legit.pl commit -a -g "invalid"
./legit.pl commit --a -m "invalid"
./legit.pl commit --a --m "invalid"
./legit.pl commit -t -a "invalid"
./legit.pl log

rm -rf .legit
rm test1 test2 test3

