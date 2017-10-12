package Bio::Deago::BuildDeagoConfig;

use Moose;
use Config::General;
use File::Basename;

has 'config' 						=> ( is => 'ro', isa => 'Config::General', 	required => 1);
has 'config_file'				=> ( is => 'ro', isa => 'Str', 							default => "./deago.config");
has 'build_config_file' => ( is => 'ro', isa => 'Bool', lazy => 1, 	builder => '_build_config_file' );

sub _config_file_exists {
	my ($self) = @_;
	Bio::Deago::Exceptions::FileNotFound->throw( error => "Error: Could not find configuration file: " . $self->config_file . "\n" )
    unless ( defined($self->config_file) && -e $self->config_file  );	
  return 1;
}

sub _config_directory_exists {
	my ($self) = @_;
	Bio::Deago::Exceptions::FileNotFound->throw( error => "Error: Could not find output directory for configuration file: " . $self->config_file . "\n" )
    unless ( defined($self->config_file) && -d dirname($self->config_file)  );	
  return 1;
}

sub _build_config_file {
	my ($self) = @_;
	$self->_config_directory_exists();
	$self->config->save_file($self->config_file);
	$self->_config_file_exists();
	return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;