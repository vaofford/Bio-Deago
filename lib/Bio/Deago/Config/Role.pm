package Bio::Deago::Config::Role;

use Moose::Role;
use namespace::autoclean;
use Cwd;
use Config::General;

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
has 'config_hash'				=> ( is => 'ro', isa => 'Config::General',	lazy => 1, 										builder => '_build_config' );
has 'is_valid' 					=> ( is => 'ro', isa => 'Bool', 						builder => 'validate_config' );

sub _build_config {
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

	my $config_obj = Config::General->new( 	-ConfigFile 				=> $self->config_file, 
																					-ConfigHash 				=> \%config_hash, 
																					-AllowMultiOptions 	=> 'no'
																				);

	return($config_obj);
}

sub _counts_directory_exists {
	my ($self) = @_;

	if ( defined($self->counts_directory) ){
		return 1;
	}	else {
		return 0;
	}
}

sub validate_config {
	my ($self) = @_;

	return 0;

	#use Data::Dumper;
	#print Dumper($self);

	#print $self->ParseConfig("counts_directory");

	#print $self->_counts_directory_exists;

	#return 1 if ($self->_counts_directory_exists)
	#use Data::Dumper;
	#print Dumper($self);
}	

1;