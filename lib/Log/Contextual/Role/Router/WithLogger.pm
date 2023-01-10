package Log::Contextual::Role::Router::WithLogger;
use strict;
use warnings;

# ABSTRACT: Abstract interface between loggers and logging code blocks

use Moo::Role;

requires 'with_logger';

1;

