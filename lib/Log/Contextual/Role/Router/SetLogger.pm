package Log::Contextual::Role::Router::SetLogger;
use strict;
use warnings;

# ABSTRACT: Abstract interface between loggers and logging code blocks

use Moo::Role;

requires 'set_logger';

1;

