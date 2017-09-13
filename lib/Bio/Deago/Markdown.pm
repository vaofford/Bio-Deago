package Bio::Deago::Markdown;

use Moose;
use Cwd qw(abs_path);
use File::Basename;
use Text::Template;

use Data::Dumper;

has 'config_file' 				=> ( is => 'ro', isa => 'Str', 							required => 1);
has 'config_hash' 				=> ( is => 'rw', isa => 'Config::General', 	required => 1);
has 'contrasts'						=> ( is => 'ro', isa => 'ArrayRef', 				required => 1);
has 'output_filename'			=> ( is => 'ro', isa => 'Str', 							default => './deago_markdown.Rmd' );
has 'template_files'			=> ( is => 'rw', isa => 'HashRef', 					lazy => 1, builder => '_get_template_files');
has 'template_directory'	=> ( is => 'rw', isa => 'Str', 							lazy => 1, builder => '_get_template_directory');
has 'replacement_values'	=> ( is => 'rw', isa => 'HashRef', 					lazy => 1, builder => '_get_replacement_values');

no Moose;

sub BUILD {
	my ($self) = @_;

	$self->template_directory;
	$self->template_files;
	$self->_templates_exist;
	$self->replacement_values;
	$self->_build_markdown;
}

sub _get_template_directory {
	my @module_dir_structure = File::Spec->splitdir( Cwd::abs_path(__FILE__) );
	my $module_directory = File::Spec->catdir( splice @module_dir_structure, 0, ($#module_dir_structure-3) );
	my $template_directory = $module_directory . "/markdown_templates";
	return $template_directory;
}

sub _get_template_files {
	my ($self) = @_;

	my %template_files = (
		'qc' => ['header.Rmd', 'config.Rmd'],
#		'contrast' => [''],
#		'go_analysis' => ['']
	);

	return \%template_files;
}

sub _templates_exist {
	my ($self) = @_;
	foreach my $template_array ( values %{$self->template_files} ) {
		foreach my $template_file (@$template_array) {
			$template_file = $self->template_directory . "/" . $template_file;
			Bio::Deago::Exceptions::FileNotFound->throw( error => "Error: Could not find template file: " . $template_file . "\n" )
    		unless ( -e $template_file && -f $template_file );
    }
	}

	return 1;
}

sub _get_replacement_values {
	my ($self) = @_;

	my $replacement_values = { qc => { 	config_filename => $self->config_file,
                       								fearsome => 'Larry Ellison' }
        										};     										

  return $replacement_values;
}

sub _build_markdown {
	my ($self) = @_;

	my @replaced_template_text = @{ $self->_replace_template_values( $self->template_files->{'qc'}, 'qc' ) };
	#print Dumper (@replaced_template_text);
}

sub _replace_template_values {
	my ($self) = $_[0];
	my @template_files = @{$_[1]};
	my $template_level = $_[2];
	my $replacement_values = $self->replacement_values->{$template_level};

	my @template_text;
	foreach my $template_file ( @template_files ) {
		my $template = Text::Template->new(TYPE => 'FILE',  SOURCE => $template_file);
		my $replaced_text = $template->fill_in(HASH => $replacement_values);
		push(@template_text, $replaced_text);
	}

	return \@template_text;
}

__PACKAGE__->meta->make_immutable;

1;