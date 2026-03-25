specs:
	RUBYOPT='-rbundler/setup -rrbs/test/setup' RBS_TEST_TARGET='TinyAdmin::*' bin/rspec

console:
	bin/rails c

server:
	bin/rails s

seed:
	bin/rails db:migrate && bin/rails db:seed

lint:
	bin/rubocop
