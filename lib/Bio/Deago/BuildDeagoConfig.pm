package Bio::Deago::BuildDeagoConfig;

use Moose;
use Config::General;
use File::Basename;

has 'config' 						=> ( is => 'ro', isa => 'Config::General', 	required => 1);
has 'config_file'				=> ( is => 'ro', isa => 'Str', 							default => "./deago.config");
has 'build_config_file' => ( is => 'ro', isa => 'Bool', lazy => 1, 	builder => '_build_config_file' );

sub _config_file_exists {
	my ($self) = @_;
	( defined($self->config_file) && -e $self->config_file ) ? return 1 : return 0;
}

sub _build_config_file {
	my ($self) = @_;

	( defined($self->config_file) && -d dirname($self->config_file) ) or die "Error: Could not find output directory for config file: " . $self->config_file;
	$self->config->save_file($self->config_file);
	
	return $self->_config_file_exists();
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;