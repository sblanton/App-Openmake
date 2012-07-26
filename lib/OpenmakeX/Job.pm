package OpenmakeX::Job;

use Moose;

with 'App::Services::Role::Logger';

has job_name => (
	is  => 'rw',
	isa => 'Str',
);

has om_env => ( is => 'rw', );

has om_util => (is=>'rw');

sub exec {
	my $s = shift;

	my $omcmdlinejar = $s->om_env->properties->getProperty('OPENMAKE_HOME') . '/bin/omcmdline.jar';

	$s->log->logconfess("omcmdline.jar not found")
	  unless -f $omcmdlinejar;

	$s->log->logconfess("job not specified.")
	  unless $s->job_name;

	my $command = "java -cp \"$omcmdlinejar\" com.openmake.cmdline.Main -build \"" . $s->job_name . "\"";

	my @output = `$command`;

	my $rc = $?;

	map {
		if ( $_ =~ /error/i ) {
			$s->log->error($_);
			
		} else {
			$s->log->info($_);
			
		}
		
	} @output;

	$s->om_util->handle_rc( $rc );

}

no Moose;

1;
