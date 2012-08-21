package OpenmakeX::Env;

use Moo;

with 'App::Services::Role::Logger';

use File::HomeDir;
use Config::Properties::Simple;
use common::sense;

has properties => (
	is => 'rw',
	isa => 'Config::Properties::Simple'
	
 );

has openmake_server => (
	is=>'rw',
	isa => 'Str',
	
);

sub BUILD {
	my $s = shift;

	$s->get_omenv_properties();
	$s->openmake_server( $s->properties->getProperty('OPENMAKE_SERVER') || $ENV{OPENMAKE_SERVER});

}

sub get_omenv_properties {
	my $s = shift or die;

	my $omenv = 'omenvironment.properties';
	my $home  = File::HomeDir->my_home;

	my @files;

	if ( $^O =~ /win/i ) {
		push @files, qq($ENV{APPDATA}/openmake/$omenv $ENV{ProgramFiles}/openmake/$omenv);
	
	} else {
		push @files, "${home}/.openmake/${omenv}";
	
	}
	
	my $file;
	
	map { $file = $_ if -f $_ } @files;
	
	return undef unless $file;
	
	$s->log->info("Reading config file $file...");

	my $cfg = Config::Properties::Simple->new( file => $file );

	$s->properties($cfg);

}

no Moo;

1;
