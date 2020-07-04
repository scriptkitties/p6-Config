#! /usr/bin/env false

use v6.d;

unit class Config::Parser;

#| Attempt to read the file at a given $path, and returns its
#| parsed contents as a Hash.
method read(IO() $path --> Hash) { … }

#| Attempt to write the $config Hash at a given $path. Returns
#| True on success, False on failure.
method write(IO() $path, Hash $config --> Bool) { … }
