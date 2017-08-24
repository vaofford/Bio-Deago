package Bio::Deago::BuildMarkdown;

use Moose;
use File::Basename;
use Text::Template;
use Config::General;

use Bio::Deago::Exceptions;
use Bio::Deago::Targets;

use Data::Dumper;

with 'Bio::Deago::Config::Role';

#no warnings 'uninitialized';

has 'config_file' 		=> ( is => 'ro', isa => 'Str');
has 'output_filename'	=> ( is => 'ro', isa => 'Str', 			default => './deago_annotation.tsv');
has 'template_files'	=> ( is => 'ro', isa => 'ArrayRef');
has 'build_markdown'	=> ( is => 'ro', isa => 'Bool', 		lazy => 1, 	builder => '_build_markdown' );

sub _build_markdown {
	my ($self) = @_;

	$self->_check_inputs();
	$self->_read_config();
	$self->_read_targets();

	#print Dumper ($self);
	
	return $self->_markdown_file_exists();
}

sub _check_inputs {
	my ($self) = @_;
	
	Bio::Deago::Exceptions::FileNotFound->throw( error => "Error: Cannot find config file: " . $self->config_file . "\n") 
		unless ( -e $self->config_file );

	Bio::Deago::Exceptions::DirectoryNotFound->throw( error => "Error: Could not find output directory for markdown file: " . $self->output_filename . "\n" )
    unless ( defined($self->output_filename) && -d dirname($self->output_filename) ); 
}

sub _read_config {
	my ($self) = @_;

	$self->read_config_file();

  Bio::Deago::Exceptions::ConfigNotValid->throw( error => "Error: Config is not valid: " . $self->config_file . "\n" )
  	unless ( $self->config_is_valid() ); 
}

sub _read_targets {
	my ($self) = @_;

	my $targets_obj = Bio::Deago::Targets->new( targets_file => $self->config_hash->{'config'}{'targets_file'} );

	print Dumper ($targets_obj);
}

sub _markdown_file_exists {
	my ($self) = @_;
	( defined($self->output_filename) && -e $self->output_filename ) ? return 1 : return 0;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;