package Log::Contextual::Easy::Default;
use strict;
use warnings;

our $VERSION = '0.008002';

use Log::Contextual ();
BEGIN { our @ISA = qw(Log::Contextual) }

sub arg_default_logger {
   if ($_[1]) {
      return $_[1];
   } else {
      require Log::Contextual::WarnLogger;
      my $package = uc $_[2];
      $package =~ s/::/_/g;
      return Log::Contextual::WarnLogger->new({env_prefix => $package});
   }
}

sub default_import { qw(:dlog :log ) }

1;

__END__

=head1 NAME

Log::Contextual::Easy::Default - Import all logging methods with WarnLogger as default

=head1 VERSION

version 0.008002

=head1 SYNOPSIS

In your module:

 package My::Module;
 use Log::Contextual::Easy::Default;

 log_debug { "your message" };
 Dlog_trace { $_ } @vars;

In your program:

 use My::Module;

 # enable warnings
 $ENV{MY_MODULE_UPTO}="TRACE";

 # or use a specific logger with set_logger / with_logger

=head1 DESCRIPTION

By default, this module enables a L<Log::Contextual::WarnLogger>
with C<env_prefix> based on the module's name that uses
Log::Contextual::Easy. The logging levels are set to C<trace> C<debug>,
C<info>, C<warn>, C<error>, and C<fatal> (in this order) and all
logging functions (L<< C<log_...>|Log::Contextual/"log_$level" >>,
L<< C<logS_...>|Log::Contextual/"logS_$level" >>,
L<< C<Dlog_...>|Log::Contextual/"Dlog_$level" >>, and
L<< C<Dlog...>|Log::Contextual/"DlogS_$level" >>) are exported.

For what C<::Default> implies, see L<Log::Contextual/-default_logger>.

=head1 SEE ALSO

=over 4

=item L<Log::Contextual::Easy::Package>

=back
