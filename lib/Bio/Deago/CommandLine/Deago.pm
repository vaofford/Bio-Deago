package Bio::Deago::CommandLine::Deago;

# ABSTRACT: RNA-Seq differential expression qc and analysis
# Some of the functionality across this package has been borrowed from Roary (Andrew Page)

=head1 SYNOPSIS

RNA-Seq differential expression qc and analysis

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use File::Basename;
use Data::Dumper;

use Bio::Deago;

extends 'Bio::Deago::CommandLine::Common';
with 'Bio::Deago::Config::Role';

has 'args'         						=> ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name'  						=> ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'         						=> ( is => 'rw', isa => 'Bool', 		default => 0 );
		
has '_error_message' 					=> ( is => 'rw', isa => 'Str' );
has 'verbose' 								=> ( is => 'rw', isa => 'Bool', 		default => 0 );

has 'convert_annotation'			=> ( is => 'rw', isa => 'Bool', 		default => 0 );
has 'annotation_delimiter'		=> ( is => 'rw', isa => 'Str', 			default => '\t' );
has 'build_config' 						=> ( is => 'rw', isa => 'Bool', 		default => 0 );
has 'config_hash'     				=> ( is => 'rw', isa => 'Config::General');
has 'config_file' 						=> ( is => 'rw', isa => 'Str', 			default => './deago.config' );
has 'markdown_file' 					=> ( is => 'rw', isa => 'Str', 			default => './deago_markdown.Rmd' );
has 'html_file' 							=> ( is => 'rw', isa => 'Str', 			default => './deago_markdown.html' );
has 'output_directory' 				=> ( is => 'rw', isa => 'Str', 			default => '.' );

