package Bio::Deago::Config::Role;

use Moose::Role;
use namespace::autoclean;
use Cwd;
use Config::General;
use Bio::Deago::Exceptions;

has 'counts_directory'  => ( is => 'rw', isa => 'Str');
has 'targets_file' 	   	=> ( is => 'rw', isa => 'Str');
has 'results_directory' => ( is => 'rw', isa => 'Str',							default => getcwd());
has 'annotation_file'   => ( is => 'rw', isa => 'Str');
has 'control'   				=> ( is => 'rw', isa => 'Str');
has 'qvalue'   					=> ( is => 'rw', isa => 'Num', 							default => 0.05);
has 'keep_images'   		=> ( is => 'rw', isa => 'Bool', 						default => 0);
has 'qc_only'  					=> ( is => 'rw', isa => 'Bool', 						default => 0);
has 'go_analysis' 			=> ( is => 'rw', isa => 'Bool', 						default => 0);
has 'config_file'				=> ( is => 'rw', isa => 'Str', 							default => './default.config');
has 'config_hash'				=> ( is => 'rw', isa => 'Config::General');
has 'config_is_valid' 	=> ( is => 'ro', isa => 'Bool', 						lazy=>1, 		builder => 'validate_config' );

sub build_config_hash {
	my ($self) = @_;
	my %config_hash = ( 'counts_directory' 	=> $self->counts_directory,
											'targets_file' 			=> $self->targets_file,
											'results_directory' => $self->results_directory,
											'qvalue'						=> $self->qvalue,
											'keep_images'				=> $self->keep_images,
											'qc_only'						=> $self->qc_only,
											'go_analysis'				=> $self->go_analysis
										);

	$config_hash{'annotation_file'} = $self->annotation_file if ( defined($self->annotation_file) );
	$config_hash{'control'} = $self->control if ( defined($self->control) );

	my $config_obj = Config::General->new(	-ConfigHash 				=> \%config_hash, 
																					-AllowMultiOptions 	=> 'no',
																					-SaveSorted 				=> 'yes'
																				);
	return($config_obj);
}

sub read_config_file {
	my ($self) = @_;

	Bio::Deago::Exceptions::FileNotFound->throw( error => "Error: Cannot find config file: " . $self->config_file . "\n") 
		unless ( -e $self->config_file );

	my $config_obj = Config::General->new($self->config_file);

	$self->config_hash($config_obj);
}

sub _counts_directory_exists {
	my ($self) = @_;
	( defined($self->config_hash->{'config'}{'counts_directory'}) && -d $self->config_hash->{'config'}{'counts_directory'} ) ? return 1 : return 0;
}

sub _targets_file_exists {
	my ($self) = @_;
	( defined($self->config_hash->{'config'}{'targets_file'}) && -e $self->config_hash->{'config'}{'targets_file'} ) ? return 1 : return 0;
}

sub _results_directory_exists {
	my ($self) = @_;
	( defined($self->config_hash->{'config'}{'results_directory'}) && -d $self->config_hash->{'config'}{'results_directory'} ) ? return 1 : return 0;
}

sub _annotation_file_exists {
	my ($self) = @_;
	( defined($self->config_hash->{'config'}{'annotation_file'}) && -e $self->config_hash->{'config'}{'annotation_file'} ) ? return 1 : return 0;
}

sub _qvalue_is_valid {
	my ($self) = @_;
	( $self->config_hash->{'config'}{'qvalue'} >= 0 && $self->config_hash->{'config'}{'qvalue'} <= 1 ) ? return 1 : return 0;
}

sub _go_analysis_is_valid {
	my ($self) = @_;
	( $self->config_hash->{'config'}{'go_analysis'} == 1 && $self->_annotation_file_exists == 1 ) ? return 1 : return 0;
}

sub _config_is_valid {
	my ($self) = @_;

	my $is_valid = 0;

	$is_valid = (	$self->_counts_directory_exists &&
								$self->_targets_file_exists &&
								$self->_results_directory_exists &&
								$self->_qvalue_is_valid);

	if ( defined($self->annotation_file) ) {
		$is_valid = ($is_valid && $self->_annotation_file_exists);
	}

	if ( $self->go_analysis == 1 ) {
		$is_valid = ($is_valid && $self->_go_analysis_is_valid);
	}

	return $is_valid;
}

sub validate_config {
	my ($self) = @_;

	return $self->_config_is_valid;
}	

1;