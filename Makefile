specs:
	RUBYOPT='-rbundler/setup -rrbs/test/setup' RBS_TEST_TARGET='TinyAdmin::*' bin/rspec

server:
	bin/rails s -b 0.0.0.0 -p 4000

console:
	bin/rails c

lint:
	bin/rubocop

seed:
	cd spec/dummy_rails && bin/rails db:reset