sub BUILD {
	my ($self) = @_;

	my ( 	$help,					$verbose,						$convert_annotation,	$build_config,
				$markdown_file,	$html_file,					$counts_directory, 		$annotation_delimiter,
				$targets_file, 	$results_directory, $annotation_file, 		$control, 
				$qvalue, 				$count_type, 				$count_delim,				 	$count_column, 
				$skip_lines, 		$gene_ids, 					$keep_images, 				$qc_only, 
				$go_analysis, 	$go_levels, 				$cmd_version, 				$config_file,
				$output_directory
			);

	GetOptionsFromArray(
		$self->args,
		'v|verbose'           		=> \$verbose,
		'o|output_directory=s'		=> \$output_directory,
		'convert_annotation'			=> \$convert_annotation,
		'annotation_delim=s'			=> \$annotation_delimiter,
		'build_config'						=> \$build_config,
		'config_file=s'						=> \$config_file,
		'markdown_file=s'					=> \$markdown_file,
		'html_file=s'							=> \$html_file,
		'c|counts_directory=s'		=> \$counts_directory,
		't|targets=s'							=> \$targets_file,
		'r|results_directory=s' 	=> \$results_directory,
		'a|annotation_file=s'			=> \$annotation_file,
		'control=s'								=> \$control,
		'q|qvalue=f'							=> \$qvalue,
		'count_type=s'						=> \$count_type,
		'count_column=i'					=> \$count_column,
		'count_delim=s'						=> \$count_delim,
		'skip_lines=i'						=> \$skip_lines,		
		'gene_ids=s'							=> \$gene_ids,		
		'keep_images'			      	=> \$keep_images,
		'qc|qc_only'							=> \$qc_only,
		'go|go_analysis'					=> \$go_analysis,
		'go_levels=s'							=> \$go_levels,
		'w|version'            		=> \$cmd_version,
		'h|help'               		=> \$help
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

	$self->output_directory($output_directory) if ( defined($output_directory) && $output_directory ne '.' );
	$self->_error_message("Error: Output directory doesn't exist: " . $self->output_directory) if( defined($self->output_directory) && !-e $self->output_directory );
	if ( defined($self->output_directory) && $self->output_directory ne '.') {
		$self->markdown_file(  )
	}
	
	$self->convert_annotation($convert_annotation)						if ( defined($convert_annotation) );
	$self->annotation_delimiter($annotation_delimiter)				if ( defined($annotation_delimiter) );
	$self->build_config($build_config)												if ( defined($build_config) );

	$self->config_file($config_file)													if ( defined($config_file) );
	$self->markdown_file($markdown_file)											if ( defined($markdown_file) );
	$self->html_file($html_file)															if ( defined($html_file) );

	$self->counts_directory($counts_directory)								if ( defined($counts_directory) );
	$self->targets_file($targets_file)												if ( defined($targets_file) );

	$self->results_directory($results_directory) 							if ( defined($results_directory) );
	$self->annotation_file($annotation_file) 									if ( defined($annotation_file) );
	$self->control($control) 																	if ( defined($control) );
	$self->qvalue($qvalue) 																		if ( defined($qvalue) );
	$self->keep_images($keep_images) 													if ( defined($keep_images) );
	$self->qc_only($qc_only) 																	if ( defined($qc_only) );
	$self->go_analysis($go_analysis) 													if ( defined($go_analysis) );

	$self->_error_message("Error: go_levels must be either BP, MF or all") if ( defined($go_levels) && $go_levels ne "BP" && $go_levels ne "MF" && $go_levels ne "all");
	$self->go_levels($go_levels) 															if ( defined($go_levels) );

	$self->_error_message("Error: count_type must be either featurecounts or expression") if ( defined($count_type) && $count_type ne "featurecounts" && $count_type ne "expression" && $count_type ne "unknown");
	$self->count_type($count_type) 														if ( defined($count_type) );

	$self->count_column($count_column) 												if ( defined($count_column) );
	$self->skip_lines($skip_lines) 														if ( defined($skip_lines) );
	$self->gene_ids($gene_ids) 																if ( defined($gene_ids) );
	$self->count_delim($count_delim) 													if ( defined($count_delim) );

	$self->_error_message("Error: Cannot generate markdown file as markdown file already exists: " . $self->markdown_file) if( defined($self->markdown_file) && -e $self->markdown_file );
	$self->_error_message("Error: Cannot generate html file as html file already exists: " . $self->html_file) if( defined($self->html_file) && -e $self->html_file );

	$self->_error_message("Error: You need to provide or build a configuration file") if( !$self->build_config && !defined($config_file) );
	$self->_error_message("Error: Configuration file does not exist: " . $self->config_file) if( !$self->build_config && defined($config_file) && !-e $self->config_file );
	$self->_error_message("Error: You need to provide both a counts directory and targets file or a valid configuration file") if( ((!defined($self->counts_directory) && !defined($self->targets_file)) && $self->build_config) || !defined($self->config_file) ); 

	$self->_error_message("Error: Cannot build configuration file as destination directory doesn't exist: " . $self->config_file ) if( $self->build_config && defined($self->config_file) && !-d dirname($self->config_file) );
	$self->_error_message("Error: Cannot build configuration file as configuration file already exists: " . $self->config_file) if( $self->build_config && defined($self->config_file) && -e $self->config_file );

	$self->_error_message("Error: --convert_annotation requires --build_config") if( $self->convert_annotation && !$self->build_config );
	$self->_error_message("Error: Cannot convert annotation file as no annotation file given") if( $self->convert_annotation && !defined($self->annotation_file) && $self->build_config );
	$self->_error_message("Error: Cannot convert annotation file as annotation file does not exist: " . $self->annotation_file) if( $self->convert_annotation && defined($self->annotation_file) && !-e $self->annotation_file );
}

sub run {
	my ($self) = @_;

	if ( defined( $self->_error_message ) ) {
		print $self->_error_message . "\n";
		die $self->usage_text;
	}

	my $config_hash;
  if ( $self->build_config ) {
		$self->logger->info("Building config hash...");
		$config_hash = $self->build_config_hash();
	} else {
		$self->logger->info("Found configuration file: " . $self->config_file);
		$self->logger->info("Reading config hash...");
		$config_hash = $self->read_config_file();
	}
	$self->config_hash($config_hash) if ( defined($config_hash) );

	$self->logger->info("Running DEAGO...");
	my $deago_obj = Bio::Deago->new(	output_directory			=> $self->output_directory,
																		convert_annotation		=> $self->convert_annotation,
																		annotation_delimiter	=> $self->annotation_delimiter,
																		build_config 					=> $self->build_config,
																		config_hash 					=> $self->config_hash,
																		config_file						=> $self->config_file,
																		markdown_file 				=> $self->markdown_file,
																		html_file 						=> $self->html_file,
																		verbose 							=> $self->verbose
																	);
	$deago_obj->run();
}

sub _version {
    my ($self) = @_;
    if ( defined($Bio::Deago::CommandLine::Deago::VERSION) ) {
        return $Bio::Deago::CommandLine::Deago::VERSION . "\n";
    }
    else {
        return "x.y.z\n";
    }
}

sub usage_text {
	my ($self) = @_;

	return <<USAGE;
Usage: deago [options]
RNA-Seq differential expression qc and analysis

Main options:
  --output_directory (-o) output directory [.]
  --convert_annotation    convert annotation for use with deago (requires -a)
  --annotation_delim      annotation file delimiter [\\t]
  --build_config          build configuration file from command line arguments (see configuration options)
  --config_file           configuration filename or output filename for configuration file if building [./deago.config]
  --markdown_file         output filename for markdown file [./deago_markdown.Rmd]
  --html_file             output filename for html file [./deago_markdown.html]
  -v                      verbose output to STDOUT
  -w                      print version and exit
  -h                      print help message and exit

Configuration options (required):
  -c STR          directory containing count files (absolute path)
  -t STR          targets filename (absolute path)

 Configuration options (optional):
  -r STR          results directory [current working directory]
  -a STR          annotation filename (absolute path)
  -q NUM          qvalue (DESeq2) [0.05]
  --control       name of control condition (must be present in targets file)
  --keep_images   keep images used in report
  --qc            QC only
  --go            GO term enrichment
  --go_levels     BP only, MF only or all [BP|MF|all]
  --count_type    type of count file [expression|featurecounts]
  --count_column  number of column containing count values
  --skip_lines    number of lines to skip in count file
  --count_delim   count file delimiter
  --gene_ids      name of column containing gene ids

DEAGO takes in a configuration file containing key/value pairs [default: ./deago.config]. You can 
use your own configuration file with --config_file or specify parameters and let DEAGO build a 
configuration file with --build_config (and --config_file if you don't want the default 
configuration filename). For more information on configuration parameters run: build_deago_config -h.

DEAGO will then build a master R markdown file (--markdown_file if you don't want the default 
markdown filename) from templates which utilize the companion DEAGO R package and the key/value 
pairs set out in the configuration file. The R markdown will be processed and used to generate a 
HTML report (--html_file if you don't want the default html filename).

To use custom gene names and for GO term enrichment (--go) and annotation file must be provided 
(-a). Annotations downloaded from BioMart or those in a similar format can be converted for use 
with DEAGO.  For more information run: mart_to_deago -h.
         
USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;