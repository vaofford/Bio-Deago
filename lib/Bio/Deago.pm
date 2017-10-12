package Bio::Deago;

# ABSTRACT: RNA-Seq differential expression qc and analysis

=head1 SYNOPSIS

RNA-Seq differential expression qc and analysis

=cut

use Moose;
use Config::General;
use File::Basename;
use Log::Log4perl qw(:easy);

use Data::Dumper;

with 'Bio::Deago::Config::Role';

has 'convert_annotation'    => ( is => 'rw', isa => 'Bool',     default => 0 );
has 'annotation_delimiter'  => ( is => 'rw', isa => 'Str',      default => '\t' );
has 'annotation_outfile'    => ( is => 'rw', isa => 'Str' );
has 'build_config'          => ( is => 'rw', isa => 'Bool',     default => 0 );
has 'config_hash'           => ( is => 'rw', isa => 'Config::General');
has 'config_file'           => ( is => 'rw', isa => 'Str',      default => './deago.config' );
has 'markdown_file'         => ( is => 'rw', isa => 'Str',      default => './deago_markdown.Rmd' );
has 'html_file'             => ( is => 'rw', isa => 'Str',      default => './deago_markdown.html' );

has 'verbose'               => ( is => 'rw', isa => 'Bool',     default => 0 );
has 'logger'                => ( is => 'ro', lazy => 1, builder => '_build_logger' );

sub run {
  my ($self) = @_;

  $self->annotation_outfile( $self->_build_annotation_outfile ) if ( $self->convert_annotation );
  $self->_convert_mart_to_deago if ( $self->convert_annotation );
  Bio::Deago::Exceptions::FileNotFound->throw( error => "Error: Could not find converted annotation file: " . $self->annotation_outfile . "\n" )
    if ( $self->convert_annotation && defined($self->annotation_outfile) && !-e $self->annotation_outfile );

  $self->_build_deago_config if ( $self->build_config );
  Bio::Deago::Exceptions::FileNotFound->throw( error => "Error: Could not find configuration file: " . $self->config_file . "\n" )
    unless ( defined($self->config_file) && -e $self->config_file );
 
  $self->_build_deago_markdown;
  Bio::Deago::Exceptions::FileNotFound->throw( error => "Error: Could not find markdown file: " . $self->markdown_file . "\n" )
    unless ( defined($self->markdown_file) && -e $self->markdown_file );
 
  $self->_deago_markdown_to_html;
  #Bio::Deago::Exceptions::FileNotFound->throw( error => "Error: Could not find HTML file: " . $self->html_file . "\n" )
  #  unless ( defined($self->html_file) && -e $self->html_file );
}

sub _build_annotation_outfile {
  my ($self) = @_;
  my ($annotation_filename, $annotation_directory, $annotation_extension) = fileparse( $self->config_hash->{'config'}->{'annotation_file'}, qr/\.[^.]*/ );
  my $annotation_outfile = $annotation_directory . $annotation_filename . "_deago" . $annotation_extension;

  Bio::Deago::Exceptions::FileExists->throw( error => "Error: Converted annotation file already exists: " . $annotation_outfile . "\n" )
    unless ( defined($annotation_outfile) && !-e $annotation_outfile );
  return $annotation_outfile;
}

sub _build_deago_config {
  my ($self) = @_;

  my $config_cmd_args;
  foreach my $config_parameter ( keys $self->config_hash->{'config'}  ) {
    my $cmd_arg;
    if ( $config_parameter eq "qc_only" || $config_parameter eq "go_analysis" || $config_parameter eq "keep_images" ) {
      if ( $self->config_hash->{'config'}->{$config_parameter} == 1 ) {
        $cmd_arg = " --qc" if ($config_parameter eq "qc_only");
        $cmd_arg = " --go" if ($config_parameter eq "go_analysis");
        $cmd_arg = " --keep_images" if ($config_parameter eq "keep_images");
      }
    } else {
      $cmd_arg = " --" . $config_parameter . " '" . $self->config_hash->{'config'}->{$config_parameter} . "'";
    }

    $config_cmd_args .= $cmd_arg if (defined $cmd_arg);
  }

  my $build_config_cmd = "build_deago_config " . $config_cmd_args;
  $self->logger->info("Building DEAGO config...");
  $self->_run_command($build_config_cmd);
  return 1;
}

sub _convert_mart_to_deago {
  my ($self) = @_;

  Bio::Deago::Exceptions::FileNotFound->throw( error => "Error: Annotation file does not exist: " . $self->config_hash->{'config'}->{'annotation_file'} . "\n" )
    unless ( defined($self->config_hash->{'config'}->{'annotation_file'}) && -e $self->config_hash->{'config'}->{'annotation_file'} );

  my $convert_annotation_cmd_args = join(" ", "-a", $self->config_hash->{'config'}->{'annotation_file'}, "-o", basename($self->annotation_outfile), "-d", dirname($self->annotation_outfile));
  my $convert_annotation_cmd = "mart_to_deago " . $convert_annotation_cmd_args;

  $self->logger->info("Converting annotation...");
  $self->_run_command($convert_annotation_cmd);
  return 1;
}

sub _build_deago_markdown {
  my ($self) = @_;

  Bio::Deago::Exceptions::FileNotFound->throw( error => "Error: Configuration file does not exist: " . $self->config_file . "\n" )
    unless ( defined($self->config_file) && -e $self->config_file );

  Bio::Deago::Exceptions::DirectoryNotFound->throw( error => "Error: Markdown output directory does not exist: " . dirname($self->markdown_file) . "\n" )
    unless ( defined($self->markdown_file) && -d dirname($self->markdown_file) );

  my $deago_markdown_cmd_args = join(" ", "-c", $self->config_file, "-o", basename($self->markdown_file), "-d", dirname($self->markdown_file) );
  my $deago_markdown_cmd = "build_deago_markdown " . $deago_markdown_cmd_args;

  $self->logger->info("Building markdown...");
  $self->_run_command($deago_markdown_cmd);
  return 1;
}

sub _deago_markdown_to_html {
  my ($self) = @_;

  Bio::Deago::Exceptions::FileNotFound->throw( error => "Error: Configuration file does not exist: " . $self->config_file . "\n" )
    unless ( defined($self->config_file) && -e $self->config_file );

  Bio::Deago::Exceptions::FileNotFound->throw( error => "Error: Markdown file does not exist: " . $self->markdown_file . "\n" )
    unless ( defined($self->markdown_file) && -e $self->markdown_file );

  Bio::Deago::Exceptions::DirectoryNotFound->throw( error => "Error: HTML output directory does not exist: " . dirname($self->html_file) . "\n" )
    unless ( defined($self->html_file) && -d dirname($self->html_file) );

  my $deago_html_cmd_args = join(" ", "-i", $self->markdown_file, "-o", basename($self->html_file), "-d", dirname($self->html_file) );
  my $deago_html_cmd = "deago_markdown_to_html " . $deago_html_cmd_args;

  $self->logger->info("Building HTML report...");
  $self->_run_command($deago_html_cmd);
  return 1;
}

sub _run_command {
  my ($self) = @_;
  my $command_to_run = $_[1];
  $self->logger->info( $command_to_run );
  system( $command_to_run );
  1;
}

sub _build_logger {
  my ($self) = @_;
  my $level = $ERROR;
  if( $self->verbose ){
     $level = $DEBUG;
   }
  Log::Log4perl->easy_init($level);
  my $logger = get_logger();
  return $logger;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;