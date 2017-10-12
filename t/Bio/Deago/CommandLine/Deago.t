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
my $cwd         = getcwd();
system('touch empty_file');

build_default_config_file( 'expected_default_deago.config' );
#my $markdown_cmd = "build_deago_markdown -c expected_default_deago.config";
#system($markdown_cmd);

my %scripts_and_expected_files = (
      '--config_file expected_default_deago.config'													=> [ ['deago_markdown.html'] ],
#      '-i expected_default_deago.config -o deago_markdown.out.html'				=> [ 'deago_markdown.out.html' ],
#      '-i expected_default_deago.config -o deago_markdown.out.html -d t'	=> [ 't/deago_markdown.out.html' ],
#      '-h' => [ 'empty_file', 't/data/empty_file' ],
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
#unlink( 'deago_markdown.Rmd' );
unlink( 'empty_file' );

done_testing();