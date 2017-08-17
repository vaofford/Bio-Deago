#!/usr/bin/env perl

use Moose;
use Data::Dumper;
use Cwd;
use Config::General;


BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';

$ENV{PATH} .= ":../bin";

BEGIN {
    use Test::Most;
    use_ok('Bio::Deago::CommandLine::BuildDeagoConfig');
}

my $script_name = 'Bio::Deago::CommandLine::BuildDeagoConfig';
my $cwd         = getcwd();
system('touch empty_file');

my %default_config = 	(	'counts_directory'	=> 't/data/example_counts',
												'go_analysis'				=> 0,
												'keep_images'				=> 0,
												'qc_only'						=> 0,
												'qvalue'						=> 0.05,
												'results_directory'	=> $cwd,
												'targets_file'			=> 't/data/example_targets.tsv'
											);

build_test_config_file( 'expected_default_deago.config', \%default_config );

my %non_default_config = 	(	'counts_directory'	=> 't/data/example_counts',
														'go_analysis'				=> 1,
														'keep_images'				=> 1,
														'qc_only'						=> 1,
														'qvalue'						=> 0.01,
														'results_directory'	=> 't/data',
														'targets_file'			=> 't/data/example_targets.tsv',
														'annotation_file'		=> 't/data/example_annotation.tsv'
													);

build_test_config_file( 'expected_non_default_deago.config', \%default_config );

my %scripts_and_expected_files = (
      '-t t/data/example_targets.tsv -c t/data/example_counts' => ['deago.config', 'expected_default_deago.config' ],
      '-t t/data/example_targets.tsv -c t/data/example_counts -r t/data -a t/data/example_annotation.tsv -q 0.01 --go --qc --keep_images' => ['deago.config', 'expected_non_default_deago.config' ],
      '-h' => [ 'empty_file', 't/data/empty_file' ],
);

stdout_should_have($script_name,'', 'Error: You need to provide');
stdout_should_have($script_name,'-c counts', 'Error: You need to provide a targets file');
stdout_should_have($script_name,'-t targets.txt', 'Error: You need to provide a counts directory');
stdout_should_have($script_name,'-c counts -t targets.txt 0', 'Error: You need to remove trailing arguements');
stderr_should_have($script_name,'-c counts -t targets.txt', 'Error: Could not write config file, options are not valid');

stderr_should_have($script_name,'-c t/data/example_counts -t t/data/example_targets.tsv -q 5', 'Error: Could not write config file, options are not valid');
stderr_should_have($script_name,'-c t/data/example_counts -t t/data/example_targets.tsv --go', 'Error: Could not write config file, options are not valid');
stderr_should_have($script_name,'-c t/data/example_counts -t t/data/example_targets.tsv -a annotation', 'Error: Could not write config file, options are not valid');
stderr_should_have($script_name,'-c t/data/example_counts -t t/data/example_targets.tsv -a annotation --go', 'Error: Could not write config file, options are not valid');

mock_execute_script_and_check_output( $script_name, \%scripts_and_expected_files );

unlink('expected_default_deago.config');
unlink('expected_non_default_deago.config');

done_testing();
