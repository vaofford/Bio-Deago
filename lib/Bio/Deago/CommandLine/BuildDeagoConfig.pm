package Bio::Deago::CommandLine::BuildDeagoConfig;

# ABSTRACT: Build a configuration file for use with deago

=head1 SYNOPSIS
Build a configuration file for use with deago
=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Config::General;
use File::Basename;

use Bio::Deago::BuildDeagoConfig;

extends 'Bio::Deago::CommandLine::Common';
with 'Bio::Deago::Config::Role';

has 'args'         			=> ( is => 'ro', isa => 'ArrayRef', required => 1 );
#has 'script_name'  			=> ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'         			=> ( is => 'rw', isa => 'Bool', 		default => 0 );

has '_error_message' 		=> ( is => 'rw', isa => 'Str' );
has 'verbose' 					=> ( is => 'rw', isa => 'Bool', 		default => 0 );
has 'output_file' 			=> ( is => 'rw', isa => 'Str', 			default=>'deago.config');
has 'output_directory'	=> ( is => 'rw', isa => 'Str', 			default => '.' );

sub BUILD {
	my ($self) = @_;

	my ( $help, $verbose, $output_file, $output_directory, $counts_directory, $targets_file, $results_directory, $annotation_file, $control, $qvalue, $keep_images, $qc_only, $go_analysis, $cmd_version );

	GetOptionsFromArray(
		$self->args,
		'v|verbose'           	=> \$verbose,
		'o|output_file=s'     	=> \$output_file,
		'd|output_directory=s'	=> \$output_directory,
		'c|counts_directory=s'	=> \$counts_directory,
		't|targets=s'						=> \$targets_file,
		'r|results_directory=s' => \$results_directory,
		'a|annotation_file=s'		=> \$annotation_file,
		'control=s'							=> \$control,
		'q|qvalue=i'						=> \$qvalue,
		'keep_images'			      => \$keep_images,
		'qc|qc_only'						=> \$qc_only,
		'go|go_analysis'				=> \$go_analysis,
		'w|version'             => \$cmd_version,
		'h|help'                => \$help
	);

	if ( defined($verbose) ) {
  	$self->verbose($verbose);
		$self->logger->level(10000);
	}

	$self->help($help) if(defined($help));
	( !$self->help ) or die $self->usage_text;

	$self->version($cmd_version) if ( defined($cmd_version) );
	if ( $self->version ) {
		die($self->_version());
	}

	if ( @{ $self->args } > 0 ) {
		$self->_error_message("Error: You need to remove trailing arguements");
	}

	if( !defined($counts_directory) ) {
		$self->_error_message("Error: You need to provide a counts directory");
	} else {
		$self->counts_directory($counts_directory);
	}

	if( !defined($targets_file) ) {
		$self->_error_message("Error: You need to provide a targets_file");
	} else {
		$self->targets_file($targets_file);
	}

	$self->annotation_file($annotation_file) if ( defined($annotation_file) );
	$self->control($control) if ( defined($control) );

}

sub run {
	my ($self) = @_;

	if ( defined( $self->_error_message ) ) {
		print $self->_error_message . "\n";
		die $self->usage_text;
	}

	my %config_parameters = ( 'counts_directory' 	=> $self->counts_directory,
														'targets_file' 			=> $self->targets_file,
														'results_directory' => $self->results_directory,
														'qvalue'						=> $self->qvalue,
														'keep_images'				=> $self->keep_images,
														'qc_only'						=> $self->qc_only,
														'go_analysis'				=> $self->go_analysis
													);

	$config_parameters{'annotation_file'} = $self->annotation_file if ( defined($self->annotation_file) );
	$config_parameters{'control'} = $self->control if ( defined($self->control) );

	my $config_file = $self->output_directory . "/" . $self->output_file;

	my $config_obj = Config::General->new( 	-ConfigFile => $config_file, 
																					-ConfigHash => \%config_parameters, 
																					-AllowMultiOptions => 'no'
																				);

	my $deago_config = Bio::Deago::BuildDeagoConfig->new( 'config' => $config_obj );

	$deago_config->config_file();
}

sub usage_text {
	my ($self) = @_;

	return <<USAGE;
Usage: build_deago_config [options]
Builds a tab-delimited key/value config file for use with deago
Options: -c STR        directory containing count files
         -t STR        targets file
         -r STR        results directory [current working directory]
         -o STR        output filename [deago.config]
         -d STR        output directory for config file [.]
         -a STR        annotation file 
         -q INT        qvalue (DESeq2) [0.05]
         --control     name of control condition (must be present in targets file)
         --keep_images keep images used in report [0]
         --qc          QC only [0]
         --go          GO term enrichment [0]
         -v            verbose output to STDOUT
         -w            print version and exit
         -h            this help message
USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;