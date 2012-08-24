package App::Openmake::Util;

use Moose;

with 'App::Services::Logger::Role';

sub handle_rc {
	my $s = shift or confess;

	my $rc = shift;

	unless (defined $rc) {
		$s->log->error("No return code passed");
		return undef;
		
	}

	return 1 unless $rc;

	if ( $rc == -1 ) {
		$s->log->fatal( "failed to execute: $!");

	} elsif ( $rc & 127 ) {
		$s->log->fatal('child died with signal ' . ($rc & 127) . ' ' . (( $? & 128 ) ? 'with' : 'without') . ' a coredump');

	} else {
		$s->log->error("child exited with value ", $rc >> 8);

	}

}

no Moose;

1;
