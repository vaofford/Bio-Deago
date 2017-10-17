#!/usr/bin/env perl

use strict;
use warnings;

use Moose;
use Test::Files;

BEGIN { unshift( @INC, './lib' ) }
BEGIN { unshift( @INC, './t/lib' ) }
with 'TestHelper';
with 'ConfigTestHelper';

BEGIN {
    use Test::Most;
    use Bio::Deago::Exceptions;
    use_ok('Bio::Deago::Targets');
}

my $output_directory = make_output_directory();
die "Output directory path unsafe" if ( !defined($output_directory) || $output_directory eq "" || $output_directory !~ m/deago_test_output/ );
unlink('expected_default_deago.config');

my $config_obj = build_default_config_file( 'expected_default_deago.config', $output_directory );

ok ( my $targets_obj = Bio::Deago::Targets->new(
  config_hash   => $config_obj,
) ,'initialise targets object');

ok( $targets_obj->targets, 'read in targets file' );
is( $targets_obj->target_is_valid, 1, 'validate targets' );

my $bad_targets_obj = $targets_obj;
$bad_targets_obj->targets->[0]->{'filename'} = "doesNotExist.csv";
throws_ok{
	$bad_targets_obj->_count_files_exist
} qr /Error: Cannot find count file:/, 'throws error when count file does not exist';

$bad_targets_obj->config_hash->{'config'}{'control'} = 'doesNotExist';
is( $bad_targets_obj->_control_present, 0, 'returns 0 when control not in targets file' );

$bad_targets_obj->targets->[0] = {'bad_column' => 'NA'};
is( $bad_targets_obj->_expected_columns_present, 0, 'returns 0 when expected columns not present' );

done_testing();