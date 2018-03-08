#!/usr/bin/env perl

use strict;
use warnings;

use Moose;
use Test::Files;
use Cwd qw(abs_path);
use File::Basename;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';
with 'ConfigTestHelper';

BEGIN {
    use Test::Most;
		use Bio::Deago::BuildDeagoMarkdown;
    use_ok('Bio::Deago::Markdown');
}

my $output_directory = make_output_directory();
die "Output directory path unsafe" if ( !defined($output_directory) || $output_directory eq "" || $output_directory !~ m/deago_test_output/ );
my $expected_markdown_file = $output_directory . "/deago_markdown.Rmd";

my $config_obj = build_go_config_file( 'expected_go_deago.config', $output_directory );

ok (my $build_markdown_obj = Bio::Deago::BuildDeagoMarkdown->new(
            	config_file		=> 'expected_go_deago.config',
), 'initialise build markdown object');

ok ( my $markdown_obj = Bio::Deago::Markdown->new(
	config_file	=> $build_markdown_obj->{'config_file'},
	config_hash 	=> $build_markdown_obj->{'config_hash'},
	num_samples	=> scalar( @{$build_markdown_obj->targets} ),
	contrasts 	=> $build_markdown_obj->contrasts,
	output_filename => $expected_markdown_file
) ,'initialise markdown object');
unlink($expected_markdown_file);

my $expected_markdown_template_path = abs_path(dirname(__FILE__) . "/../../../markdown_templates"); 
is( $markdown_obj->template_directory, $expected_markdown_template_path, 'get markdown template path' );

$markdown_obj->{'template_files'} = { 'bad_template' 		=> ['doesNotExist.Rmd'] };
throws_ok{
	$markdown_obj->_templates_exist
} qr /Error: Could not find template file:/, 'throw error if template file does not exist';

delete $markdown_obj->{'template_files'};
my %expected_template_files = (
		'qc' 		=> ['header.Rmd', 'config.Rmd', 'import.Rmd', 'deseq.Rmd', 'annotation.Rmd', 'qc_plots.Rmd'],
		'de_main' 	=> ['contrast_main.Rmd'],
		'de_venn' 	=> ['contrast_venn.Rmd'],
		'de_sections' 	=> ['contrast_section.Rmd'],
		'go_main' 	=> ['go_main.Rmd'],
		'go_sections' 	=> ['go_section.Rmd'],
		'session'	=> ['session.Rmd']
);
is_deeply( $markdown_obj->template_files, \%expected_template_files, 'get markdown template files' );
is( $markdown_obj->_templates_exist, 1, 'template files exist' );

my $test_qc_values = {	'rc_fig_width' 		=> 9, 'rc_fig_height' 	=> 7,
                  			'sd_fig_width' 		=> 9, 'sd_fig_height' 	=> 7,
	                      'pca_fig_width' 	=> 9, 'pca_fig_height' 	=> 7,
	                      'cd_fig_width' 		=> 9, 'cd_fig_height' 	=> 7,
	                      'dens_fig_width' 	=> 9, 'dens_fig_height' => 7,
	                      'disp_fig_width' 	=> 9, 'disp_fig_height' => 7
					            };
is_deeply( $markdown_obj->_define_qc_plot_values, $test_qc_values, 'get replacement qc plot values' );

is( $markdown_obj->_define_qc_plot_values->{'pca_fig_width'}, 9, 'samples < 10 replacement qc plot pca_fig_width 9' );

$markdown_obj->{'num_samples'} = 15;
is( $markdown_obj->_define_qc_plot_values->{'pca_fig_width'}, 10, 'samples between 10 and 20 replacement qc plot pca_fig_width 10' );

$markdown_obj->{'num_samples'} = 25;
is( $markdown_obj->_define_qc_plot_values->{'pca_fig_width'}, 11, 'samples between 20 and 30 replacement qc plot pca_fig_width 11' );

$markdown_obj->{'num_samples'} = 35;
is( $markdown_obj->_define_qc_plot_values->{'pca_fig_width'}, 12, 'samples between 30 and 40 replacement qc plot pca_fig_width 12' );

$markdown_obj->{'num_samples'} = 45;
is( $markdown_obj->_define_qc_plot_values->{'pca_fig_width'}, 14, 'samples >40 replacement qc plot pca_fig_width 14' );

is( $markdown_obj->_define_replacement_values->{'qc'}{'skip_lines'}, 0, 'get replacement values qc skip_lines set to 0' );
is( $markdown_obj->_define_replacement_values->{'de_main'}{'alpha'}, 0.05, 'get replacement values de_main alpha set to 0.05' );
is( $markdown_obj->_define_replacement_values->{'go_main'}{'alpha'}, 0.05, 'get replacement values go_main alpha set to 0.05' );

like( $markdown_obj->_get_contrast_text->[0], qr/[\#\# 0b_vs_0a]\d+[Points will be colored red if the adjusted p-value is less than 0.05]/, 'get replaced contrast text' );
like( $markdown_obj->_get_go_text->[1], qr/\#\#\#\# GO term enrichment - BP/, 'get go term enrichment text' );

like( $markdown_obj->_replace_template_values( $markdown_obj->template_files->{'qc'}, $markdown_obj->replacement_values->{'qc'} )->[2], qr/genes for each contrast \(padj < 0.05\)/, 'replace template values');

ok($markdown_obj->_write_markdown, 'write markdown to file');
ok( -e $expected_markdown_file, "Markdown file exists $expected_markdown_file" );

like( join("\n", @{$markdown_obj->_build_markdown}), qr/[\# Introduction]\d+[\#\# 0b_vs_0a]\w+[\#\#\#\# GO term enrichment - BP]/, 'get replaced contrast text' );

unlink('expected_go_deago.config');
unlink($expected_markdown_file);

done_testing();
