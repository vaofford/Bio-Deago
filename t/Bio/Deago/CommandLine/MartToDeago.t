#!/usr/bin/env perl

use Moose;
use Data::Dumper;
use Cwd;
use File::Slurper;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';

$ENV{PATH} .= ":../bin";

BEGIN {
    use Test::Most;
    use_ok('Bio::Deago::CommandLine::MartToDeago');
}

my $script_name = 'Bio::Deago::CommandLine::MartToDeago';
my $cwd         = getcwd();
system('touch empty_file');

my %scripts_and_expected_files = (
      '-a t/data/example_mart_annotation_short.tsv' => ['deago_annotation.tsv', 't/data/example_deago_annotation_short.tsv' ],
      '-a t/data/example_mart_annotation_short.tsv -o deago.out.tsv' => ['deago.out.tsv', 't/data/example_deago_annotation_short.tsv' ],
      '-h' => [ 'empty_file', 't/data/empty_file' ],
);

stdout_should_have( $script_name, '',                                                         'Error: You need to provide an annotation file');
stdout_should_have( $script_name, '-a t/data/example_mart_annotation_short.tsv 0',            'Error: You need to remove trailing arguements');
stdout_should_have( $script_name, '-a bad_annotation.tsv',                                    'Error: Cannot find annotation file' );
stdout_should_have( $script_name, '-a t/data/example_mart_annotation_short.tsv  -d badDir',   'Error: Could not find output directory for annotation file' );

mock_execute_script_and_check_output( $script_name, \%scripts_and_expected_files );

unlink('deago_annotation.tsv');

done_testing();