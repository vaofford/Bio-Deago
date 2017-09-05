package Bio::Deago::Targets;

use Moose;
use File::Slurper qw(read_lines);
use Text::CSV::Hashify;

use Data::Dumper;

has 'config_hash' 		=> ( is => 'ro', isa => 'Config::General', 	required => 1);
has 'targets_file'		=> ( is => 'rw', isa => 'Str');
has 'targets'					=> ( is => 'ro', isa => 'ArrayRef',					lazy => 1, 		builder => '_read_targets' );
has 'target_is_valid' => ( is => 'ro', isa => 'Bool', 						lazy => 1, 		builder => '_validate_targets' );

sub BUILD {
	my ($self) = @_;

	$self->targets_file($self->config_hash->{'config'}{'targets_file'});

	Bio::Deago::Exceptions::FileNotFound->throw( error => "Error: Cannot find targets file: " . $self->targets_file . "\n") 
		unless ( defined($self->targets_file) && -e $self->targets_file );

	Bio::Deago::Exceptions::DirectoryNotFound->throw( error => "Error: Cannot find counts directory: " . $self->config_hash->{'config'}{'counts_directory'} . "\n") 
		unless ( defined($self->config_hash->{'config'}{'counts_directory'}) && -e $self->config_hash->{'config'}{'counts_directory'} );

	$self->targets();
	$self->target_is_valid();

}

sub _read_targets {
	my ($self) = @_;

	my $targets_obj = Text::CSV::Hashify->new({	file		=> $self->targets_file,
																							sep			=> "\t",
																							format 	=>	'aoh'
																 						});

	my $target_arrayref = $targets_obj->all;
	for (my $i=0; $i < scalar(@$target_arrayref); $i++) {
		%{$target_arrayref->[$i]} = ( map { lc($_) => $target_arrayref->[$i]{$_} } keys %{ $target_arrayref->[$i] } );
	}

	return($target_arrayref);
}

sub _validate_targets {
	my ($self) = @_;

	my $is_valid = 0;

	$is_valid = (	$self->_expected_columns_present &&
								$self->_control_present && 
								$self->_count_files_exist
							);

	return $is_valid;
}

sub _count_files_exist {
	my ($self) = @_;

	my $count_directory = $self->config_hash->{'config'}{'counts_directory'};
	my @count_files = grep defined, map {$_->{'filename'}} @{$self->targets};

	my $count_files_found = 0;
	foreach my $count_file (@count_files) {
		$count_file = $count_directory . "/" . $count_file;
		Bio::Deago::Exceptions::FileNotFound->throw( error => "Error: Cannot find count file: " . $count_file  . "\n")
		unless(-e $count_file);
	}

	return 1;
}

sub _expected_columns_present{
	my ($self) = @_;

	my @expected_columns = qw(filename replicate condition);

	my $count_files = $self->targets;
	my %first_row = ( map { lc($_) => 1 } keys %{ @$count_files[0] });

	my $expected_columns_present = 0;
	foreach my $expected_column ( @expected_columns ){
		$expected_columns_present++ if ( exists $first_row{$expected_column} );
	}

	( $expected_columns_present == scalar(@expected_columns) ) ? return 1 : return 0;
}

sub _control_present {
	my ($self) = @_;
	if ( defined $self->config_hash->{'config'}{'control'} ) 
	{
		my $column_to_check = 'condition';
		my @matched_controls = grep { $_->{$column_to_check} eq $self->config_hash->{'config'}{'control'} } @{$self->targets};
		( @matched_controls ) ? return 1 : return 0;
	} else {
		return 1;
	}
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;