use strict;
use warnings;

use strict;
use warnings;
use Test::More;

SKIP: {
    skip 'CPAN::Meta not installed', 1
	unless eval 'require CPAN::Meta; 1';
    skip 'File::Find::Rule::Perl not installed', 1
	unless eval 'require File::Find::Rule::Perl; 1';
    skip 'Test::Dependencies not installed', 1 
	unless eval 'require Test::Dependencies; 1';

    Test::Dependencies->import(exclude => [qw{ExtUtils::MakeMaker}],
			       style => 'light');

    my $meta = CPAN::Meta->load_file('MYMETA.yml');
    my @files =
	File::Find::Rule::Perl->perl_file->in('./lib', './t');

    ok_dependencies($meta, \@files, ignores => [qw(
	Test::Dependencies Test::Perl::Critic

	Test::FTP::Server
	Test::FTP::Server::Server
	Test::FTP::Server::DirHandle
	Test::FTP::Server::FileHandle
	Test::FTP::Server::Util

	Net::FTPServer::Full::FileHandle
	Net::FTPServer::Full::DirHandle
	Net::FTPServer::Full::Server

	Test::TCP
	File::Copy::Recursive
        )]);
};

done_testing();
