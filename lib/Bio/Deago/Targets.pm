package Bio::Deago::Targets;

use Moose;
use File::Slurper qw(read_lines);
use Text::CSV::Hashify;

use Data::Dumper;
use Bio::Deago::Config::Role;

has 'targets_file'		=> ( is => 'rw', isa => 'Str', 			required => 1);
has 'targets'					=> ( is => 'ro', isa => 'ArrayRef',	lazy => 1, 		builder => '_read_targets' );
has 'is_valid' 				=> ( is => 'ro', isa => 'Bool', 		lazy => 1, 		builder => '_validate_targets' );

sub BUILD {
	my ($self) = @_;
	
	Bio::Deago::Exceptions::FileNotFound->throw( error => "Error: Cannot find targets_file file: " . $self->targets_file . "\n") 
		unless ( defined($self->targets_file) && -e $self->targets_file );

	$self->targets();
}

sub _read_targets {
	my ($self) = @_;

	my $targets_hashref = Text::CSV::Hashify->new({	file		=> $self->targets_file,
																									sep			=> "\t",
																									format 	=>	'aoh'
																 								});
	return( $targets_hashref->all );
}

sub _validate_target_files {

}

sub _validate_control {

}

sub _validate_targets {
	my @expected_columns = qw(filename replicate condition);


}

no Moose;
__PACKAGE__->meta->make_immutable;

1;