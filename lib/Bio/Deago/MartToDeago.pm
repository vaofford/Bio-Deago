package Bio::Deago::MartToDeago;

use Moose;
use File::Basename;
use File::Slurper qw(read_lines write_text);
use List::MoreUtils qw(uniq);

use Bio::Deago::Exceptions;

no warnings 'uninitialized';

has 'annotation_file' 		=> ( is => 'ro', isa => 'Str', 			required => 1);
has 'output_filename'			=> ( is => 'ro', isa => 'Str', 			default => "./deago_annotation.tsv");
has 'separator'						=> ( is => 'ro', isa => 'Str', 			default => "\t");
has 'annotations'					=> ( is => 'rw', isa => 'ArrayRef', lazy => 1, 	builder => '_read_annotation');
has 'convert_annotation'	=> ( is => 'ro', isa => 'Bool', 		lazy => 1, 	builder => '_convert_annotation' );

sub BUILD {
	my ($self) = @_;
	
	Bio::Deago::Exceptions::FileNotFound->throw( error => "Error: Cannot find annotation file: " . $self->annotation_file . "\n") 
		unless ( -e $self->annotation_file );

	Bio::Deago::Exceptions::DirectoryNotFound->throw( error => "Error: Could not find output directory for annotation file: " . $self->output_filename . "\n" )
    unless ( defined($self->output_filename) && -d dirname($self->output_filename) ); 

  $self->annotations();
  my $separator = $self->separator;
  die "Error: Could not collapse annotation, only found one column. Check separator.\n"
  unless ( scalar(split(/$separator/, $self->annotations->[0])) > 1 );
  
}

sub _read_annotation {
	my ($self) = @_;

	my @annotations = read_lines($self->annotation_file);
	$self->annotations(\@annotations) if ( @annotations );
}

sub _annotation_file_exists {
	my ($self) = @_;
	( defined($self->output_filename) && -e $self->output_filename ) ? return 1 : return 0;
}

sub _collapse_annotation {
	my ($self) = @_;
	my $separator = $self->separator;
	my (%split_annotations, @collapsed_annotations);

	my @annotations = @{ $self->annotations };
	foreach (@annotations)
	{
		# Necessary to capture empty fields
		my ($identifier, @data) = map { $_ eq '' ? 'undefined_value' : $_ } split /$separator/, $_, -1; 

		for (my $i=0; $i < scalar(@data); $i++)
		{
			if (!exists $split_annotations{$identifier}{$i}{$data[$i]})
			{
				$split_annotations{$identifier}{$i}{$data[$i]} = 1;
			}
		}
	}

	foreach my $identifier (sort keys %split_annotations)
	{
		my $line=$identifier;
		foreach my $column (sort keys %{$split_annotations{$identifier}})
		{
			 $line .= "\t" . join(";", sort keys %{$split_annotations{$identifier}{$column}});
		}

		$line =~ s/undefined_value//g;

		push(@collapsed_annotations, $line);
			
	}

	my $annotation = join("\n", @collapsed_annotations);

	return $annotation;
}

sub _convert_annotation {
	my ($self) = @_;

	my $annotation = $self->_collapse_annotation();

	write_text($self->output_filename, $annotation);
	
	return $self->_annotation_file_exists();
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;