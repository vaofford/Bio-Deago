package Bio::Deago::CommandLine::BuildMarkdown;

# ABSTRACT: Build a master R Markdown file from templates

=head1 SYNOPSIS
Build a master R Markdown file from templates
=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);

use Bio::Deago::BuildMarkdown;

extends 'Bio::Deago::CommandLine::Common';

has 'args'         				=> ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name'  				=> ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'         				=> ( is => 'rw', isa => 'Bool', 		default => 0 );

has '_error_message' 			=> ( is => 'rw', isa => 'Str' );
has 'verbose' 						=> ( is => 'rw', isa => 'Bool', 		default => 0 );
has 'config_file' 				=> ( is => 'rw', isa => 'Str',			default => 'deago.config');
has 'output_file' 				=> ( is => 'rw', isa => 'Str', 			default=>'deago_markdown.Rmd');
has 'output_directory'		=> ( is => 'rw', isa => 'Str', 			default => '.' );
has 'output_filename'			=> ( is => 'rw', isa => 'Str', 			default => './deago_markdown.Rmd');

sub BUILD {
	my ($self) = @_;

	my ( $help, $verbose, $cmd_version, $config_file, $template_files, $output_directory, $output_file);

	GetOptionsFromArray(
		$self->args,
		'v|verbose'           		=> \$verbose,
		'o|output_file=s'     		=> \$output_file,
		'd|output_directory=s'		=> \$output_directory,
		'c|config_file=s'					=> \$config_file,
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

	$self->config_file( $config_file ) 												if ( defined($config_file) );
	$self->output_file( $output_file ) 												if ( defined($output_file) );
	$self->output_directory( $output_directory =~ s/\/$//r ) 	if ( defined($output_directory) );

	my $output_filename = $self->output_directory . "/" . $self->output_file;
	$self->output_filename($output_filename) if ( defined($output_filename) );
}

sub run {
	my ($self) = @_;

	if ( defined( $self->_error_message ) ) {
		print $self->_error_message . "\n";
		die $self->usage_text;
	}

	my $obj = Bio::Deago::BuildMarkdown->new(
            	config_file					=> $self->config_file,
            	output_filename			=> $self->output_filename
   					);
	$obj->build_markdown() or $self->logger->error( "Error: Could not build markdown file:" . $self->output_filename);
}

sub usage_text {
	my ($self) = @_;

	return <<USAGE;
Usage: build_markdown [options]
Takes in R markdown template files and builds a master markdown file using parameters in config file.  

Options: -c STR        DEAGO config file [deago.config]
         -o STR        output filename [deago_markdown.Rmd]
         -d STR        output directory for annnotation file [.]
         -v            verbose output to STDOUT
         -w            print version and exit
         -h            this help message

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;