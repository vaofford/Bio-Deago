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
		use_ok('Bio::Deago::BuildDeagoConfig');
}

my $output_directory = make_output_directory();
die "Output directory path unsafe" if ( !defined($output_directory) || $output_directory eq "" || $output_directory !~ m/deago_test_output/ );

my $config_obj = build_default_config_file( 'expected_default_deago.config', $output_directory );

ok ( my $build_config_obj = Bio::Deago::BuildDeagoConfig->new(
  	config  		=> $config_obj,
  	config_file => "badDirectory/willNotExist.config"
) ,'initialise build configuration object');

throws_ok{
	$build_config_obj->_config_directory_exists
} qr /Error: Could not find output directory for configuration file:/, 'throws error when configuration output directory does not exist';

throws_ok{
	$build_config_obj->_build_config_file
} qr /Error: Could not find output directory for configuration file:/, 'throws build error when configuration output directory does not exist';

throws_ok{
	$build_config_obj->_config_file_exists
} qr /Error: Could not find configuration file:/, 'throws error when configuration output file does not exist';

$build_config_obj->{config_file} = "./deago.config";
is($build_config_obj->_config_directory_exists, 1, 'configuration output directory exists');
is($build_config_obj->_build_config_file, 1, 'can build configuration file');
is($build_config_obj->_config_file_exists, 1, 'configuration output file exists');
compare_ok('deago.config','expected_default_deago.config','observed configuration file matches expected');

unlink('deago.config');
unlink('expected_default_deago.config');

done_testing();