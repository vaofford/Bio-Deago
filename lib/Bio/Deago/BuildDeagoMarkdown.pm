package Bio::Deago::BuildDeagoMarkdown;

use Moose;
use File::Basename;
use Text::Template;
use Config::General;
use List::MoreUtils qw(uniq);

use Bio::Deago::Exceptions;
use Bio::Deago::Targets;
use Bio::Deago::Markdown;

use Data::Dumper;

with 'Bio::Deago::Config::Role';

has 'config_file' 		=> ( is => 'ro', isa => 'Str', required => 1);
has 'output_filename'	=> ( is => 'ro', isa => 'Str', 							default => './deago_markdown.Rmd' );
has 'template_files' 	=> ( is => 'rw', isa => 'ArrayRef');
has 'config_hash' 		=> ( is => 'rw', isa => 'Config::General', 	lazy => 1, 	builder => 'read_config_file');
has 'targets'					=> ( is => 'ro', isa => 'ArrayRef', 				lazy => 1, 	builder => '_read_targets' );
has 'contrasts'				=> ( is => 'ro', isa => 'ArrayRef', 				lazy => 1, 	builder => '_get_contrasts' );
has 'build_markdown'	=> ( is => 'ro', isa => 'Bool', 						lazy => 1, 	builder => '_build_markdown' );

sub _build_markdown {
	my ($self) = @_;

	$self->_output_directory_exists;
	$self->config_hash;
	$self->targets;
	$self->contrasts;
	$self->_build_markdown_from_templates();

	#print Dumper($self);
	
	return $self->_markdown_file_exists();
}

sub _output_directory_exists {
	my ($self) = @_;

	Bio::Deago::Exceptions::DirectoryNotFound->throw( error => "Error: Could not find output directory for markdown file: " . $self->output_filename . "\n" )
    unless ( defined($self->output_filename) && -d dirname($self->output_filename) ); 
}

sub _read_targets {
	my ($self) = @_;

	my $targets_obj = Bio::Deago::Targets->new( config_hash => $self->config_hash );

	Bio::Deago::Exceptions::TargetsNotValid->throw( error => "Error: Target file is not valid: " . $self->config_file . "\n" )
  	unless ( $targets_obj->target_is_valid ); 

  return $targets_obj->targets;
}

sub _get_contrasts {
	my ($self) = @_;

	#my $targets = $self->_read_targets;

	my $column_to_check = 'condition';
	my @conditions = map { $_->{$column_to_check} } @{$self->targets};
	$_ = lc for @conditions;
	my @sorted_conditions = sort { $a cmp $b } uniq(@conditions);

	if ( defined $self->config_hash->{'config'}{'control'} ) {
		my $control = $self->config_hash->{'config'}{'control'};
		my @control_sorted_conditions = grep {!/^$control$/} @sorted_conditions;
		unshift( @control_sorted_conditions, $control);
		@sorted_conditions =  @control_sorted_conditions;
	}
	
	my @contrasts;
	foreach my $i (0..$#sorted_conditions) {
	   foreach my $j (0..$#sorted_conditions) {
	   		my $condition = $sorted_conditions[$i] . "_vs_" . $sorted_conditions[$j];
	      push(@contrasts, $condition) unless ($i <= $j);
	   }
	}

	return \@contrasts;
}

sub _build_markdown_from_templates {
	my ($self) = @_;

	Bio::Deago::Markdown->new( 	config_file 		=> $self->config_file,
															config_hash 		=> $self->config_hash,
															num_samples			=> scalar( @{$self->targets} ),
															contrasts 			=> $self->contrasts,
															output_filename	=> $self->output_filename
														);
}

sub _markdown_file_exists {
	my ($self) = @_;
	( defined($self->output_filename) && -e $self->output_filename ) ? return 1 : return 0;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;