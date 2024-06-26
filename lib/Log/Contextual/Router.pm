package Log::Contextual::Router;
use strict;
use warnings;

our $VERSION = '0.009002';

use Scalar::Util 'blessed';

use Moo;

with 'Log::Contextual::Role::Router',
  'Log::Contextual::Role::Router::SetLogger',
  'Log::Contextual::Role::Router::WithLogger',
  'Log::Contextual::Role::Router::HasLogger';

eval { ## no critic (ErrorHandling::RequireCheckingReturnValueOfEval)
  require Log::Log4perl;
  die if $Log::Log4perl::VERSION < 1.29;
  Log::Log4perl->wrapper_register(__PACKAGE__)
};

has _default_logger => (
  is       => 'ro',
  default  => sub { {} },
  init_arg => undef,
);

has _package_logger => (
  is       => 'ro',
  default  => sub { {} },
  init_arg => undef,
);

has _get_logger => (
  is       => 'ro',
  default  => sub { {} },
  init_arg => undef,
);

sub before_import { }

sub after_import {
  my ($self, %import_info) = @_;
  my $exporter = $import_info{exporter};
  my $target   = $import_info{target};
  my $config   = $import_info{arguments};

  if (my $l = $exporter->arg_logger($config->{logger}, $target)) {
    $self->set_logger($l);
  }

  if (my $l = $exporter->arg_package_logger($config->{package_logger}, $target)) {
    $self->_set_package_logger_for($target, $l);
  }

  if (my $l = $exporter->arg_default_logger($config->{default_logger}, $target)) {
    $self->_set_default_logger_for($target, $l);
  }
}

sub with_logger {
  my $logger = $_[1];
  if (ref $logger ne 'CODE') {
    die 'logger was not a CodeRef or a logger object.  Please try again.'
      unless blessed($logger);
    $logger = do {
      my $l = $logger;
      sub { $l }
    };
  }
  local $_[0]->_get_logger->{l} = $logger;
  $_[2]->();
}

sub set_logger {
  my $logger = $_[1];
  if (ref $logger ne 'CODE') {
    die 'logger was not a CodeRef or a logger object.  Please try again.'
      unless blessed($logger);
    $logger = do {
      my $l = $logger;
      sub { $l }
    };
  }

  warn 'set_logger (or -logger) called more than once!  This is a bad idea!'
    if $_[0]->_get_logger->{l};
  $_[0]->_get_logger->{l} = $logger;
}

sub has_logger { !!$_[0]->_get_logger->{l} }

sub _set_default_logger_for {
  my $logger = $_[2];
  if (ref $logger ne 'CODE') {
    die 'logger was not a CodeRef or a logger object.  Please try again.'
      unless blessed($logger);
    $logger = do {
      my $l = $logger;
      sub { $l }
    };
  }
  $_[0]->_default_logger->{$_[1]} = $logger
}

sub _set_package_logger_for {
  my $logger = $_[2];
  if (ref $logger ne 'CODE') {
    die 'logger was not a CodeRef or a logger object.  Please try again.'
      unless blessed($logger);
    $logger = do {
      my $l = $logger;
      sub { $l }
    };
  }
  $_[0]->_package_logger->{$_[1]} = $logger
}

sub _get_loggers {
  my ($self, %info) = @_;
  my $package   = $info{caller_package};
  my $log_level = $info{message_level};
  my $logger =
       $_[0]->_package_logger->{$package}
    || $_[0]->_get_logger->{l}
    || $_[0]->_default_logger->{$package}
    || die
    q( no logger set!  you can't try to log something without a logger! );

  $info{caller_level}++;
  $logger = $logger->($package, \%info);

  return $logger if $logger->${\"is_${log_level}"};
  return ();
}

sub handle_log_request {
  my ($self, %message_info) = @_;
  my $generator = $message_info{message_sub};
  my $text      = $message_info{message_text};
  my $args      = $message_info{message_args};
  my $log_level = $message_info{message_level};

  $message_info{caller_level}++;

  my @loggers = $self->_get_loggers(%message_info)
    or return;

  my @log = defined $text ? ($text) : ($generator->(@$args));
  $_->$log_level(@log) for @loggers;
}

1;

__END__

=head1 NAME

Log::Contextual::Router - Route messages to loggers

=head1 VERSION

version

=head1 DESCRIPTION

This is the default log router used by L<Log::Contextual>. It fulfills the roles
L<Log::Contextual::Role::Router>,
L<Log::Contextual::Role::Router::WithLogger>,
L<Log::Contextual::Role::Router::HasLogger>, and
L<Log::Contextual::Role::Router::SetLogger>.

=cut
