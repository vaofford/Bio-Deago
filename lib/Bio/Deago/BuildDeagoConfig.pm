package Bio::Deago::BuildDeagoConfig;

use Moose;
use Config::General;

with 'Bio::Deago::Config::Role';

has 'config' 			=> ( is => 'ro', isa => 'Config::General', 	required => 1);
has 'build_config_file' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build_config_file' );

sub _build_config_file {
	my ($self) = @_;

	use Data::Dumper;
	print Dumper($self);
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;