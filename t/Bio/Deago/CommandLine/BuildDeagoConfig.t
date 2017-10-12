#!/usr/bin/env perl

use Moose;
use Data::Dumper;
use Cwd qw(abs_path getcwd); 
use Config::General;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';
with 'ConfigTestHelper';

$ENV{PATH} = join(':', ("$ENV{PATH}", abs_path('../bin')));

BEGIN {
    use Test::Most;
    use_ok('Bio::Deago::CommandLine::BuildDeagoConfig');
}

my $script_name = 'Bio::Deago::CommandLine::BuildDeagoConfig';
system('touch empty_file');

my $results_directory = make_results_directory();
die "Resuls directory path unsafe" if ( !defined($results_directory) || $results_directory eq "" || $results_directory !~ m/deago_test_results/ );

build_default_config_file( 'expected_default_deago.config', $results_directory );
build_qc_config_file( 'expected_qc_deago.config', $results_directory );
build_go_config_file( 'expected_go_deago.config', $results_directory );
build_keep_images_config_file( 'expected_keep_images_deago.config', $results_directory );
build_expression_config_file( 'expected_expression_deago.config', $results_directory );
build_featurecounts_config_file( 'expected_featurecounts_deago.config', $results_directory );

my %scripts_and_expected_files = (
      "-t t/data/example_targets.tsv -c t/data/example_counts -r $results_directory" 																							=> [ ['deago.config'], ['expected_default_deago.config'] ],
      "-t t/data/example_targets.tsv -c t/data/example_counts -r $results_directory --qc"																					=> [ ['deago.config'], ['expected_qc_deago.config'] ],
      "-t t/data/example_targets.tsv -c t/data/example_counts -r $results_directory -a t/data/example_deago_annotation.tsv --go" 	=> [ ['deago.config'], ['expected_go_deago.config'] ],
      "-t t/data/example_targets.tsv -c t/data/example_counts -r $results_directory --keep_images" 																=> [ ['deago.config'], ['expected_keep_images_deago.config'] ],
      "-t t/data/example_targets.tsv -c t/data/example_counts -r $results_directory --count_type featurecounts" 									=> [ ['deago.config'], ['expected_featurecounts_deago.config'] ],
      "-t t/data/example_targets.tsv -c t/data/example_counts -r $results_directory --count_type expression" 											=> [ ['deago.config'], ['expected_expression_deago.config'] ],
      '-h' => [ ['empty_file'], ['t/data/empty_file'] ],
);

stdout_should_have( $script_name, '', 																																					'Error: You need to provide' );
stdout_should_have( $script_name, '-c counts', 																																	'Error: You need to provide a targets file' );
stdout_should_have( $script_name, '-t targets.txt', 																														'Error: You need to provide a counts directory' );
stdout_should_have( $script_name, '-c counts -t targets.txt 0', 																								'Error: You need to remove trailing arguements' );
stderr_should_have( $script_name, '-c counts -t t/data/example_targets.tsv', 																		'Error: Could not write configuration file, options are not valid' );
stderr_should_have( $script_name, '-c t/data/counts -t targets.txt', 																						'Error: Could not write configuration file, options are not valid' );
stderr_should_have( $script_name, '-c t/data/counts -t t/data/example_targets.tsv -r t/data/results1', 					'Error: Could not write configuration file, options are not valid' );
stderr_should_have( $script_name, '-c t/data/example_counts -t t/data/example_targets.tsv -q 5', 								'Error: Could not write configuration file, options are not valid' );
stderr_should_have( $script_name, '-c t/data/example_counts -t t/data/example_targets.tsv --go', 								'Error: Could not write configuration file, options are not valid' );
stderr_should_have( $script_name, '-c t/data/example_counts -t t/data/example_targets.tsv -a annotation', 			'Error: Could not write configuration file, options are not valid' );
stderr_should_have( $script_name, '-c t/data/example_counts -t t/data/example_targets.tsv -a annotation --go', 	'Error: Could not write configuration file, options are not valid' );
stderr_should_have( $script_name, '-c t/data/example_counts -t t/data/example_targets.tsv --control notThere', 	'Error: Could not write configuration file, options are not valid' );
stdout_should_have( $script_name, '-c t/data/example_counts -t t/data/example_targets.tsv --count_type bad', 		'Error: count_type must be either featurecounts or expression' );


mock_execute_script_and_check_output( $script_name, \%scripts_and_expected_files );

unlink( 'expected_default_deago.config' );
unlink( 'expected_qc_deago.config' );
unlink( 'expected_go_deago.config' );
unlink( 'expected_keep_images_deago.config' );
unlink( 'expected_expression_deago.config' );
unlink( 'expected_featurecounts_deago.config' );
unlink( 'empty_file' );

done_testing();
