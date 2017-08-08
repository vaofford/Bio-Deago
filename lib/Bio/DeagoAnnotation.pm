package Bio::DeagoAnnotation;

# ABSTRACT: Prepare deago annotations from BioMart TSV files

=head1 SYNOPSIS

Prepare deago annotations from BioMart TSV files.
   use Bio::DeagoAnnotation;
   
   my $obj = Bio::DeagoAnnotation->new(
     assembly_file    => $assembly_file,
     annotation_tool  => $annotation_tool,
     sample_name      => $lane_name,
     accession_number => $accession,
     dbdir            => $dbdir,
     tmp_directory    => $tmp_directory
   );
  $obj->annotate;

=cut

use Moose;



no Moose;
__PACKAGE__->meta->make_immutable;

1;