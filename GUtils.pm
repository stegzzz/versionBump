package umods::GUtils;
#see https://perlmaven.com/how-to-create-a-perl-module-for-code-reuse
use strict;
use warnings;
use Exporter qw(import);
our @EXPORT_OK = qw(add prompt_yn);

##Start prompt
#https://stackoverflow.com/questions/18103501/prompting-multiple-questions-to-user-yes-no-file-name-input
sub prompt {
  my ($query) = @_; # take a prompt string as argument
  local $| = 1; # activate autoflush to immediately show the prompt
  print $query;
  chomp(my $answer = <STDIN>);
  return $answer;
}

#start prompt_yn
sub prompt_yn {
  my ($query) = @_;
  my $answer = prompt("$query (Y/N): ");
  return lc($answer) eq 'y';
}
#end prompt_yn
#
##End prompt

1;
