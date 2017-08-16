package Bio::Deago::BuildDeagoConfig;

use Moose;
use Config::General;

with 'Bio::Deago::Config::Role';

has 'config' 			=> ( is => 'ro', isa => 'Config::General', 	required => 1);
has 'config_file' => ( is => 'ro', isa => 'Str', lazy => 1, 	builder => '_build_config_file' );

sub _validate_config {
	my ($self) = @_;
}

sub _build_config_file {
	my ($self) = @_;

	use Data::Dumper;
	print Dumper($self->config);
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;