use strict;
use warnings;
use Getopt::Long qw (GetOptions);
use Pod::Usage qw (pod2usage);
use v5.10;
use lib 'c:/users/admin/workspace/perl';
use umods::GUtils qw(prompt_yn);
#NB need to have GUtils.pm in sub-directory umods of lib
my $man = 0;
my $help = 0;
my $helpHeader = 'Arguments required, see below\n';
my $nargs=@ARGV;
my $vfile='version.txt';
my $number='revision';
my $major=0;
my $minor=0;
my $revision=1;
my $create='';
my $set='';
my $reset='';
my $get='';
my $dec='';
my $inc='';
my $dry='';
my $runWithNoArgsAllowed=1;

if (!$nargs && !$runWithNoArgsAllowed){
    pod2usage(2);#exit error 2 after printing SYNOPSIS, verbose 0
}

## Parse options and print usage if there is a syntax error,
## or if usage was explicitly requested.
GetOptions('help|?' => \$help, man => \$man, 'create'=>\$create, 'set=i'=>\$set, 'reset'=>\$reset, 
    'get'=>\$get,'dec'=>\$dec,'inc'=>\$inc,'dry'=>\$dry,'number=s'=>\$number, 'file=s' => \$vfile) or pod2usage(2);
pod2usage(1) if $help;#exit error 1 after printing SYNOPSIS and OPTIONS, verbose 1;
pod2usage(-verbose => 2) if $man;#exit error 1 after printing man, verbose 2

#pod3usage verbosity 0 -> SYNOPSIS
#pod3usage verbosity 1 -> SYNOPSIS and OPTIONS, ARGUMENTS, or OPTIONS AND
#ARGUMENTS 
#pod3usage verbosity 2 -> all sections
#see pod2usage, perlpod, and perlpodstyle
#print ("Running with $nargs arguments\n");

sub writeVF{
    open my $vfh, '>', $vfile, or die "Cannot open $vfile for writing : $! \n";
    print $vfh "$major\n$minor\n$revision";
    close $vfh;
}

sub readVF{
    open my $vfh, '<', $vfile, or die "Cannot open $vfile for reading : $! \n";
    chomp(my @lines =<$vfh>);
    $major=$lines[0];
    $minor=$lines[1];
    $revision=$lines[2];
    close $vfh;
}

if($create){
    say "warning, overwriting file $vfile";
    if(!prompt_yn("proceed?")){
	say "aborting, bye...";
	exit 0;
    }
    writeVF;
    say "$vfile created";
    exit 0;
}

if($reset){
    writeVF;
    say "$vfile reset, major = $major, minor=$minor, revision = $revision";
    exit 0;
}

if($set){
    readVF;
    $revision=$set if($number eq 'revision' && $set ne '');
    $minor=$set if($number eq 'minor' && $set ne '');
    $major=$set if($number eq 'major' && $set ne '');
    writeVF;
    say "major = $major, minor=$minor, revision = $revision set in $vfile";
    exit 0;
}

if($get){
    readVF;
    say "$major.$minor.$revision";
    exit 0;
}

if($dec){
    readVF;
    $revision-- if($number eq 'revision');
    $minor-- if($number eq 'minor');
    $major-- if($number eq 'major');
    if(!$dry){
	writeVF;
    }
    say "$major.$minor.$revision";
    exit 0;
}

if($inc){
    readVF;
    $revision++ if($number eq 'revision');
    $minor++ if($number eq 'minor');
    $major++ if($number eq 'major');
    if(!$dry){
	writeVF;
    }
    say "$major.$minor.$revision";
    exit 0;
}

#default action
readVF;
$revision++ if($number eq 'revision');
$minor++ if($number eq 'minor');
$major++ if($number eq 'major');
writeVF;
say "major = $major, minor=$minor, revision = $revision set in $vfile";
exit 0;

__END__

=pod

=head1 NAME

bump.pl - automatically set or bump version numbers in version file. Example usage in conjunction with make to provide a version number into your program.

