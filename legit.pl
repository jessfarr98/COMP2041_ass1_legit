#!/usr/bin/perl

#created by z5113609
#COMP2041: Software Construction, semester 2, 2018
#program called legit.pl which is a subset of the git version control system

use strict;
use warnings;
use File::Copy;

#TO DO LIST:
#fix add so it doesn't add files that have been committed
#think of test cases that cover the edge cases
#start subset 1

#Subset 0 implementations

#A THOUGHT FOR LATER:
#to make it less computationally expensive separate by argument numbers so it doesn't have to analyse several if statements to execute

#separate each command into functions in case they require each other's features

if ($ARGV[0] eq "init") {
	init();

} elsif ($ARGV[0] eq "add") {
	my @files = @ARGV[1..$#ARGV];

	add(@files);

 
} elsif ($ARGV[0] eq "commit") {
	#print "$ARGV[1]\n";
	if($ARGV[1] =~ /[^(\-a)(\-m)]/){
		print "usage: legit.pl commit [-a] -m commit-message\n" and exit 0;
	}
	if(@ARGV == 3){
		my $message = $ARGV[2];

		commit($message);
	}else{
		#cause all the files already in the index to have the most recent versions of the files added
		#print("-a flag\n");
		my $message = $ARGV[3];
		#go through the index, create a list of the files in the index
		my @index_files;
		foreach my $path (glob "./.legit/index/*") {
			my @dirs = split '/', $path;
			my $file_name = $dirs[$#dirs];
			push @index_files, $file_name;
		}

		add(@index_files);
		commit($message);
	}
} elsif ($ARGV[0] eq "log") {
	legit_log();


} elsif ($ARGV[0] eq "show") {
	#error checking: incorrect input
	if (@ARGV == 1) {
		print "usage: legit.pl show <commit>:<filename>\n" and exit 0;
	}
	if ($ARGV[1] !~ /.*:.*/) {
		print "legit.pl: error: invalid object $ARGV[1]\n" and exit 0;
	}
	my $parameters = $ARGV[1];
	my @params = split ':', $parameters;

	show($params[0], $params[1]);

} elsif ($ARGV[0] eq "rm") {
	if($ARGV[1] eq "--cached"){
	#remove the files from the index only

	} elsif ($ARGV[1] eq "--force") {
	#ignore all error checking

	} else {
	#error message if removing a file in the current directory thats different to the last commit
	#error message if removing a file from the index if different to the last commit



	}
} elsif ($ARGV[0] eq "status") {


}

#SUBSET 0 subroutines:

#A function to initialise the .legit repository if required
sub init {
	my $legit = ".legit";
	my $index = "index";
	#the directory already exists print an error message and exit with error status
	if (-d "$legit") {
		#print "exists\n";
		print "legit.pl: error: .legit already exists\n";
	} else {
	#create the directory
		#print ".legit does not exist\n";
		mkdir "$legit";
		print "Initialized empty legit repository in .legit\n";
		#in addition, create subdirectory in .legit for add called .index
		mkdir "./.legit/index";
		
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

	#if the .legit directory hasn't been created then print an error
	unless(-d ".legit"){
		print "legit.pl: error: no .legit directory containing legit repository exists\n";
	}

	while(my $element = shift @add_files){
		#print "element is '$element'\n";
		#if a file doesn't exist then don't add it
		unless(-e "$element"){
			print "legit.pl: error: can not open '$element'\n";
			next;
		} 
		#if the file is empty then don't add it to the index
		open my $F, '<', $element;
		my @element_array;
		foreach my $line (<$F>) {
			push @element_array, $line;
		}

		close $F;

		#check if the file is in the most recent commit in the same state
		my $num_coms = 0;
		foreach my $commit (glob "./.legit/commits/commit.*") {
			$num_coms++;
		}
		#print "num coms is $num_coms\n";		
		if ($num_coms > 0) {
			#print "num coms = $num_coms greater than 0\n";
			#decrement to get to get the most recent commit directory
			$num_coms--;
			my @prev_com;
			foreach my $file (glob "./.legit/commits/commit.$num_coms/*") {
				#load into the array for comparison
				#print "'$file'"."\n";
				my @dir_of_file = split '/', $file;
				my $regex = $dir_of_file[$#dir_of_file];
				#print "$regex\n";

				if ($regex =~ /^$element$/) {
					#print "equals\n";
					open $F, '<', $file;
					foreach my $line (<$F>) {
						push @prev_com, $line;
					}
					close $F;
				}
			}

			if (@prev_com eq @element_array) {
			#compare the files since the length of the files are the same
				my $diff = 0;
				foreach my $i (0..$#element_array) {
					#print "prev $prev_com[$i]";
					#print "new $element_array[$i]";
					#if ($element_array[$i] != $prev_com[$i]) {
					#	$diff = 1;
					#	last;
					#}
					if ($prev_com[$i] =~ /[^0-9]+/) {
					#lexicographical comparison
						if($prev_com[$i] ne $element_array[$i]){
							$diff = 1;
							last;
						}
					}else{
						if($element_array[$i] != $prev_com[$i]){
							#print "prev $prev_com[$i]";
							$diff = 1;
							last;
						}
					}
					
				}
				#print "$diff\n";
				if($diff == 0){
					unlink ".legit/index/$element";
					next;
					#$dont_add = 1;
				}
			}
		}

		copy $element, "./.legit/index";
	}
}

#commit adds the files in the index to the repository
sub commit {
	my ($message) = @_;

	#check that the index has files it is able to commit
	my $empty = 0;
	foreach my $add_file(glob "./.legit/index/*"){
		$empty++;
	}
	if($empty == 0){
		print "nothing to commit\n" and exit 0;
	}

	#create a commits directory if it doesn't exist yet
	unless(-d "./.legit/commits"){	
		mkdir "./.legit/commits";
	}

	#determine the name/signature of the new commit directory and create it
	my $num_dirs = 0;
	foreach my $dir(glob "./.legit/commits/*"){
		$num_dirs++;
	}
	my $new_commit = "commit".".$num_dirs";
	mkdir "./.legit/commits/$new_commit";

	#now move everything from index to this new directory.
	foreach my $commit_file(glob "./.legit/index/*"){
		copy $commit_file, "./.legit/commits/$new_commit";
	}

	#print the message into its own file and place this file in the directory as a .txt file
	my $commit_message = "commit_message.txt";

	open my $F, '>', $commit_message or die "cannot write to $commit_message: $?\n";
	print $F "$message"."\n";

	move $commit_message, "./.legit/commits/$new_commit/";

	close $F;
	print "Committed as commit $num_dirs\n";

}

#have an array that stores every commit's message in the corresponding commits message
#print these messages 

#TO DO: print the log in the reverse order
sub legit_log {
	#print all the commits and their messages

	my @logs;
	foreach my $commit (glob "./.legit/commits/commit.*/*"){
		#print "$commit\n";
	 	if($commit =~ "./.legit/commits/commit.([0-9]+)/commit_message.txt"){
			open my $F, '<', $commit or die "can't open $commit: $?\n";
			foreach my $line(<$F>){
				#print "$1 $line";
				push @logs, "$1 $line";
			}
			close $F;
		}
	}

	foreach my $element(reverse @logs){
		print "$element";
	}
}

#go to the specified commit directory in the .legit directory and print the specified files in the subsequent dir.
sub show {
	my ($commit, $file) = @_;
	if ($commit eq "") {
	#go through the commits in the index and print the files contents
		#print "empty\n";
		if(-e "./.legit/index/$file"){
			open my $F, '<', "./.legit/index/$file" or die "can't open $file: $?\n";
			foreach my $line(<$F>){
				print "$line";
			}
			close $F;
		}else{
			print "legit.pl: error: '$file' not found in index\n"

		}
	} elsif ($commit =~ /[0-9]+/){
	#go to the specified commit and print the specified commit
		#print "num\n";

		unless(-d "./.legit/commits/commit.$commit"){
			print "legit.pl: error: unknown commit '$commit'\n" and exit 0;
		}

		if(-e "./.legit/commits/commit.$commit/$file"){
			open my $F, '<', "./.legit/commits/commit.$commit/$file" or die "can't open $file: $?\n";
			foreach my $line(<$F>){
				print "$line";
			}
			close $F;
		}else{
			print "legit.pl: error: '$file' not found in commit $commit\n"

		}

	} #else {
		#print "invalid input, Usage: show <digit/empty string>:<filename>\n" and exit 0;
	#}
}

#SUBSET 1 subroutines
sub legit_rm {
	

}


