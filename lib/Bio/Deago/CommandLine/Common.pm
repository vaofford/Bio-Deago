package Bio::Deago::CommandLine::Common;

# ABSTRACT: Common command line settings
# Functionality has been borrowed from Roary (Andrew Page)

=head1 SYNOPSIS
Common command line settings
   extends 'Bio::Deago::CommandLine::Common';
=cut

use Moose;
use FindBin;
use Log::Log4perl qw(:easy);
use MooseX::Attribute::ENV;

has 'R'                 => ( is => 'ro', traits => ['ENV'], env_prefix => 'DEAGO');
has 'R_LIBS'            => ( is => 'ro', traits => ['ENV'], env_prefix => 'DEAGO');
has 'logger'            => ( is => 'ro', lazy => 1, builder => '_build_logger');
has 'version'           => ( is => 'rw', isa => 'Bool', default => 0 );

sub _build_logger
{
    my ($self) = @_;
    Log::Log4perl->easy_init($ERROR);
    my $logger = get_logger();
    return $logger;
}


sub run {
	my ($self) = @_;
}

sub usage_text {
    my ($self) = @_;
	return "Usage text";
}

sub _version {
    my ($self) = @_;
    return "x.y.z\n";
}

sub _set_R_environment {
    my ($self) = @_;

    $ENV{PATH} = $self->R . ":$ENV{PATH}" if ( defined $self->R );
    $ENV{R_LIBS} = $self->R_LIBS if ( defined $self->R_LIBS );

}

# add our included binaries to the END of the PATH
#before 'run' => sub {
#	my ($self) = @_;
#	my $OPSYS = $^O;
#	my $BINDIR = "$FindBin::RealBin/../binaries/$OPSYS";
#
#    for my $dir ($BINDIR, $FindBin::RealBin) {
#      if (-d $dir) {
#        $ENV{PATH} .= ":$dir";
#       }
#  }
#};

no Moose;
1;