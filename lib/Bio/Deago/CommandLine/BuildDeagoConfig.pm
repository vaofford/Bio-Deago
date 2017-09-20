package Bio::Deago::CommandLine::BuildDeagoConfig;

# ABSTRACT: Build a configuration file for use with deago

=head1 SYNOPSIS
Build a configuration file for use with deago
=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Config::General;

use Bio::Deago::BuildDeagoConfig;

extends 'Bio::Deago::CommandLine::Common';
with 'Bio::Deago::Config::Role';

has 'args'         			=> ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name'  			=> ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'         			=> ( is => 'rw', isa => 'Bool', 		default => 0 );

has '_error_message' 		=> ( is => 'rw', isa => 'Str' );
has 'verbose' 					=> ( is => 'rw', isa => 'Bool', 		default => 0 );
has 'output_file' 			=> ( is => 'rw', isa => 'Str', 			default=>'deago.config');
has 'output_directory'	=> ( is => 'rw', isa => 'Str', 			default => '.' );

sub BUILD {
	my ($self) = @_;

	my ( 	$help, $verbose, $output_file, $output_directory, 
				$counts_directory, $targets_file, $results_directory, 
				$annotation_file, $control, $qvalue, $count_type, $count_delim,
				$count_column, $skip_lines, $gene_ids, $keep_images, 
				$qc_only, $go_analysis, $go_levels, $cmd_version );

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
		'q|qvalue=f'						=> \$qvalue,
		'count_type=s'					=> \$count_type,
		'count_column=i'				=> \$count_column,
		'count_delim=s'					=> \$count_delim,
		'skip_lines=i'					=> \$skip_lines,		
		'gene_ids=s'						=> \$gene_ids,		
		'keep_images'			      => \$keep_images,
		'qc|qc_only'						=> \$qc_only,
		'go|go_analysis'				=> \$go_analysis,
		'go_levels=s'						=> \$go_levels,
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
		$self->_error_message("Error: You need to provide a targets file");
	} else {
		$self->targets_file($targets_file);
	}

	$self->results_directory($results_directory) 							if ( defined($results_directory) );
	$self->annotation_file($annotation_file) 									if ( defined($annotation_file) );
	$self->control($control) 																	if ( defined($control) );
	$self->qvalue($qvalue) 																		if ( defined($qvalue) );
	$self->keep_images($keep_images) 													if ( defined($keep_images) );
	$self->qc_only($qc_only) 																	if ( defined($qc_only) );
	$self->go_analysis($go_analysis) 													if ( defined($go_analysis) );

	$self->_error_message("Error: go_levels must be either BP, MF or all") if ( defined($go_levels) && $go_levels ne "BP" && $go_levels ne "MF" && $go_levels ne "all");
	$self->go_levels($go_levels) 															if ( defined($go_levels) );

	$self->_error_message("Error: count_type must be either featurecounts or expression") if ( defined($count_type) && $count_type ne "featurecounts" && $count_type ne "expression");
	$self->count_type($count_type) 														if ( defined($count_type) );

	$self->count_column($count_column) 												if ( defined($count_column) );
	$self->skip_lines($skip_lines) 														if ( defined($skip_lines) );
	$self->gene_ids($gene_ids) 																if ( defined($gene_ids) );
	$self->count_delim($count_delim) 													if ( defined($count_delim) );

	$self->output_file( $output_file ) 												if ( defined($output_file) );
	$self->output_directory( $output_directory =~ s/\/$//r ) 	if ( defined($output_directory) );

}

sub run {
	my ($self) = @_;

	if ( defined( $self->_error_message ) ) {
		print $self->_error_message . "\n";
		die $self->usage_text;
	}

	my $config_file = $self->output_directory . "/" . $self->output_file;
	$self->config_file($config_file) if ( defined($config_file) );

	my $config_hash = $self->build_config_hash();
	$self->config_hash($config_hash) if ( defined($config_hash) );

	if ( $self->config_is_valid() ) {
		my $deago_config = Bio::Deago::BuildDeagoConfig->new( 'config' => $self->config_hash, 'config_file' => $self->config_file );
		$deago_config->build_config_file() or $self->logger->error("Error: Could not write config file:" . $self->config_file);
	} else {
		$self->logger->error("Error: Could not write config file, options are not valid");
	}
}

sub usage_text {
	my ($self) = @_;

	return <<USAGE;
Usage: build_deago_config [options]
Builds a tab-delimited key/value config file for use with deago

Options: -c STR         directory containing count files (absolute path)
         -t STR         targets filename (absolute path)
         -r STR         results directory [current working directory]
         -o STR         output filename for config file [deago.config]
         -d STR         output directory for config file [.]
         -a STR         annotation filename (absolute path)
         -q NUM         qvalue (DESeq2) [0.05]
         --control      name of control condition (must be present in targets file)
         --keep_images  keep images used in report
         --qc           QC only
         --go           GO term enrichment
         --count_type   type of count file [expression|featurecounts]
         --count_column number of column containing count values
         --skip_lines   number of lines to skip in count file
         --count_delim  count file delimiter
         --go_levels    BP only, MF only or all [BP|MF|all]
         -v             verbose output to STDOUT
         -w             print version and exit
         -h             this help message
USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;