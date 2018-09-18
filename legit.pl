#!/usr/bin/perl

#created by z5113609
#COMP2041: Software Construction, semester 2, 2018
#program called legit.pl which is a subset of the git version control system

use strict;
use warnings;

#Subset 0 content

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
sub add {
	

}



