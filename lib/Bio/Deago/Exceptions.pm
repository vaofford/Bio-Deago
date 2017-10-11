package Bio::Deago::Exceptions;
# ABSTRACT: Exceptions 

=head1 SYNOPSIS
Exceptions 
=cut

use strict; use warnings;
use Exception::Class (
    'Bio::Deago::Exceptions::FileNotFound'				=> { description => 'Couldn\'t open the file' },
    'Bio::Deago::Exceptions::DirectoryNotFound'		=> { description => 'Couldn\'t find the directory' },
    'Bio::Deago::Exceptions::CouldntWriteToFile'	=> { description => 'Couldn\'t open the file for writing' },
    'Bio::Deago::Exceptions::ConfigNotValid'			=> { description => 'Config is not valid' },
    'Bio::Deago::Exceptions::TargetsNotValid'			=> { description => 'Target file is not valid' },
    'Bio::Deago::Exceptions::CountTypeNotValid'		=> { description => 'Count type is not valid' },
    'Bio::Deago::Exceptions::FileExists'					=> { description => 'Couldn\'t write to file, file already exists' },
);  

1;