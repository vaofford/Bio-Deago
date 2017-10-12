package Bio::Deago::DeagoMarkdownToHtml;

use Moose;
use File::Basename;

has 'markdown_file'		=> ( is => 'ro', isa => 'Str', 	default => "./deago_markdown.Rmd");
has 'html_file'				=> ( is => 'ro', isa => 'Str', 	default => "./deago_markdown.html");
has 'rlog'						=> ( is => 'ro', isa => 'Str', 	default =>'./deago.rlog');

sub _markdown_file_exists {
	my ($self) = @_;
	Bio::Deago::Exceptions::FileNotFound->throw( error => "Error: Could not find R markdown file: " . $self->markdown_file . "\n" )
    unless ( defined($self->markdown_file) && -e dirname($self->markdown_file) );	
  return 1;
}

sub _html_file_exists {
	my ($self) = @_;
	Bio::Deago::Exceptions::FileNotFound->throw( error => "Error: Could not find HTML report: " . $self->html_file . "\n" )
    unless ( defined($self->html_file) && -e dirname($self->html_file) );	
  return 1;
}

sub run {
	my ($self) = @_;
	$self->_markdown_file_exists;

	my $cmd_to_run = "Rscript -e 'library(markdown)' -e 'rmarkdown::render(\"" . $self->markdown_file . "\", output_file=\"" . basename($self->html_file) . "\", output_dir=\"". dirname($self->html_file) . "\")'";
	$cmd_to_run .= " > " . $self->rlog . " 2>&1";
	system($cmd_to_run);

	$self->_html_file_exists;
	return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;