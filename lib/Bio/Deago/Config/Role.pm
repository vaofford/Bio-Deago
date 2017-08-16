package Bio::Deago::Config::Role;

# ABSTRACT: config class

use Moose::Role;
use namespace::autoclean;
use Cwd;

has 'counts_directory'  => ( is => 'rw', isa => 'Str');
has 'targets_file' 	   	=> ( is => 'rw', isa => 'Str');
has 'results_directory' => ( is => 'rw', isa => 'Str',		default => getcwd());
has 'annotation_file'   => ( is => 'rw', isa => 'Str');
has 'control'   				=> ( is => 'rw', isa => 'Str');
has 'qvalue'   					=> ( is => 'rw', isa => 'Num', 		default=>0.05);
has 'keep_images'   		=> ( is => 'rw', isa => 'Bool', 	default=>0);
has 'qc_only'  					=> ( is => 'rw', isa => 'Bool', 	default=>0);
has 'go_analysis' 			=> ( is => 'rw', isa => 'Bool', 	default=>0);
has 'is_valid'					=> ( is => 'ro', isa => 'Bool',		default=>0);

1;