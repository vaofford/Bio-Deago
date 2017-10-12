package ConfigTestHelper;

# ABSTRACT: Test helper with config parameters

=head1 SYNOPSIS
Config test helper
=cut

use Moose::Role;
use Config::General;
use Cwd qw(getcwd abs_path); 

my $cwd = getcwd();
my $counts_directory = abs_path('t/data/example_counts');
my $targets_file = abs_path('t/data/example_targets.tsv');
my $annotation_file = abs_path('t/data/example_deago_annotation.tsv');

sub build_test_config_file {
    my ( $config_file, $config_hash ) = @_;

    my $config = Config::General->new(  -ConfigHash         => $config_hash, 
                                        -AllowMultiOptions  => 'no',
                                        -SaveSorted         => 'yes',
                                        -StoreDelimiter     => "\t",
                                        -NoEscape           => 'yes'
                                      );
    $config->save_file($config_file);
}

sub build_default_config_file {
    my $config_file = $_[0];
    my %config =    (   'count_column'      => 5,
                        'count_delim'       => ",",
                        'counts_directory'  => $counts_directory,
                        'count_type'        => 'unknown',
                        'gene_ids'          => 'GeneID',
                        'go_analysis'       => 0,
                        'go_levels'         => 'all',
                        'keep_images'       => 0,
                        'qc_only'           => 0,
                        'qvalue'            => 0.05,
                        'results_directory' => $cwd,
                        'skip_lines'        => 0,
                        'targets_file'      => $targets_file
                    );

    build_test_config_file( $config_file, \%config );
}

sub build_keep_images_config_file {
    my $config_file = $_[0];
    my %config =    (   'count_column'      => 5,
                        'count_delim'       => ",",
                        'counts_directory'  => $counts_directory,
                        'count_type'        => 'unknown',
                        'gene_ids'          => 'GeneID',
                        'go_analysis'       => 0,
                        'go_levels'         => 'all',
                        'keep_images'       => 1,
                        'qc_only'           => 0,
                        'qvalue'            => 0.05,
                        'results_directory' => $cwd,
                        'skip_lines'        => 0,
                        'targets_file'      => $targets_file
                    );

    build_test_config_file( $config_file, \%config );
}

sub build_qc_config_file {
    my $config_file = $_[0];
    my %config =    (   'count_column'      => 5,
                        'count_delim'       => ",",
                        'counts_directory'  => $counts_directory,
                        'count_type'        => 'unknown',
                        'gene_ids'          => 'GeneID',
                        'go_analysis'       => 0,
                        'go_levels'         => 'all',
                        'keep_images'       => 0,
                        'qc_only'           => 1,
                        'qvalue'            => 0.05,
                        'results_directory' => $cwd,
                        'skip_lines'        => 0,
                        'targets_file'      => $targets_file
                    );

    build_test_config_file( $config_file, \%config );
}

sub build_go_config_file {
    my $config_file = $_[0];
    my %config =    (   'count_column'      => 5,
                        'count_delim'       => ",",
                        'counts_directory'  => $counts_directory,
                        'count_type'        => 'unknown',
                        'gene_ids'          => 'GeneID',
                        'go_analysis'       => 1,
                        'go_levels'         => 'all',
                        'keep_images'       => 0,
                        'qc_only'           => 0,
                        'qvalue'            => 0.05,
                        'results_directory' => $cwd,
                        'skip_lines'        => 0,
                        'targets_file'      => $targets_file,
                        'annotation_file'   => $annotation_file
                    );

    build_test_config_file( $config_file, \%config );
}

sub build_expression_config_file {
    my $config_file = $_[0];
    my %config =    (   'count_column'      => 5,
                        'count_delim'       => ",",
                        'counts_directory'  => $counts_directory,
                        'count_type'        => 'expression',
                        'gene_ids'          => 'GeneID',
                        'go_analysis'       => 0,
                        'go_levels'         => 'all',
                        'keep_images'       => 0,
                        'qc_only'           => 0,
                        'qvalue'            => 0.05,
                        'results_directory' => $cwd,
                        'skip_lines'        => 0,
                        'targets_file'      => $targets_file
                    );

    build_test_config_file( $config_file, \%config );
}

sub build_featurecounts_config_file {
    my $config_file = $_[0];
    my %config =    (   'count_column'      => 7,
                        'count_delim'       => "\\t",
                        'counts_directory'  => $counts_directory,
                        'count_type'        => 'featurecounts',
                        'gene_ids'          => 'Geneid',
                        'go_analysis'       => 0,
                        'go_levels'         => 'all',
                        'keep_images'       => 0,
                        'qc_only'           => 0,
                        'qvalue'            => 0.05,
                        'results_directory' => $cwd,
                        'skip_lines'        => 1,
                        'targets_file'      => $targets_file
                    );

    build_test_config_file( $config_file, \%config );
}

no Moose;
1;
