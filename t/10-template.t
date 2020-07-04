#!/usr/bin/env raku

use v6.d;

use Test;

use Config;

plan 2;

subtest 'Flat template', {
	plan 6;

	my $config = Config.new({
		foo => Any,
		bar => Any,
	}, :name<raku-config>);

	ok $config, 'Config object instantiated';

	ok $config.has('foo'), 'Config contains "foo"';
	ok $config.has('bar'), 'Config contains "bar"';

	nok $config.has('alpha'), 'Config does not contain "alpha"';
	nok $config.has('beta'), 'Config does not contain "beta"';

	is $config.keys.sort, < bar foo >, 'Config.keys is correct';
}

subtest 'Nested template', {
	plan 7;

	my $config = Config.new({
		foo => {
			alpha => Any,
		},
		bar => {
			beta => Any,
		},
		baz => Any,
	}, :name<raku-config>);

	ok $config, 'Config object instantiated';

	ok $config.has('foo'), 'Config contains "foo"';
	ok $config.has('foo.alpha'), 'Config contains "foo.alpha"';
	ok $config.has('baz'), 'Config contains "baz"';

	nok $config.has('omega.phi'), 'Config does not contain "omega.phi"';
	nok $config.has('omega'), 'Config does not contain "omega"';

	is $config.keys.sort, < bar.beta baz foo.alpha >, 'Config.keys is correct';
}
