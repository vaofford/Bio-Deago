package Bio::Deago::BuildMarkdown;

use Moose;
use File::Basename;
use Text::Template;
use Config::General;

use Bio::Deago::Exceptions;

#no warnings 'uninitialized';

has 'config_file' 		=> ( is => 'ro', isa => 'Str');
has 'output_filename'	=> ( is => 'ro', isa => 'Str', 			default => './deago_annotation.tsv');
has 'template_files'	=> ( is => 'ro', isa => 'ArrayRef');
has 'build_markdown'	=> ( is => 'ro', isa => 'Bool', 		lazy => 1, 	builder => '_build_markdown' );

sub BUILD {
	my ($self) = @_;
	
	Bio::Deago::Exceptions::FileNotFound->throw( error => "Error: Cannot find config file: " . $self->config . "\n") 
		unless ( -e $self->config_file );

	Bio::Deago::Exceptions::DirectoryNotFound->throw( error => "Error: Could not find output directory for markdown file: " . $self->output_filename . "\n" )
    unless ( defined($self->output_filename) && -d dirname($self->output_filename) ); 

}

sub _markdown_file_exists {
	my ($self) = @_;
	( defined($self->output_filename) && -e $self->output_filename ) ? return 1 : return 0;
}

sub _build_markdown {
	my ($self) = @_;
	
	return $self->_markdown_file_exists();
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;