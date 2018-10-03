#!/usr/bin/perl

#created by z5113609
#COMP2041: Software Construction, semester 2, 2018
#program called legit.pl which is a subset of the git version control system

use strict;
use warnings;
use File::Copy;

if ($ARGV[0] eq "init") {
	init();

} elsif ($ARGV[0] eq "add") {
	my @files = @ARGV[1..$#ARGV];

	add(@files);

 
} elsif ($ARGV[0] eq "commit") {
	unless (-e ".legit") {
		print "legit.pl: error: no .legit directory containing legit repository exists\n" and exit 1;
	}
	if (@ARGV <= 1) {
		print "usage: legit.pl commit [-a] -m commit-message\n" and exit 1;
	}
	if ($ARGV[1] =~ /[^(\-a)(\-m)]/) {
		print "usage: legit.pl commit [-a] -m commit-message\n" and exit 1;
	} if ($ARGV[1] eq "-m") {
		if (@ARGV != 3) {
			print "usage: legit.pl commit [-a] -m commit-message\n" and exit 1;
		}
		my $message = $ARGV[2];

		commit($message);
	} elsif ($ARGV[1] eq "-a") {
		#cause all the files already in the index to have the most recent versions of the files in cur dir added
		if (@ARGV != 4) {
			print "usage: legit.pl commit [-a] -m commit-message\n" and exit 1;
		}
		unless ($ARGV[2] eq "-m") {
			print "usage: legit.pl commit [-a] -m commit-message\n" and exit 1;
		}
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
	} else {
		print "usage: legit.pl commit [-a] -m commit-message\n" and exit 1;

	} 
} elsif ($ARGV[0] eq "log") {
	#error checking
	unless (-e ".legit") {
		print "legit.pl: error: no .legit directory containing legit repository exists\n" and exit 1;
	}
	unless (-e ".legit/commits") {
		print "legit.pl: error: your repository does not have any commits yet\n" and exit 1;
	}
	legit_log();

} elsif ($ARGV[0] eq "show") {
	#error checking: no commits made yet
	unless (-e ".legit") {
		print "legit.pl: error: no .legit directory containing legit repository exists\n" and exit 1;
	}
	unless (-e ".legit/commits") {
		print "legit.pl: error: your repository does not have any commits yet\n" and exit 1;
	}
	#error checking: incorrect input
	if (@ARGV == 1) {
		print "usage: legit.pl show <commit>:<filename>\n" and exit 1;
	}
	if ($ARGV[1] !~ /.*:.*/) {
		print "legit.pl: error: invalid object $ARGV[1]\n" and exit 1;
	}
	my $parameters = $ARGV[1];
	my @params = split ':', $parameters;

	show($params[0], $params[1]);

} elsif ($ARGV[0] eq "rm") {
	#error checking
	unless (-e ".legit") {
		print "legit.pl: error: no .legit directory containing legit repository exists\n" and exit 1;
	}
	unless (-e ".legit/commits") {
		print "legit.pl: error: your repository does not have any commits yet\n" and exit 1;
	}

	if (@ARGV > 3) {
		if ($ARGV[1] eq "--cached" && $ARGV[2] eq "--force") {
		#cached and forced simultaneously
			my @directories = ("./.legit/index");
			my @files = @ARGV[3..$#ARGV];
			my $f = 1;
			legit_rm($f, \@directories, \@files);
			exit 1;
		} elsif ($ARGV[1] eq "--force" && $ARGV[2] eq "--cached") {
			my @directories = ("./.legit/index");
			my @files = @ARGV[3..$#ARGV];
			my $f = 1;
			legit_rm($f, \@directories, \@files);
			exit 1;
		}
	} 
	if ($ARGV[1] eq "--cached") {
	#remove the files from the index only
		my @directories = ("./.legit/index");
		my @files = @ARGV[2..$#ARGV];
		my $f = 0;
		legit_rm($f, \@directories, \@files);
	} elsif ($ARGV[1] eq "--force") {
	#ignore all error checking
		#directories, files, force
		my @directories = (".", "./.legit/index");
		my @files = @ARGV[2..$#ARGV];
		my $f = 1;
		#array references are required for multiple array beig passed into to the array
		legit_rm($f, \@directories, \@files);
	} elsif ($ARGV[1] =~ /\-/) {
		print "usage: legit.pl rm [--force] [--cached] <filenames>\n" and exit 1;
	} else {
	#remove files with caution
		my @directories = (".", "./.legit/index");
		my @files = @ARGV[1..$#ARGV];
		my $f = 0;
		legit_rm($f, \@directories, \@files);
	}
}

#SUBSET 0 subroutines:

#A function to initialise the .legit repository if required
sub init {
	my $legit = ".legit";
	my $index = "index";
	#the directory already exists print an error message and exit with error status
	if (-d "$legit") {
		print "legit.pl: error: .legit already exists\n";
	} else {
	#create the directory
		mkdir "$legit";
		print "Initialized empty legit repository in .legit\n";
		#in addition, create subdirectory in .legit for add called .index
		mkdir "./.legit/index";
	}
}

#assume only files are input. Don't worry about directories
sub add {

	my (@add_files) = @_;
	#if the .legit directory hasn't been created then print an error
	unless (-d ".legit") {
		print "legit.pl: error: no .legit directory containing legit repository exists\n";
	}

	while (my $element = shift @add_files) {
		unless (-e "$element") {
			#add removed files
			if (-e ".legit/index/$element") {	
				#remove the file from the index
				unlink "./.legit/index/$element";
				next;
			} else {
				#file doesn't exist
				print "legit.pl: error: can not open '$element'\n";
				next;
			}
		} 		
		#copy the file into the index
		copy $element, "./.legit/index";
	}
}

#commit adds the files in the index to the repository

#if a file in index has been changed then commit all the files in the index
#if none of the files have been changed print nothing to commit
#if the number of files in the index is different to the number of files in the prev commit, commit
sub commit {
	my ($message) = @_;

	my $num_index_files = 0;
	foreach my $add_file (glob "./.legit/index/*") {
		$num_index_files++;
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
	my $recent = $num_dirs-1;

	#if the number of files on the index and prev com dir are different then commit
	if (-e ".legit/commits/commit.$recent") {
		my $num_com_files = 0;
		foreach my $c (glob "./.legit/commits/commit.$recent/*") {
			#print "$c\n";
			$num_com_files++;
		}
		#because of the extra commit message, decrement
		$num_com_files--;
		if ($num_com_files != $num_index_files) {
		#commit since there are new files in the directory
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

			#check that the files in the index that are able to be commited have been changed
			my %dont_add;
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
							push @com_lines, $com_line;
						}
						foreach  my $ind_line (<$INDEX>) {
							push @index_lines, $ind_line;
						}
						my $diff = 0;
						#same length, check that the files have been edited
						if (@index_lines != @com_lines) {
							$diff = 1;
		
						} else {
							foreach my $i (0..$#index_lines) {
								if ($index_lines[$i] ne $com_lines[$i]) {
									$diff = 1;
									last;
								}
							}
						}
						close $F;	
						close $INDEX;
						#add the index path name to the dont_add hash
						if ($diff == 0) {
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
		}
	} else {
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

	}
}

sub legit_log {
#print all the commits and their messages

	my @logs;
	foreach my $commit (glob "./.legit/commits/commit.*/*") {
	 	if ($commit =~ "./.legit/commits/commit.([0-9]+)/commit_message.txt") {
			open my $F, '<', $commit or die "can't open $commit: $?\n";
			foreach my $line (<$F>) {
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
	#go to the specified commit and print
		unless (-d "./.legit/commits/commit.$commit") {
			print "legit.pl: error: unknown commit '$commit'\n" and exit 1;
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

	} elsif ($commit =~ /[^0-9]/) {
		print "legit.pl: error: unknown commit '$commit'\n" and exit 1;
	}
}

#SUBSET 1 subroutines

sub legit_rm{
	my ($f, $directories, $files) = @_;

	if ($f eq 1) {
	#remove the files from the directories regardless of being committed
		foreach my $directory (@$directories) {
			if ($directory eq ".") {
			#remove the specified files from the current directory
				foreach my $file (@$files) {
					unless (-e ".legit/index/$file") {
						print "legit.pl: error: '$file' is not in the legit repository\n" and exit 1;
					}
					unlink $file;

				}
			} else {
			#remove the specified files in the index
				foreach my $file (@$files) {
					unless (-e ".legit/index/$file") {
						print "legit.pl: error: '$file' is not in the legit repository\n" and exit 1;
					}
					unlink "./.legit/index/$file";
				}
			}			
		}
	} else {
	#remove the files if it is safe
		foreach my $directory (@$directories) {
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
						unless (-e ".legit/index/$file") {
							print "legit.pl: error: '$file' is not in the legit repository\n" and exit 1;
						}

						my $in_commit = 0;
						my $curr_diff = 0;
						my $diff_index = 0;
						foreach my $com (glob "./.legit/commits/commit.$num_coms/*") {
							my @commit_paths = split '/', $com;
							my $com_file = $commit_paths[$#commit_paths];

							open my $F, '<', $file or die "can't open $file\n";
							open my $COM, '<', "./.legit/commits/commit.$num_coms/$com_file" or die "can't open $com_file\n";
							open my $IND, '<', "./.legit/index/$file" or die "can't open index $file\n";
							my @cur;
							my @commit;
							my @indx;
							#see if the current file is different to the committed file
							foreach my $line (<$F>) {
								push @cur, $line;
							}
							foreach my $lin_e (<$COM>) {
								push @commit, $lin_e;
							}
							foreach my $li_ne (<$IND>) {
								push @indx, $li_ne;
							}
								
							if (@cur != @commit) {
								$curr_diff = 1;
							} else {
								foreach my $i (0 .. $#cur) {
									if ($cur[$i] ne $commit[$i]) {
										$curr_diff = 1;
									}
								}
							}

							if (@indx == @commit) {
								foreach my $j (0 .. $#indx) {
									if ($commit[$j] ne $indx[$j]) {
										$in_commit = 1;
									}
								}
							} else {
								$in_commit = 1;
							}
								
							if (@indx != @cur) {
								$diff_index = 1;
							} else {
								foreach my $k (0 ..$#indx) {
									if ($cur[$k] ne $indx[$k]) {
										$diff_index = 1;
									}
								}
							}
							
							close $F;
							close $COM;
							close $IND;	
																						
							last;
						}
						#if commit and index are different
						#curr_diff is curr and commit
						#diff index is curr and index
						if ($diff_index == 1  && $curr_diff == 1  && $in_commit == 0 ) {
							#index and commit are the same and diff to curr
							#commit and index same but cur diff
							print "legit.pl: error: '$file' in repository is different to working file\n" and exit 1;						 
						#in_commit is commit and index
						#curr_diff is curr and commit
						#diff_index is curr and index
						} elsif ($in_commit == 1 && $curr_diff == 1 && $diff_index == 0) {
							#index and curr same but commit diff
							print "legit.pl: error: '$file' has changes staged in the index\n" and exit 1;
						} elsif ($in_commit == 1 && $curr_diff == 1 && $diff_index == 1) {
							#all three repos are diff

						} else {
							unlink $file;
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
						unless (-e ".legit/index/$file") {
							print "legit.pl: error: '$file' is not in the legit repository\n" and exit 1;
						}
						my $in_commit = 0;
						my $curr_diff = 0;
						my $diff_index = 0;
						foreach my $com (glob "./.legit/commits/commit.*/*") {
							my @commit_paths = split '/', $com;
							my $com_file = $commit_paths[$#commit_paths];
							if ($com_file eq $file) {
								open my $F, '<', $file or die "can't open cache $file\n";
								open my $COM, '<', "./.legit/commits/commit.$num_coms/$com_file" or die "can't open $com_file\n";
								open my $IND, '<', "./.legit/index/$file" or die "can't open index $file\n";
								my @cur;
								my @commit;
								my @indx;
								#see if the current file is different to the committed file
								foreach my $line (<$F>) {
									push @cur, $line;
								}
								foreach my $lin_e (<$COM>) {
									push @commit, $lin_e;
								}
								foreach my $li_ne (<$IND>) {
									push @indx, $li_ne;
								}
								
								
								if (@cur != @commit) {
									$curr_diff = 1;
								} else {
									foreach my $i (0 .. $#cur) {					
										if ($cur[$i] ne $commit[$i]) {
											$curr_diff = 1;
										}
									}
								}
								if (@indx == @commit) {
									foreach my $j (0 .. $#indx) {
										if ($commit[$j] ne $indx[$j]) {
											$in_commit = 1;
										}
									}
								} else {
									$in_commit = 1;
								}
								if (@indx != @cur) {
									$diff_index = 1;
								} else {
									foreach my $k (0 ..$#indx) {
										if ($cur[$k] ne $indx[$k]) {
											$diff_index = 1;
										}
									}
								}
							
								close $F;
								close $COM;
								close $IND;	
											
								last;
							}
						}
						#outside loop now

						if ($in_commit == 1 && $curr_diff == 1 && $diff_index == 1) {
							#all three repos are diff
							print "legit.pl: error: '$file' in index is different to both working file and repository\n" and exit 1;

						} 
							unlink "./.legit/index/$file";
					}
				}
			}			
		}
	}
}


