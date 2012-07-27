package OpenmakeX::Container;

use Moose;
extends 'Bread::Board::Container';

use Bread::Board;

sub BUILD {
	$_[0]->build_container;
}

has log_conf => ( is => 'rw', );

has job_name => (
	is       => 'rw',
	isa      => 'Str',
	required => 1
);

has '+name' => ( default => 'OpenmakeX' );

sub build_container {
	my $s = shift;

	return container $s => as {

		service 'log_conf' => $s->log_conf;
		service 'job_name' => $s->job_name;

		service 'logger_svc' => (
			class        => 'App::Services::Service::Logger',
			lifecycle    => 'Singleton',
			dependencies => { log_conf => 'log_conf' }

		);

		service 'om_env_svc' => (
			class        => 'OpenmakeX::Env',
			dependencies => {
				logger_svc => depends_on('logger_svc'),

			  }

		);

		service 'om_util_svc' => (
			class        => 'OpenmakeX::Util',
			dependencies => {
				logger_svc => depends_on('logger_svc'),

			  }

		);

		service 'om_job_svc' => (
			class        => 'OpenmakeX::Job',
			dependencies => {
				logger_svc => depends_on('logger_svc'),
				om_env     => depends_on('om_env_svc'),
				om_util    => depends_on('om_util_svc'),
				job_name   => 'job_name',

			  }

		);

	}
}

no Moose;

1;
