#!perl
##!perl -T

use strict;
use warnings;

use Test::More;

use Test::FTP::Server;
use Test::TCP;

use Net::FTP;

my $userid = 'testid';
my $password = 'testpass';

test_tcp(
	server => sub {
		my $port = shift;

		my $server = Test::FTP::Server->new(
			'users' => [{
				'userid' => $userid,
				'password' => $password,
				'root' => '/',
			}],
			'ftpd_conf' => {
				'port' => $port,
				'daemon mode' => 1,
				'run in background' => 0,
			},
		);
		ok($server, 'init server');

		$server->run;
	},
	client => sub {
		my $port = shift;

		my $ftp = Net::FTP->new('localhost', Port => $port);
		ok($ftp);
		ok($ftp->login($userid, $password));
		ok($ftp->quit());
	},
);

done_testing;

1;
