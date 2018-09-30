#!/usr/bin/perl

#created by z5113609
#COMP2041: Software Construction, semester 2, 2018
#program called legit.pl which is a subset of the git version control system

use strict;
use warnings;
use File::Copy;

#TO DO LIST:
#think of test cases that cover the edge cases. Complete subset 0 test cases
#COMMIT BUG: commits when supposed to say nothing to commit. This is because you only copy from the index now
#REASSESS FUNCTIONALITY
#COMMIT functionality. If a file is not present in the current directory then do not commit it? 
#plan/start status

#Subset 0 implementations

#separate each command into functions in case they require each other's features

if ($ARGV[0] eq "init") {
	init();

} elsif ($ARGV[0] eq "add") {
	if (@ARGV == 1) {
		print "legit.pl: error: internal error Nothing specified, nothing added.\n" and exit 0;
	}
	my @files = @ARGV[1..$#ARGV];

	add(@files);

 
} elsif ($ARGV[0] eq "commit") {
	#print "$ARGV[1]\n";
	if ($ARGV[1] =~ /[^(\-a)(\-m)]/) {
		print "usage: legit.pl commit [-a] -m commit-message\n" and exit 0;
	} if (@ARGV == 3) {
		my $message = $ARGV[2];

		commit($message);
	} else {
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
	if ($ARGV[1] eq "--force" && $ARGV[2] eq "--cached") {
		#print "force cache rm\n";
		my @directories = ("./.legit/index");
		my @files = @ARGV[3..$#ARGV];
		my $f = 1;
		legit_rm($f, \@directories, \@files);
		exit 0;
	}
	if ($ARGV[1] eq "--cached") {
	#remove the files from the index only
		#print "cache rm\n";
		my @directories = ("./.legit/index");
		my @files = @ARGV[2..$#ARGV];
		my $f = 0;
		legit_rm($f, \@directories, \@files);
	} elsif ($ARGV[1] eq "--force") {
	#ignore all error checking
		#print "removing with force\n";
		#directories, files, force
		#print "force rm \n";
		my @directories = ("./.legit/index",".");
		my @files = @ARGV[2..$#ARGV];
		#print "@files\n";
		my $f = 1;
		#print "$f\n";
		#array references are required for multiple array beig passed into to the array
		legit_rm($f, \@directories, \@files);
	} else {
	#error message if removing a file in the current directory thats different to the last commit
	#error message if removing a file from the index if different to the last commit
		#print "rm with safety\n";
		my @directories = ("./.legit/index", ".");
		my @files = @ARGV[1..$#ARGV];
		my $f = 0;
		legit_rm($f, \@directories, \@files);
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
	unless (-d ".legit") {
		print "legit.pl: error: no .legit directory containing legit repository exists\n";
	}

	while (my $element = shift @add_files) {
		#print "element is '$element'\n";
		#if a file doesn't exist then don't add it
		unless (-e "$element") {
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
			

			} if (@prev_com eq @element_array) {
			#compare the files since the length of the files are the same
				my $diff = 0;
				foreach my $i (0..$#element_array) {
					#print "prev $prev_com[$i]";
					#print "new $element_array[$i]";
					#if ($element_array[$i] != $prev_com[$i]) {
					#	$diff = 1;
					#	last;
					#}
					#print "hi\n";
					#if ($prev_com[$i] =~ /^[0-9]+$/) {
					#lexicographical comparison
						
					#	if($prev_com[$i] != $element_array[$i]){
					#		$diff = 1;
					#		last;
					#	}
					#}else{
					if ($element_array[$i] ne $prev_com[$i]) {
						#print "prev $prev_com[$i]";
						$diff = 1;
						last;
					}
					#}
					
				}
				#print "$diff\n";
				#if ($diff == 0) {
					#print "unlink\n";
				#	unlink ".legit/index/$element";
				#	next;
					#$dont_add = 1;
				#}
			}
		}

		copy $element, "./.legit/index";
	}
}

#commit adds the files in the index to the repository

#COMMIT NEW FUNCTIONALITY
#if there are no files in the index nothing to commit
#if a file in index has been changed then commit all the files in the index
#if none of the files have been changed print nothing to commit

sub commit {
	my ($message) = @_;
	#print "committing\n";
	#check that the index has files it is able to commit
	my $num_index_files = 0;
	foreach my $add_file (glob "./.legit/index/*") {
		$num_index_files++;
	}
	if ($num_index_files == 0) {
		print "nothing to commit\n" and exit 0;
	}

	#create a commits directory if it doesn't exist yet
	unless (-d "./.legit/commits") {	
		mkdir "./.legit/commits";
	}

	#determine the name/signature of the new commit directory and create it
	my $num_dirs = 0;
	foreach my $dir (glob "./.legit/commits/*") {
		$num_dirs++;
	}

	#check that the files in the index that are able to be commited have been changed
	my %dont_add;
	my $recent = $num_dirs-1;
	#print "recent directory is $recent\n";
	foreach my $recent_commit (glob "./.legit/commits/commit.$recent/*") {
		foreach my $index_file (glob "./.legit/index/*") {
			my @coms = split '/', $recent_commit;
			my $com_file = $coms[$#coms];
			my @inds = split '/', $index_file;
			my $ind = $inds[$#inds];
			#check the files are different
			if ($ind eq $com_file) {
				open my $F, '<', $recent_commit;
				open my $INDEX, '<', $index_file;
				my @com_lines;
				my @index_lines;
				#load file lines into arrays
				foreach my $com_line (<$F>){
					#print "com_line is $com_line\n";
					push @com_lines, $com_line;
				}
				foreach  my $ind_line (<$INDEX>) {
					#print "ind_line is $ind_line\n";
					push @index_lines, $ind_line;
				}
				my $diff = 0;
				#same length, check that the files have been edited
				if (@index_lines != @com_lines) {
					$diff = 1;

				} else {
					foreach my $i (0..$#index_lines) {
						if ($index_lines[$i] ne $com_lines[$i]) {
							#print "the diff lines are $index_lines[$i]\n";
							$diff = 1;
							last;
						}
					}
				}
				close $F;	
				close $INDEX;
				#add the index path name the dont_add hash
				if ($diff == 0) {
					#print "$index_file\n";
					$dont_add{$index_file}++;
				}
			}
		}
	}
	#if the dont_add hash is not the same length as the index array then add all the files in the index
	my $size_hash = keys %dont_add;
	if ($size_hash != $num_index_files) {
	#add all the index files
		my $new_commit = "commit".".$num_dirs";
		mkdir "./.legit/commits/$new_commit";

		foreach my $commit_file (glob "./.legit/index/*") {
			copy $commit_file, "./.legit/commits/$new_commit";
		}

		my $commit_message = "commit_message.txt";

		open my $F, '>', $commit_message or die "cannot write to $commit_message: $?\n";
		print $F "$message"."\n";
		move $commit_message, "./.legit/commits/$new_commit/";
		close $F;

		print "Committed as commit $num_dirs\n";
	} else {
	#nothing to commit
		print "nothing to commit\n";
	}

	#now move everything from index to this new directory.
	#my $commit_occurred = 0;
	#my $new_commit = "commit".".$num_dirs";
	#foreach my $commit_file (glob "./.legit/index/*") {
	#	if ($dont_add{$commit_file} && $dont_add{$commit_file} > 0) {
	#		next;
	#	} else {
	#		if ($commit_occurred == 0) {
	#			mkdir "./.legit/commits/$new_commit";
	#		}
	#		$commit_occurred = 1;
	#		copy $commit_file, "./.legit/commits/$new_commit";
	#	}
	#}

	#if ($commit_occurred == 1) {
		#print the message into its own file and place this file in the directory as a .txt file
		
	#} else {
		
	#}
}

#have an array that stores every commit's message in the corresponding commits message
#print these messages 
sub legit_log {
	#print all the commits and their messages

	my @logs;
	foreach my $commit (glob "./.legit/commits/commit.*/*") {
		#print "$commit\n";
	 	if ($commit =~ "./.legit/commits/commit.([0-9]+)/commit_message.txt") {
			open my $F, '<', $commit or die "can't open $commit: $?\n";
			foreach my $line (<$F>) {
				#print "$1 $line";
				push @logs, "$1 $line";
			}
			close $F;
		}
	}

	foreach my $element (reverse @logs) {
		print "$element";
	}
}

#go to the specified commit directory in the .legit directory and print the specified files in the subsequent dir.
sub show {
	my ($commit, $file) = @_;
	if ($commit eq "") {
	#go through the commits in the index and print the files contents
		#print "empty\n";
		if (-e "./.legit/index/$file") {
			open my $F, '<', "./.legit/index/$file" or die "can't open $file: $?\n";
			foreach my $line (<$F>) {
				print "$line";
			}
			close $F;
		} else {
			print "legit.pl: error: '$file' not found in index\n"

		}
	} elsif ($commit =~ /[0-9]+/){
	#go to the specified commit and print the specified commit
		#print "num\n";

		unless (-d "./.legit/commits/commit.$commit") {
			print "legit.pl: error: unknown commit '$commit'\n" and exit 0;
		}

		if (-e "./.legit/commits/commit.$commit/$file") {
			open my $F, '<', "./.legit/commits/commit.$commit/$file" or die "can't open $file: $?\n";
			foreach my $line (<$F>) {
				print "$line";
			}
			close $F;
		} else {
			print "legit.pl: error: '$file' not found in commit $commit\n"

		}

	} #else {
		#print "invalid input, Usage: show <digit/empty string>:<filename>\n" and exit 0;
	#}
}

#SUBSET 1 subroutines


#THINK ABOUT breaking into two subroutines for index or current  dir
sub legit_rm{
#PLAN:
#the paramenters are a list of the files to be removed, a variable to flag if force remove and a list of directories to remove from
#if force remove just remove the file from index 	
#otherwise have to go through the index 
	#TRY: array references to stop the array concatonating
	my ($f, $directories, $files) = @_;
	#print "printing directories\n";
	#print join "\n", @$directories;

	#print "\nprinting files\n@$files\n";
	#print $f."\n";
	if ($f eq 1) {
	#remove the files from the directories regardless of being committed
		foreach my $directory (@$directories) {
			#print "dir is $directory\n";
			if ($directory eq ".") {
			#remove the specified files from the current directory
				#print "remove from the current directory\n";
				foreach my $file (@$files) {
					#print "$file\n";
					unlink $file;

				}
			} else {
			#remove the specified files in the index
				foreach my $file (@$files) {
					#print "$file\n";
					unlink "./.legit/index/$file";
				}
			}			
		}
	} else {
	#remove the files if it is safe
		foreach my $directory (@$directories) {
			#print "dir is $directory\n";
			if ($directory eq ".") {
			#remove the specified files from the current directory if the file exists in the last commit
				#go through the commits and find the last commit
				my $num_coms = 0;
				foreach my $commit (glob "./.legit/commits/commit.*") {
					$num_coms++;
				}
				$num_coms--;
				if ($num_coms >= 0) {
					#check if the file exists in the commit
					foreach my $file (@$files) {
						foreach my $com (glob "./.legit/commits/commit.*/*") {
							my @commit_paths = split '/', $com;
							my $com_file = $commit_paths[$#commit_paths];
							#print "$com_file\n";
							if ($com_file eq $file) {

								unlink $file;
								last;
							}
						}
					}

				}
			} else {
			#remove the specified files in the index if the file exists in the last commit
				my $num_coms = 0;
				foreach my $commit (glob "./.legit/commits/commit.*") {
					$num_coms++;
				}
				$num_coms--;
				if ($num_coms >= 0) {
					#check if the file exists in the commit
					foreach my $file (@$files) {
						foreach my $com (glob "./.legit/commits/commit.*/*") {
							my @commit_paths = split '/', $com;
							my $com_file = $commit_paths[$#commit_paths];
							#print "$com_file\n";
							if ($com_file eq $file) {
								unlink "./.legit/index/$file";
								last;
							}
						}
					}

				}
			}			
		}
	}
}


