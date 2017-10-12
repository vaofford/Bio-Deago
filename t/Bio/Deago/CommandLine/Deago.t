#!/usr/bin/env perl

use Moose;
use Data::Dumper;
use Cwd qw(abs_path getcwd); 

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';
with 'ConfigTestHelper';

$ENV{PATH} = join(':', ("$ENV{PATH}", abs_path('../bin')));

BEGIN {
    use Test::Most;
    use_ok('Bio::Deago::CommandLine::Deago');
}

my $script_name = 'Bio::Deago::CommandLine::Deago';
system('touch empty_file');

my $results_directory = make_results_directory();
die "Resuls directory path unsafe" if ( !defined($results_directory) || $results_directory eq "" || $results_directory !~ m/deago_test_results/ );

build_default_config_file( 'expected_default_deago.config', $results_directory );
build_qc_config_file( 'expected_qc_deago.config', $results_directory );
build_go_config_file( 'expected_go_deago.config', $results_directory );
build_keep_images_config_file( 'expected_keep_images_deago.config', $results_directory );
build_expression_config_file( 'expected_expression_deago.config', $results_directory );
build_featurecounts_config_file( 'expected_featurecounts_deago.config', $results_directory );
build_mart_config_file( 'expected_mart_deago.config', $results_directory );

my $build_config_params = "--build_config -t t/data/example_targets.tsv -c t/data/example_counts -r $results_directory";

my %scripts_and_expected_files = (
#		'--config_file expected_default_deago.config'																			=> [ ['deago_markdown.Rmd','deago_markdown.html'] ],
#		'--config_file expected_default_deago.config --markdown_file t/deago_markdown.out.Rmd --html_file t/deago_markdown.out.html' => [ ['t/deago_markdown.out.Rmd','t/deago_markdown.out.html'] ],
#		"$build_config_params --convert_annotation -a t/data/example_mart_annotation.tsv"	=> [ ['deago.config', 't/data/example_mart_annotation_deago.tsv','deago_markdown.Rmd','deago_markdown.html'], 
#      																																										 ['expected_mart_deago.config', 't/data/example_deago_annotation.tsv'] ],
	'-h' => [ ['empty_file'], ['t/data/empty_file'] ],
);

stdout_should_have( $script_name, '',																		'Error: You need to provide or build a configuration file' );
stdout_should_have( $script_name, '--config_file badConfig', 						'Error: Configuration file does not exist' );
stdout_should_have( $script_name, '--build_config', 										'Error: You need to provide both a counts directory and targets file or a valid configuration file' );

#	$self->_error_message("Error: You need to remove trailing arguements");
#	$self->_error_message("Error: go_levels must be either BP, MF or all") if ( defined($go_levels) && $go_levels ne "BP" && $go_levels ne "MF" && $go_levels ne "all");
#	$self->_error_message("Error: count_type must be either featurecounts or expression") if ( defined($count_type) && $count_type ne "featurecounts" && $count_type ne "expression" && $count_type ne "unknown");
#	$self->_error_message("Error: Cannot generate markdown file as markdown file already exists: " . $self->markdown_file) if( defined($self->markdown_file) && -e $self->markdown_file );
#	$self->_error_message("Error: Cannot generate html file as html file already exists: " . $self->html_file) if( defined($self->html_file) && -e $self->html_file );
#	$self->_error_message("Error: You need to provide or build a configuration file") if( !$self->build_config && !defined($config_file) );
#	$self->_error_message("Error: Configuration file does not exist: " . $self->config_file) if( !$self->build_config && defined($config_file) && !-e $self->config_file );
#	$self->_error_message("Error: Cannot build configuration file as destination directory doesn't exist: " . $self->config_file ) if( $self->build_config && defined($self->config_file) && !-d dirname($self->config_file) );
#	$self->_error_message("Error: Cannot build configuration file as configuration file already exists: " . $self->config_file) if( $self->build_config && defined($self->config_file) && -e $self->config_file );
#	$self->_error_message("Error: --convert_annotation requires --build_config") if( $self->convert_annotation && !$self->build_config );
#	$self->_error_message("Error: Cannot convert annotation file as no annotation file given") if( $self->convert_annotation && !defined($self->annotation_file) );
#	$self->_error_message("Error: Cannot convert annotation file as annotation file does not exist: " . $self->annotation_file) if( $self->convert_annotation && defined($self->annotation_file) && !-e $self->annotation_file );

mock_execute_script_and_check_output( $script_name, \%scripts_and_expected_files );

unlink( 'expected_default_deago.config' );
unlink( 'expected_qc_deago.config' );
unlink( 'expected_go_deago.config' );
unlink( 'expected_mart_deago.config' );
unlink( 'expected_keep_images_deago.config' );
unlink( 'expected_expression_deago.config' );
unlink( 'expected_featurecounts_deago.config' );
unlink( 't/data/example_mart_annotation_deago.tsv' );
unlink( 'empty_file' );

print ("You will need to manually remove the results directory: " . $results_directory . "\n") if ( defined($results_directory) && -d $results_directory && $results_directory =~ m/deago_test_results/ );

done_testing();
