#!/usr/bin/env perl

use Moose;
use Cwd qw(abs_path getcwd); 

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';
with 'ConfigTestHelper';

$ENV{PATH} = join(':', ("$ENV{PATH}", abs_path('../bin')));

BEGIN {
    use Test::Most;
    use_ok('Bio::Deago::CommandLine::DeagoMarkdownToHtml');
}

my $script_name = 'Bio::Deago::CommandLine::DeagoMarkdownToHtml';
system('touch empty_file');

my $output_directory = make_output_directory();
die "Output directory path unsafe" if ( !defined($output_directory) || $output_directory eq "" || $output_directory !~ m/deago_test_output/ );

build_default_config_file( 'expected_default_deago.config', $output_directory );
my $markdown_cmd = "build_deago_markdown -c expected_default_deago.config";
system($markdown_cmd);

my %scripts_and_expected_files = (
      '-i expected_default_deago.config'																	=> [ ['deago_markdown.Rmd'] ],
      '-i expected_default_deago.config -o deago_markdown.out.html'				=> [ ['deago_markdown.out.html'] ],
      '-i expected_default_deago.config -o deago_markdown.out.html -d t'	=> [ ['t/deago_markdown.out.html'] ],
      '-h' => [ ['empty_file'], ['t/data/empty_file'] ],
);

stdout_should_have( $script_name, '',																		'Error: You need to provide a markdown file' );
stdout_should_have( $script_name, '-o deago_markdown.out.html', 				'Error: You need to provide a markdown file' );
stdout_should_have( $script_name, '-i bad_markdown', 										'Error: Cannot find markdown file' );
stdout_should_have( $script_name, '-c deago_markdown.Rmd  -d badDir', 	'Error: Could not find output directory for html file' );

mock_execute_script_and_check_output( $script_name, \%scripts_and_expected_files );

unlink( 'expected_default_deago.config' );
unlink( 'deago_markdown.Rmd' );
unlink( 'empty_file' );

done_testing();