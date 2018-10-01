#!/bin/sh

#test script testing the behaviour of rm from subset 1


touch test1 test2 test3
echo "test1 line 1"  > test1
echo "test2 line 1" > test2
echo "test3 line 1" > test3
chmod 755 ./legit.pl
./legit.pl init
./legit.pl add test1 test2
./legit.pl commit -m "first"
./legit.pl show 0:test1
./legit.pl show 0:test2
./legit.pl rm test1
#test1 file should be removed from the current directory and the index
ls test*
ls .legit/index
./legit.pl show 0:test1
./legit.pl rm test3
#test3 should not be removed from the currect directory. Print error message about file not being in the legit repo
ls test*
./legit.pl add test3
./legit.pl rm test3
#test3 should still be present in the current directory and the index. Print error message "legit.pl: error: 'file' has changes staged in the index"
ls test*
ls .legit/index
./legit.pl commit -m "second"
./legit.pl show 1:test3
./legit.pl rm test3
#test3 should be removed from the index and the current directory
ls test*
ls .legit/index
./legit.pl show 1:test3

#error testing
#when no commits have occurred

#rm file not in current directory but in index
#no issue runs as normal

#rm file in current directory not in index
#print "legit.pl: error: 'file' not in the legit repository"

#rm file not in either
#print "legit.pl: error: 'file' not in the legit repository"

#rm file recreated after removing from current dir and index then rm run on it again
#print "legit.pl: error: 'file' in repository is different to working file"

./legit.pl rm null_file

rm -rf .legit
rm test2



