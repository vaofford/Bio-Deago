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
      '-a example_mart_annotation.tsv' => ['deago_annotation.tsv', 't/data/example_deago_annotation.tsv' ],
      '-h' => [ 'empty_file', 't/data/empty_file' ],
);

mock_execute_script_and_check_output( $script_name, \%scripts_and_expected_files );

unlink('deago_annotation.tsv');

done_testing();