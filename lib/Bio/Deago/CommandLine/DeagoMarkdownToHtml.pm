package Bio::Deago::CommandLine::DeagoMarkdownToHtml;

# ABSTRACT: Convert an R Markdown file into HTML report

=head1 SYNOPSIS
Convert an R Markdown file into HTML report
=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);

use Bio::Deago::DeagoMarkdownToHtml;

extends 'Bio::Deago::CommandLine::Common';

has 'args'         				=> ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name'  				=> ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'         				=> ( is => 'rw', isa => 'Bool', 		default => 0 );

has '_error_message' 			=> ( is => 'rw', isa => 'Str' );
has 'verbose' 						=> ( is => 'rw', isa => 'Bool', 		default => 0 );
has 'markdown_file' 			=> ( is => 'rw', isa => 'Str',			default => './deago_markdown.Rmd');
has 'output_directory'		=> ( is => 'rw', isa => 'Str', 			default => '.' );
has 'output_file' 				=> ( is => 'rw', isa => 'Str',			default => 'deago_markdown.html');
has 'output_filename'			=> ( is => 'rw', isa => 'Str', 			default => './deago_markdown.html');

sub BUILD {
	my ($self) = @_;

	my ( $help, $verbose, $cmd_version, $markdown_file, $output_directory, $output_file);

	GetOptionsFromArray(
		$self->args,
		'v|verbose'           		=> \$verbose,
		'o|output_file=s'     		=> \$output_file,
		'd|output_directory=s'		=> \$output_directory,
		'i|markdown_file=s'				=> \$markdown_file,
		'w|version'             	=> \$cmd_version,
		'h|help'                	=> \$help
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

	if( !defined($markdown_file) ) {
		$self->_error_message("Error: You need to provide a markdown file");
	} else {
		$self->markdown_file( $markdown_file );
	}
	$self->_error_message("Error: Cannot find markdown file: " . $self->markdown_file) if ( !-e $self->markdown_file && defined($markdown_file) );

	$self->output_file( $output_file ) 												if ( defined($output_file) );
	$self->output_directory( $output_directory =~ s/\/$//r ) 	if ( defined($output_directory) );
	$self->_error_message("Error: Could not find output directory for html file: " . $self->output_directory) if ( !-d $self->output_directory && defined($output_directory) );

	my $output_filename = $self->output_directory . "/" . $self->output_file;
	$self->output_filename($output_filename) if ( defined($output_filename) );
}

sub run {
	my ($self) = @_;

	if ( defined( $self->_error_message ) ) {
		print $self->_error_message . "\n";
		die $self->usage_text;
	}

#	
	my $html_obj = Bio::Deago::DeagoMarkdownToHtml->new(
            	markdown_file		=> $self->markdown_file,
            	html_file				=> $self->output_filename,
   					);
	
	$self->logger->info("R logs will be written to:" . $html_obj->rlog);
	$html_obj->run();
}

sub usage_text {
	my ($self) = @_;

	return <<USAGE;
Usage: deago_markdown_to_html [options]
Takes in a R markdown file and builds a HTML report.  

Options: -i STR        DEAGO markdown file [./deago_markdown.Rmd]
         -o STR        output filename for html file [deago_markdown.html]
         -d STR        output directory for html file [.]
         -v            verbose output to STDOUT
         -w            print version and exit
         -h            this help message

Processes an R markdown file to generate a HTML report.

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;