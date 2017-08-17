#!/usr/bin/env perl
use strict;
use warnings;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }

BEGIN {
    use Test::Most tests => 1;
    use_ok('Bio::Deago');
}

my $obj ;

#ok( $obj = Bio::Bio::Deago->new(
#   input_file    => 'contigs.fa',
#   sample_name      => 'sample123',
#   dbdir            => '/tmp',
# ), 'initialise obj with all defaults');

#is($obj->_annotation_pipeline_class, 'Bio::AutomatedAnnotation::Prokka', 'Prokka should be loaded by default');
#is($obj->_contig_uniq_id,'sample123', 'Sample name should be used if no accession is passed in' );


#ok( $obj = Bio::AutomatedAnnotation->new(
#   assembly_file    => 'contigs.fa',
#   sample_name      => 'sample123',
#   dbdir            => '/tmp',
#   accession_number => 'Accession456'
# ), 'initialise obj an accession number');

#is($obj->_contig_uniq_id,'Accession456', 'Accession should be used if its provided' );
#ok($obj->_temp_directory_name,'Get a temp directory');

done_testing();