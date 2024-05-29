package Log::Contextual::TeeLogger;
use strict;
use warnings;

our $VERSION = '0.009002';

{
  for my $name (qw( trace debug info warn error fatal )) {

    no strict 'refs';

    *{$name} = sub {
      my $self = shift;

      foreach my $logger (@{$self->{loggers}}) {
        $logger->$name(@_);
      }
    };

    my $is_name = "is_${name}";

    *{$is_name} = sub {
      my $self = shift;
      foreach my $logger (@{$self->{loggers}}) {
        return 1 if $logger->$is_name(@_);
      }
      return 0;
    };
  }
}

sub new {
  my ($class, $args) = @_;
  my $self = bless {}, $class;

  ref($self->{loggers} = $args->{loggers}) eq 'ARRAY'
    or die "No loggers passed to tee logger";

  return $self;
}

1;

__END__

=head1 NAME

Log::Contextual::TeeLogger - Output to more than one logger

=head1 VERSION

version

=head1 SYNOPSIS

  use Log::Contextual::SimpleLogger;
  use Log::Contextual::TeeLogger;
  use Log::Contextual qw( :log ),
    -logger => Log::Contextual::TeeLogger->new({ loggers => [
      Log::Contextual::SimpleLogger->new({ levels => [ 'debug' ] }),
      Log::Contextual::SimpleLogger->new({
        levels => [ 'info' ],
        coderef => sub { print @_ },
      }),
    ]});

  ## docs below here not yet edited

  log_info { 'program started' }; # no-op because info is not in levels
  sub foo {
    log_debug { 'entered foo' };
    ...
  }

=head1 DESCRIPTION

This module is a simple logger made mostly for demonstration and initial
experimentation with L<Log::Contextual>.  We recommend you use a real logger
instead.  For something more serious but not overly complicated, take a look at
L<Log::Dispatchouli>.

=head1 METHODS

=head2 new

Arguments: C<< Dict[ levels => ArrayRef[Str], coderef => Optional[CodeRef] ] $conf >>

  my $l = Log::Contextual::SimpleLogger->new({
    levels => [qw( info warn )],
    coderef => sub { print @_ }, # the default prints to STDERR
  });

Creates a new SimpleLogger object with the passed levels enabled and optionally
a C<CodeRef> may be passed to modify how the logs are output/stored.

Levels may contain:

  trace
  debug
  info
  warn
  error
  fatal

=head2 $level

Arguments: C<@anything>

All of the following six methods work the same.  The basic pattern is:

  sub $level {
    my $self = shift;

    print STDERR "[$level] " . join qq{\n}, @_;
        if $self->is_$level;
  }

=head3 trace

  $l->trace( 'entered method foo with args ' join q{,}, @args );

=head3 debug

  $l->debug( 'entered method foo' );

=head3 info

  $l->info( 'started process foo' );

=head3 warn

  $l->warn( 'possible misconfiguration at line 10' );

=head3 error

  $l->error( 'non-numeric user input!' );

=head3 fatal

  $l->fatal( '1 is never equal to 0!' );

B<Note:> C<fatal> does not call C<die> for you, see L<Log::Contextual/EXCEPTIONS AND ERROR HANDLING>

=head2 is_$level

All of the following six functions just return true if their respective
level is enabled.

=head3 is_trace

  say 'tracing' if $l->is_trace;

=head3 is_debug

  say 'debuging' if $l->is_debug;

=head3 is_info

  say q{info'ing} if $l->is_info;

=head3 is_warn

  say 'warning' if $l->is_warn;

=head3 is_error

  say 'erroring' if $l->is_error;

=head3 is_fatal

  say q{fatal'ing} if $l->is_fatal;

=cut

