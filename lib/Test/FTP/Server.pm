package Test::FTP::Server;

use strict;
use warnings;

our $VERSION = '0.01';

use Carp;

use File::Find;
use File::Spec;
use File::Copy;
use File::Temp qw/ tempfile tempdir /;

use Test::FTP::Server::Server;

sub new {
	my $class = shift;
	my (%opt) = @_;

	my @args = ();

	if (my $users = $opt{'users'}) {
		foreach my $u (@$users) {
			if (my $base = $u->{'sandbox'}) {

				croak($base . ' is not directory.') unless -d $base;

				my $dir = tempdir(CLEANUP => 1);
				File::Find::find({
					'wanted' => sub {
						my $src = my $dst = $_;
						$dst =~ s/^$base//;
						$dst = File::Spec->catfile($dir, $dst);

						if (-d $_) {
							mkdir($dst);
						}
						else {
							File::Copy::copy($src, $dst);
						}

						chmod((stat($src))[2], $dst);
						utime((stat($src))[8,9], $dst);
					},
					'no_chdir' => 1,
				}, $base);

				$u->{'root'} = $dir;
			}

			croak(
				'It\'s necessary to specify parameter that is ' .
				'"root" or "sandbox" for each user.'
			) unless $u->{'root'};
		}
		push(@args, '_test_users', $users);
	}

	if ($opt{'ftpd_conf'}) {
		if (ref $opt{'ftpd_conf'}) {
			my ($fh, $filename) = tempfile();
			while (my ($k, $v) = each %{ $opt{'ftpd_conf'} }) {
				print($fh "$k: $v\n");
			}
			close($fh);

			push(@args, '-C', $filename);
		}
		else {
			push(@args, '-C', $opt{'ftpd_conf'});
		}
	}

	my $self = bless({ 'args' => \@args }, $class);
}

sub run {
	my $self = shift;
	Test::FTP::Server::Server->run($self->{'args'});
}

1;
__END__

=head1 NAME

Test::FTP::Server - ftpd runner for tests

=head1 SYNOPSIS

  use Test::TCP;
  use Test::FTP::Server;

  my $userid = 'testuser';
  my $password = 'testpass';
  my $root_directory = '/path/to/root_directory';

  my $server = Test::FTP::Server->new(
    'users' => [{
      'userid' => $userid,
      'password' => $password,
      'root' => $root_directory,
    }],
    'ftpd_conf' => {
      'port' => $port,
      'daemon mode' => 1,
      'run in background' => 0,
    },
  );
  $server->run;

=head1 DESCRIPTION

C<Test::FTP::Server> run C<Net::FTPServer> internally.
The server's settings can be specified as a parameter, therefore it is not necessary to prepare the configuration file.

=head1 FUNCTIONS

=head2 new

Create a ftpd instance.

	if (my $users = $opt{'users'}) {
	}

	if ($opt{'ftpd_conf'}) {


The instance is terminated when the returned object is being DESTROYed.  If required programs (mysql_install_db and mysqld) were not found, the function returns undef and sets appropriate message to $Test::mysqld::errstr.

=head2 run

Run a ftpd instance. 

=head1 EXAMPLE

  use Test::FTP::Server;
  use Test::TCP;
  use Net::FTP;

  my $userid = 'testid';
  my $password = 'testpass';
  my $sandbox = '/path/to/sandbox_base';

  test_tcp(
    server => sub {
      my $port = shift;

      Test::FTP::Server->new(
        'users' => [{
          'userid' => $userid,
          'password' => $password,
          'sandbox' => $sandbox,
        }],
        'ftpd_conf' => {
          'port' => $port,
          'daemon mode' => 1,
          'run in background' => 0,
        },
      )->run;
    },
    client => sub {
      my $port = shift;

      my $ftp = Net::FTP->new('localhost', Port => $port);
      ok($ftp);
      ok($ftp->login($userid, $password));
      ok($ftp->quit());
    },
  );

=head1 AUTHOR

Taku Amano E<lt>taku@toi-planning.netE<gt>

=head1 SEE ALSO

L<Net::FTPServer>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
