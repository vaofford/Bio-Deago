package Bio::Deago;

# ABSTRACT: RNA-Seq differential expression qc and analysis

=head1 SYNOPSIS

RNA-Seq differential expression qc and analysis

=cut

use Moose;
use Config::General;
use Log::Log4perl qw(:easy);

with 'Bio::Deago::Config::Role';

has 'config_hash'     => ( is => 'rw', isa => 'Config::General',  lazy => 1,  builder => 'read_config_file');
has 'config_file'     => ( is => 'rw', isa => 'Str',      default => './deago.config' );
has 'markdown_file'   => ( is => 'rw', isa => 'Str',      default => './deago_markdown.Rmd' );
has 'html_file'       => ( is => 'rw', isa => 'Str',      default => './deago_markdown.html' );

has 'verbose'         => ( is => 'rw', isa => 'Bool',     default => 0 );
has 'logger'          => ( is => 'ro', lazy => 1, builder => '_build_logger' );

sub _build_logger {
    my ($self) = @_;
    Log::Log4perl->easy_init( level => $ERROR );
    my $logger = get_logger();
    return $logger;
}

sub run {
   my ($self) = @_;

   #if ( $self->build_config ) {
      print "hi\n";
   #}
}

sub _mart_to_deago {
  my ($self) = @_;

}


no Moose;
__PACKAGE__->meta->make_immutable;

1;