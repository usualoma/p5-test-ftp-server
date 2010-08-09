use ExtUtils::MakeMaker;
use Test::Dependencies
exclude => [qw(
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
)], style   => 'light';
ok_dependencies();
