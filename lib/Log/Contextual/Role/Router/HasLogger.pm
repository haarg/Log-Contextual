package Log::Contextual::Role::Router::HasLogger;
use strict;
use warnings;

# ABSTRACT: Abstract interface between loggers and logging code blocks

use Moo::Role;

requires 'has_logger';

1;

