package Bio::Deago::CommandLine::MartToDeago;

# ABSTRACT: Convert a tab-delimited annotation file (e.g. from BioMart) for use with deago

=head1 SYNOPSIS
Convert a tab-delimited annotation file (e.g. from BioMart) for use with deago
=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);

use Bio::Deago::MartToDeago;

extends 'Bio::Deago::CommandLine::Common';

has 'args'         			=> ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name'  			=> ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'         			=> ( is => 'rw', isa => 'Bool', 		default => 0 );

has '_error_message' 		=> ( is => 'rw', isa => 'Str' );
has 'verbose' 					=> ( is => 'rw', isa => 'Bool', 		default => 0 );
has 'annotation_file' 	=> ( is => 'rw', isa => 'Str');
has 'separator' 				=> ( is => 'rw', isa => 'Str', 			default => "\t");
has 'output_file' 			=> ( is => 'rw', isa => 'Str', 			default=>'deago_annotation.tsv');
has 'output_directory'	=> ( is => 'rw', isa => 'Str', 			default => '.' );
has 'output_filename'		=> ( is => 'rw', isa => 'Str', 			default => './deago_annotation.tsv');

sub BUILD {
	my ($self) = @_;

	my ( $help, $verbose, $cmd_version, $output_file, $output_directory, $annotation_file, $separator );

	GetOptionsFromArray(
		$self->args,
		'v|verbose'           	=> \$verbose,
		'o|output_file=s'     	=> \$output_file,
		'd|output_directory=s'	=> \$output_directory,
		'a|annotation_file=s'		=> \$annotation_file,
		's|separator=s'					=> \$separator,
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

	if( !defined($annotation_file) ) {
		$self->_error_message("Error: You need to provide an annotation file");
	} else {
		$self->annotation_file($annotation_file);
	}
	$self->_error_message("Error: Cannot find annotation file: " . $self->annotation_file) if ( !-e $self->annotation_file && defined($annotation_file) );

	$self->separator( $separator ) 														if ( defined($separator) );
	$self->output_file( $output_file ) 												if ( defined($output_file) );
	$self->output_directory( $output_directory =~ s/\/$//r ) 	if ( defined($output_directory) );
	$self->_error_message("Error: Could not find output directory for annotation file: " . $self->output_directory) if ( !-d $self->output_directory && defined($output_directory) );

	my $output_filename = $self->output_directory . "/" . $self->output_file;
	$self->output_filename($output_filename) if ( defined($output_filename) );
}

sub run {
	my ($self) = @_;

	if ( defined( $self->_error_message ) ) {
		print $self->_error_message . "\n";
		die $self->usage_text;
	}

	my $obj = Bio::Deago::MartToDeago->new(
            	annotation_file	=> $self->annotation_file,
            	output_filename	=> $self->output_filename,
            	separator				=> $self->separator
   					);
	$obj->convert_annotation() or $self->logger->error( "Error: Could not write annotation file:" . $self->annotation_file);
}

sub usage_text {
	my ($self) = @_;

	return <<USAGE;
Usage: mart_to_deago [options]
Converts a tab-delimited annotation file (e.g. from BioMart) for use with DEAGO

Options: -a STR        annotation file
         -o STR        output filename for deago annotation file [deago_annotation.tsv]
         -d STR        output directory for deago annnotation file [.]
         -s STR        input file field separator [\\t]
         -v            verbose output to STDOUT
         -w            print version and exit
         -h            this help message

Description:

Converts a tab-delimited file (e.g. from BioMart) for use with the RNA-Seq expression 
analysis pipeline (DEAGO).  Output is a tab delimited file where each row represents 
a unique value from the first column (assumed to be the gene id for DEAGO). Remaining 
column values from rows sharing the same unique identifier are collapsed and 
semi-colon separated (;).

# Example for human
 1) Go to http://www.ensembl.org/biomart/martview
 2) Select dataset e.g. Ensembl Genes 87
 3) Select Gene ID, Associated Gene Name and GO Term Accession from Attributes
 4) Download as TSV
 5) Run mart_to_deago -a <annotation.tsv>

Example input file contents:

Gene stable ID	Gene	GO term accession
Smp_000080	gene1	GO:0016020
Smp_000080	gene2	GO:0016021
Smp_000080	gene2	GO:0005515
Smp_000090	gene1	
Smp_000100	gene1	GO:0051015
Smp_000100	gene1	GO:0005515
Smp_000110              GO:0005515

Example output file contents:

Gene stable ID	Gene	GO term accession
Smp_000080	gene1;gene2	GO:0016020;GO:0005515;GO:0016021
Smp_000090	gene1
Smp_000100	gene1	GO:0051015;GO:0005515
Smp_000110		GO:0005515

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;