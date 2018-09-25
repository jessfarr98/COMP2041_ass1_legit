#!/usr/bin/perl

#created by z5113609
#COMP2041: Software Construction, semester 2, 2018
#program called legit.pl which is a subset of the git version control system

use strict;
use warnings;

#Subset 0 implementations

#A THOUGHT FOR LATER:
#to make it less computationally expensive separate by argument numbers so it doesn't have to analyse several if statements to execute

#separate each command into functions in case they require each other's features

if ($ARGV[0] eq "init") {
	init();
} elsif ($ARGV[0] eq "add") {

}


#A function to initialise the repository if required
sub init {
	#initialise the subdirectory called .legit
	#my $subdir = "\.legit";
	#the subdirectory already exists print an error message and exit with error status
	if (-d "\.legit") {
		#print "exist\n";
		print "$0: error: .legit already exists\n";
	} else {
	#create the subdirectory
		#print "not exist\n";
		mkdir ".legit";
		print "Initialised empty legit repository in .legit\n"
	}
}

#a function to add files to the .legit repository
#create a subdirectory called index and store the files in here
#assume inly files are input. Don't worry about directories
#think about using function signatures?
sub add {
	

}

#commit adds the files in the index to the repository
#in the repo maybe create multiple sub directories
#if the index is empty then say nothing to commit.
#empty the index after committing
sub commit {

}

#have an array that stores every commit that has been made
sub log {


}


sub show {



}



