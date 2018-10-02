#!/bin/sh

#test script testing the behaviour of rm from subset 1

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
./legit.pl show 0:test1
./legit.pl show 0:test2
echo "rm test1 and test5 file in last commit"
./legit.pl rm test1 test5
#test1 and test5 file should be removed from the current directory and the index
ls 
ls .legit/index
./legit.pl show 0:test1
./legit.pl show 0:test5
echo "rm test3 file not in the last commt or index"
./legit.pl rm test3
#test3 should not be removed from the currect directory. Print error message "legit.pl: error: 'test3' not in the legit repository"
ls 
ls .legit/index
./legit.pl add test3
echo "rm test3 file in the index but not committed"
echo ""
./legit.pl rm test3
#test3 should still be present in the current directory and the index. Print error message "legit.pl: error: 'file' has changes staged in the index"
ls
ls .legit/index
./legit.pl commit -m "second"
./legit.pl show 1:test3
echo "rm file test3 that has been committed"
echo ""
./legit.pl rm test3
#test3 should be removed from the index and the current directory
ls
ls .legit/index
./legit.pl show 1:test3
#rm a file that has been committed in a commit that was not the previous commit


#error testing

#rm file not in current directory but in index
#no issue runs as normal
echo "rm file in index but not in current directory"
echo ""
rm test2
./legit.pl rm test2
ls
echo "index"
ls .legit/index
./legit.pl show :test2

#rm file in current directory not in index
#print "legit.pl: error: 'file' not in the legit repository"
echo "rm file in current directory not in index"
echo ""
./legit.pl add test4
rm .legit/index/test4
./legit.pl rm test4
ls
ls .legit/index
./legit.pl show :test4

#rm file not in either
#print "legit.pl: error: 'file' not in the legit repository"
echo "rm file not in directory or index\n"
./legit.pl rm test6

#rm file that has been changed after being added to the repository
#print "legit.pl: error: 'file' in repository is different to working file"
echo "test1 recreated" > test1
./legit.pl add test1
./legit.pl commit -m "third"
echo "test1 new line" >> test1
./legit.pl rm test1

#when a file has been removed with unix rm then added the file gets removed from the index


#when no commits have occurred


rm -rf .legit
#rm test2



