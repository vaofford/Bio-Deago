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
      '-a t/data/example_mart_annotation.tsv' => ['deago_annotation.tsv', 't/data/example_deago_annotation.tsv' ],
      '-a t/data/example_mart_annotation.tsv -o deago.out.tsv' => ['deago.out.tsv', 't/data/example_deago_annotation.tsv' ],
      '-h' => [ 'empty_file', 't/data/empty_file' ],
);

stdout_should_have($script_name,'', 'Error: You need to provide an annotation file');
stdout_should_have($script_name,'-a t/data/example_mart_annotation.tsv 0', 'Error: You need to remove trailing arguements');


throws_ok{
    Bio::Deago::MartToDeago->new(
        annotation_file	=> 't/data/example_mart_annotation.tsv',
        output_filename	=> 'non_existant_directory/deago_annotation.tsv')
} qr /Error: Could not find output directory for annotation file:/, 'non existant output directory should throw an error';

throws_ok{
    Bio::Deago::MartToDeago->new(
        annotation_file	=> 'non_existant_annotation.tsv')
} qr /Error: Cannot find annotation file:/, 'non existant annotation file should throw an error';

throws_ok{
    Bio::Deago::MartToDeago->new(
        annotation_file	=> 't/data/example_mart_annotation.tsv',
        separator 			=> ';')
} qr /Error: Could not collapse annotation, only found one column. Check separator./, 'non existant annotation file should throw an error';




#stderr_should_have($script_name,'-a t/data/example_mart_annotation.tsv -d non_existant_directory', 'Error: Could not find output directory for annotation file:');
#stderr_should_have($script_name,'-a non_existant_annotation.tsv', 'Couldn\'t open');
#stdout_should_have($script_name,'-a t/data/example_mart_annotation.tsv -s ";"', 'Error: Could not collapse annotation, only found one column. Check separator.');


mock_execute_script_and_check_output( $script_name, \%scripts_and_expected_files );

unlink('deago_annotation.tsv');

done_testing();