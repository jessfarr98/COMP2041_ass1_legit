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

	#NOTE need to pass in a refernce so that its changed outside of the function scope
	commit($message, @commit_array);

	#print the commit array

} elsif ($ARGV[0] eq "log") {



} elsif ($ARGV[0] eq "show") {



} elsif ($ARGV[0] eq "rm") {


} elsif ($ARGV[0] eq "status") {


}
#SUBSET 0 subroutines:

#A function to initialise the .legit repository if required
sub init {
#initialise the directory called .legit
	#the directory already exists print an error message and exit with error status
	my $legit = "legit";
	my $index = "index";

	if (-d "$legit") {
		#print "exists\n";
		print "$0: error: $legit already exists\n";
	} else {
	#create the directory
		#print ".legit does not exist\n";
		mkdir "$legit";
		print "Initialised empty legit repository in $legit\n";

		#in addition, create subdirectory in .legit for add called .index for the add files
		mkdir "./legit/index";
		
	}
}

#create a subdirectory called index and store the files in here
#assume only files are input. Don't worry about directories
#think about using function signatures?
sub add {

	#WHAT IF THIS ARRAY IS EMPTY?
	my (@add_files) = @_;
	#print join "\n", @add_files;
	#print "\nmoving the files into the .index directory\n";
	while(my $element = shift @add_files){
		#print "element is $element\n";

		#create a copy of the file
		#my $temp = ".".$element;
		#open my $TEMP, '>', $temp or die "unable to write to the $temp file: $?\n";
		#open my $FILE, '<', $element or die "unable to open $element: $?\n";
		#foreach my $line(<$FILE>) {
		#	print $TEMP $line;
		#}	
		#move that copy into the .index directory

		#WHAT IF THE FILE IS ALREADY IN INDEX?
		#move "$temp", "./legit/index";
		copy $element, "./legit/index";

		#close $TEMP;
		#close $FILE
	}
}

#commit adds the files in the index to the repository
#in the repo maybe create multiple sub directories
#if the index is empty then say nothing to commit.
#empty the index after committing
sub commit {
	my ($message, @commits) = @_;
	#print "$message\n";
	#PLAN
	#if no commits directory exists then create it. 
	#if index is empty print an error message and die
	#Go through all the commits in the directory until at the last one. 
	#create a directory that has this form commit.n+1 where n was the num of the prev commit dir.

	#check that the index has files it is able to commit
	my $empty = 0;
	foreach my $add_file(glob "./legit/index/*"){
		$empty++;
	}
	if($empty == 0){
		print "Nothing to commit\n" and exit 0;
	}

	#create a commits directory if it doesn't exist yet
	unless(-d "./legit/commits"){	
		mkdir "./legit/commits";

	}

	#determine the name/signature of the new commit directory and create it
	my $num_dirs = 0;
	foreach my $dir(glob "./legit/commits/*"){
		$num_dirs++;
	}
	my $new_commit = "commit".".$num_dirs";
	mkdir "./legit/commits/$new_commit";

	#now move everything from index to this new directory.
	foreach my $commit_file(glob "./legit/index/*"){
		move $commit_file, "./legit/commits/$new_commit";
	}

	#now update the commits array with the message
}

#have an array that stores every commit's message in the corresponding commits message
#print these messages 
sub log {


}

#go to the specified commit directory in the .legit directory and print the specified files in the subsequent dir.
sub show {



}

#SUBSET 1 subroutines