=head1 SYNOPSIS

 Options:
   -help            brief help message
   -man             full documentation
   -file            version file, default version.txt
   -number          revision number to bump, default revision (valid values revision, minor, or major)
   -set             set instead of bump, default bump
   -reset           reset to 0.0.1
   -create          create file with 0.0.1
   -get             gets version number, major.minor.revision
   -inc             gets version number, major.minor.revision after increment, 
   -dec             gets version number, major.minor.revision after decrement
   -dry             dry run, no change to file

 #the dry run looks at version number that would be produced by an inc or dec operation

 Examples:
   
   perl bump.pl -h                                   -- prints help
   perl bump.pl -m                                   -- prints all pod
   perl bump.pl -create                              -- creates version.txt 0.0.1
   perl bump.pl -create -f myversion.txt             -- creates myversion.txt 0.0.1
   perl bump.pl                                      -- bumps the revision number in version.txt
   perl bump.pl -f ..\thisVersionFile.txt            -- bumps the revision number in ..\thisVersionFile.txt
   perl bump.pl -number major                        -- bumps major in version.txt
   perl bump.pl -n minor                             -- bumps minor in version.txt
   perl bump.pl -s 12                                -- sets revision in version.txt
   perl bump.pl -s 2 -n major -file myversion.txt    -- sets major in myversion.txt
   perl bump.pl -get                                 -- gets version from version.txt
   perl bump.pl -dec -n major                        -- decrements major version in version.txt
   perl bump.pl -de -n minor -dr                     -- dry run look at version number if minor decremented                         

=over 4

=item B<-help>

Use to programmatically maintain major.minor.revision number in file e.g. call from make file

=item B<-man>

Prints the manual page and exits.

=back

=head1 DESCRIPTION

Program to bump a version number in file. By default looks in current directory for version.txt and increments the revision in the major.minor.revision scheme. Options to select the file to bump and/or to select the major.minor.revision number, set, reset, increment, decrement, inspect, reset, and dry-run.

Example usage in a makefile to allow build version numbering of C++ program:
       
    objects:= pov1.obj
    ouf:= pov1
    versionFile:= povVersion.txt
    VERSION:=$(shell perl ../../../perl/uscripts/bump.pl -inc -dry -f $(versionFile)) 
    #versionFile is not updated until link actually completes
 
    CXX:= cl 
    CXXFLAGS:= -c -EHsc -std:c++17 -D$(addprefix VER=,\"$(VERSION)\")

    target:=$(addsuffix .exe, $(ouf))

    %.obj : %.cpp
	    $(CXX) $(CXXFLAGS) $< -Fo$@
	 
    $(target) : $(objects)
	    $(LINKER) $(LDFLAGS) $(objects) /OUT:$(target)
	    perl ../../../perl/uscripts/bump.pl -inc -f $(versionFile)
    #versionFile is updated here, when the linker completes

In C++ file pov1.cpp which is being built:

    #ifdef VER
    std::string version{VER};
    #else
    std::string version{"version not set"};
    #endif

which allows access in the program to the version number.

At start of development create your version file:

    bump.pl -create

version.txt now contains version 0.0.1 and with each build the revision number is incremented. When you are ready increment the minor or major version number e.g.

    bump.pl -n minor

If you want you can also reset the revision number e.g.

    bump.pl -n minor #increment minor
    bump.pl -s 1     #revision number set back to 1

Thanks to dash-o stackoverflow user for showing how to set-up the makefile.

"L<https://stackoverflow.com/questions/65552564/make-action-if-up-to-date>"

NB use of umods::GUtils for prompting. The functions prompt and prompt_yn from 

"L<https://stackoverflow.com/questions/18103501/prompting-multiple-questions-to-user-yes-no-file-name-input>"

are required, see line #NB above and file GUtils.pm for further information. Or drop the use of prompt_yn in function create above.

Thanks to amon stackoverflow user for the prompt functions.

=head1 AUTHOR

Steven Glautier

=head1 COPYRIGHT

Copyright (C) 2020-21 Steven Glautier <spgxyz@gmail.com> 

This work is licensed for non-commercial use as follows:

Attribution-NonCommercial-ShareAlike 4.0 International.

=cut


