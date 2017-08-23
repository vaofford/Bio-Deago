package Bio::Deago::Targets;

use Moose;
use File::Slurper qw(read_lines);

use Data::Dumper;

has 'targets_file'		=> ( is => 'rw', isa => 'Str', 			required => 1);
has 'targets'					=> ( is => 'ro', isa => 'HashRef',	lazy => 1, 		builder => '_read_targets' );
has 'is_valid' 				=> ( is => 'ro', isa => 'Bool', 		lazy => 1, 		builder => '_validate_targets' );

1;