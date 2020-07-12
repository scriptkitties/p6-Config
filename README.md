# Config

Extensible configuration class for the Raku programming language.

## Installation

This module can be installed using `zef`:

```
zef install Config
```

Depending on the type of configuration file you want to work on, you will need a
`Config::Parser::` module as well. If you just want an easy-to-use configuration
object without reading/writing a file, no parser is needed.

## Usage

To start off, specify a *template* of your configuration. `Config` will check
a couple of directories for a configuration file (based on the XDG base
directory spec), and will also automatically try to see if there's any
configuration specified in environment variables.

To specify a template, pass it as an argument to `new`.

```raku
my $config = Config.new({
	keyOne => Str,
	keyTwo => {
		NestedKey => "default value",
	},
	keyThree => Int,
}, :name<foobar>);
```

Important to note here is the `name` attribute which is being set. This name
is used to look up configuration files in default locations and the
environment. For this particular example, it will check any directory specified
in `$XDG_CONFIG_DIRS` for files matching `foobar.*` and `foobar/config.*`.
Afterwards, it will check `$XDG_CONFIG_HOME` for the same files. If these
variables are not set, it will just check `$HOME/.config` for those files.

Additionally, the environment will be checked for `$FOOBAR_KEYONE`,
`$FOOBAR_KEYTWO_NESTEDKEY`, and `$FOOBAR_KEYTHREE`. The former two will be cast
to `Str` appropriately, with `$FOOBAR_KEYTHREE` being cast to an `Int`. This
ensures that the values are of the correct type, even if they're pulled from a
shell environment. This also works for `IO::Path`!

*If you're using the Raku `Log` module, you can set `RAKU_LOG_LEVEL` to `7` to
see which places it actually checks and reads for values.*

You can also manually read configuration files or hashes of values.

```raku
# Load a simple configuration hash
$config.=read({
    keyOne => 'value',
    keyTwo => {
        NestedKey => 'other value'
    }
});

# Load a configuration files
$config.=read('/etc/config.yaml');

# Load a configuration file with a specific parser
$config.=read('/etc/config', Config::Parser::ini);
```

Do note the use of `.=` here. `Config` returns a new `Config` object if you
change its values, it is an immutable object. The `.=` operator provided by
Raku is a shorthand for `$config = $config.read(...)`.

To read values from the `Config` object, you can use the `get` method, or treat
it as a `Hash`.

```raku
# Retrieve a value
$config.get('keyOne');

# Same as above, but treating it as a Hash
$config<keyOne>;

# Retrieve a value by nested key
$config.get('keyTwo.NestedKey');
```

The `Config` object can also write it's current configuration back to a file.
You must specify a particular `Config::Parser` implementation as well.

```raku
# Write out the configuration using the json parser
$config.write($*HOME.add('.config/foobar/config.json', Config::Parser::json);
```

### Available parsers

Because there's so many ways to structure your configuration files, the parsers
for these are their own modules. This allows for easy implementing new parsers,
or providing a custom parser for your project's configuration file.

The parser will be loaded during runtime, but you have to make sure it is
installed yourself.

The following parsers are available:

- json:
  - [`Config::Parser::json`](https://github.com/arjancwidlak/p6-Config-Parser-json)
  - [`Config::Parser::json`](https://github.com/robertlemmen/perl6-config-json)
- [`Config::Parser::toml`](https://github.com/scriptkitties/p6-Config-Parser-toml)
- [`Config::Parser::yaml`](https://github.com/scriptkitties/p6-Config-Parser-yaml)

### Writing your own parser

If you want to make your own parser, simply make a new class which extends the
`Config::Parser` class, and implements the `read` and `write` methods. The
`read` method *must* return a `Hash`. The `write` method *must* return a
`Bool`, `True` when writing was successful, `False` if not. Throwing
`Exception`s to indicate the kind of failure is recommended.

## Contributing

If you want to contribute to `Config`, you can do so by mailing your patches to
`~tyil/raku-devel@lists.sr.ht`. Any questions or other forms of feedback are
welcome too!

## License

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License version 3, as published by
the Free Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>.
