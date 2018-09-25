#!/usr/bin/perl

#created by z5113609
#COMP2041: Software Construction, semester 2, 2018
#program called legit.pl which is a subset of the git version control system

use strict;
use warnings;
use File::Copy;

#Subset 0 implementations

#A THOUGHT FOR LATER:
#to make it less computationally expensive separate by argument numbers so it doesn't have to analyse several if statements to execute

#separate each command into functions in case they require each other's features
my @commit_array;


if ($ARGV[0] eq "init") {
	init();

} elsif ($ARGV[0] eq "add") {
	my @files = @ARGV[1..$#ARGV];

	add(@files);

#NOTE: this needs an if for when there's -a included 
} elsif ($ARGV[0] eq "commit") {
	my $message = $ARGV[2];

	#need to pass in a refernce so that its changed outside of the function scope
	commit($message, @commit_array);

	#print the commit array

} elsif ($ARGV[0] eq "log") {



} elsif ($ARGV[0] eq "show") {



} elsif ($ARGV[0] eq "rm") {


} elsif ($ARGV[0] eq "status") {


}
#SUBSET 0 subroutines:

#A function to initialise the repository if required
sub init {
	#initialise the subdirectory called .legit
	#the subdirectory already exists print an error message and exit with error status
	if (-d ".legit") {
		#print "exists\n";
		print "$0: error: .legit already exists\n";
	} else {
	#create the subdirectory
		#print ".legit does not exist\n";
		mkdir ".legit";
		print "Initialised empty legit repository in .legit\n";

		#in addition, create subdirectory for add called .index for the add files
		mkdir ".index";
		#my $legit = ".legit";
		#my $index = ".index";
	}
}

#create a subdirectory called index and store the files in here
#assume only files are input. Don't worry about directories
#think about using function signatures?
sub add {
	my (@add_files) = @_;
	#print join "\n", @add_files;
	#print "\nmoving the files into the .index directory\n";
	while(my $element = shift @add_files){
		#print "element is $element\n";

		#create a copy of the file
		my $temp = ".".$element;
		open my $TEMP, '>', $temp or die "unable to write to the $temp file: $?\n";
		open my $FILE, '<', $element or die "unable to open $element: $?\n";
		foreach my $line(<$FILE>) {
			print $TEMP $line;
		}	
		#move that copy into the .index directory
		my $dir = ".index";
		move "$temp", "$dir";

		close $TEMP;
		close $FILE
	}
}

#commit adds the files in the index to the repository
#in the repo maybe create multiple sub directories
#if the index is empty then say nothing to commit.
#empty the index after committing
sub commit {
	my ($message, @commits) = @_;
	print "$message\n";
	#create an directory callled .commit.n where n = @commits+1
	#move all the files in .index into .commit.n. Note move not copy
	#move the .commit.n directory into the .legit directory
}

#have an array that stores every commit's message in the corresponding commits message
#print these messages 
sub log {


}

#go to the specified commit directory in the .legit directory and print the specified files in the subsequent dir.
sub show {



}

#SUBSET 1 subroutines





