lint:
	bin/rubocop

test:
	bin/rspec

test_rbs:
	RUBYOPT='-rbundler/setup -rrbs/test/setup' RBS_TEST_TARGET='TinyAdmin::*' bin/rspec
