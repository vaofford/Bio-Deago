package Bio::Deago::CommandLine::Deago;

# ABSTRACT: RNA-Seq differential expression qc and analysis

=head1 SYNOPSIS

RNA-Seq differential expression qc and analysis

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);

#use Bio::Deago;

extends 'Bio::Deago::CommandLine::Common';
with 'Bio::Deago::Config::Role';

has 'args'         					=> ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name'  					=> ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'         					=> ( is => 'rw', isa => 'Bool', 		default => 0 );
		
has '_error_message' 				=> ( is => 'rw', isa => 'Str' );
has 'verbose' 							=> ( is => 'rw', isa => 'Bool', 		default => 0 );

has 'convert_annotation'		=> ( is => 'rw', isa => 'Bool', 		default => 0 );
has 'annotation_delimiter'	=> ( is => 'rw', isa => 'Str', 			default => '\t' );
has 'build_config' 					=> ( is => 'rw', isa => 'Bool', 		default => 0 );
has 'config_file' 					=> ( is => 'rw', isa => 'Str', 			default => './deago.config' );
has 'markdown_file' 				=> ( is => 'rw', isa => 'Str', 			default => './deago_markdown.Rmd' );
has 'html_file' 						=> ( is => 'rw', isa => 'Str', 			default => './deago_markdown.html' );

sub BUILD {
	my ($self) = @_;

	my ( 	$help, $verbose, $convert_annotation, $build_config,
				$markdown_file, $html_file, $counts_directory, 
				$annotation_delimiter, $targets_file, $results_directory, 
				$annotation_file, $control, $qvalue, $count_type, 
				$count_delim, $count_column, $skip_lines, $gene_ids, 
				$keep_images, $qc_only, $go_analysis, $go_levels, $cmd_version );

	GetOptionsFromArray(
		$self->args,
		'v|verbose'           		=> \$verbose,
		'convert_ann=i'						=> \$convert_annotation,
		'ann_delim=s'							=> \$annotation_delimiter,
		'build_config=i'					=> \$build_config,
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

}

sub run {
	my ($self) = @_;

	if ( defined( $self->_error_message ) ) {
		print $self->_error_message . "\n";
		die $self->usage_text;
	}

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
  --convert_ann    convert annotation for use with deago (requires -a)
  --ann_delim      annotation file delimiter [\\t]
  --build_config   build config file from command line arguments (see configuration options)
  --config_file    config filename or output filename for config file if building [./deago.config]
  --markdown_file  output filename for markdown file [./deago_markdown.Rmd]
  --html_file      output filename for html file [./deago_markdown.html]
  -v               verbose output to STDOUT
  -w               print version and exit
  -h               print help message and exit

Configuration options (required):
  -c STR          directory containing count files (absolute path)
  -t STR          targets filename (absolute path)
  -r STR          results directory [current working directory]

 Configuration options (optional):
  -a STR          annotation filename (absolute path)
  -q NUM          qvalue (DESeq2) [0.05]
  --control       name of control condition (must be present in targets file)
  --keep_images   keep images used in report
  --qc            QC only
  --go            GO term enrichment
  --count_type    type of count file [expression|featurecounts]
  --count_column  number of column containing count values
  --skip_lines    number of lines to skip in count file
  --count_delim   count file delimiter
  --go_levels     BP only, MF only or all [BP|MF|all]

DEAGO takes in a configuration file containing key/value pairs [default: ./deago.config]. You can 
use your own configuration file with --config_file or specify parameters and let DEAGO build a 
configuration file with --build_config (and --config_file if you don't want the default 
configuration filename). For more information on configuration parameters run: build_deago_config -h.

DEAGO will then build an R markdown file (--markdown_file if you don't want the default markdown 
filename) from templates which utilize the companion DEAGO R package and the key/value pairs set 
out in the configuration file (see configuration information below). The R markdown will be 
processed and used to generate a HTML report (--html_file if you don't want the default html filename).

To use custom gene names and for GO term enrichment (--go) and annotation file must be provided 
(-a). Annotations downloaded from BioMart or those in a similar format can be converted for use 
with DEAGO.  For more information run: mart_to_deago -h.
         
USAGE
}


__PACKAGE__->meta->make_immutable;
no Moose;
1;