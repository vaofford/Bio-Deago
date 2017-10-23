package TestHelper;

# ABSTRACT: Test helper
# Functionality has been borrowed from Roary (Andrew Page)

=head1 SYNOPSIS
Test helper
=cut

use Moose::Role;
use Test::Most;
use Test::Files;
use Test::Output;
use Cwd;
use File::Path qw(make_path);
use File::Slurper qw(read_text write_text);
use Log::Log4perl qw(:easy);

$ENV{PATH} .= ":./bin";

sub mock_execute_script_and_check_output {
    my ( $script_name, $scripts_and_expected_files, $columns_to_exclude ) = @_;

    open OLDOUT, '>&STDOUT';
    open OLDERR, '>&STDERR';
    eval("use $script_name ;");

    my $returned_values = 0;
    {
        local *STDOUT;
        open STDOUT, '>/dev/null' or warn "Can't open /dev/null: $!";
        local *STDERR;
        open STDERR, '>/dev/null' or warn "Can't open /dev/null: $!";

        for my $script_parameters ( sort keys %$scripts_and_expected_files ) {
            my $full_script = $script_parameters;
            my @input_args = split( " ", $full_script );

            my $cmd = "$script_name->new(args => \\\@input_args, script_name => '$script_name')->run;";
            eval($cmd);
            warn $@ if $@;

            my @actual_output_file_names   = @{ $scripts_and_expected_files->{$script_parameters}->[0] };
            my @expected_output_file_names = @{ $scripts_and_expected_files->{$script_parameters}->[1] } if ( defined($scripts_and_expected_files->{$script_parameters}->[1]) );

            for (my $i=0; $i < scalar(@actual_output_file_names); $i++) {
                ok( -e $actual_output_file_names[$i], "Actual output file exists $actual_output_file_names[$i]  $script_parameters" );

                if ( defined($expected_output_file_names[$i]) ) {
                    compare_ok( $actual_output_file_names[$i], $expected_output_file_names[$i], "Actual and expected output match for '$script_parameters'" );
                }

                unlink($actual_output_file_names[$i]);
            }
        }
        close STDOUT;
        close STDERR;
    }

    # Restore stdout.
    open STDOUT, '>&OLDOUT' or die "Can't restore stdout: $!";
    open STDERR, '>&OLDERR' or die "Can't restore stderr: $!";

    # Avoid leaks by closing the independent copies.
    close OLDOUT or die "Can't close OLDOUT: $!";
    close OLDERR or die "Can't close OLDERR: $!";
}

sub stdout_should_have {
    my ( $script_name, $parameters, $expected ) = @_;
    my @input_args = split( " ", $parameters );
    open OLDERR, '>&STDERR';
    eval("use $script_name ;");
    my $returned_values = 0;
    {
        local *STDERR;
        open STDERR, '>/dev/null' or warn "Can't open /dev/null: $!";
        stdout_like { eval("$script_name->new(args => \\\@input_args, script_name => '$script_name')->run;"); } qr/$expected/, "got expected text $expected for $parameters";
        close STDERR;
    }
    open STDERR, '>&OLDERR' or die "Can't restore stderr: $!";
    close OLDERR or die "Can't close OLDERR: $!";
}

sub stderr_should_have {
    my ( $script_name, $parameters, $expected ) = @_;
    my @input_args = split( " ", $parameters );
    open OLDOUT, '>&STDOUT';
    eval("use $script_name ;");
    my $returned_values = 0;
    {
        local *STDOUT;
        open STDOUT, '>/dev/null' or warn "Can't open /dev/null: $!";
        stderr_like { eval("$script_name->new(args => \\\@input_args, script_name => '$script_name')->run;"); } qr/$expected/, "got expected text $expected for $parameters";
        close STDOUT;
    }
    open STDOUT, '>&OLDOUT' or die "Can't restore stdout: $!";
    close OLDOUT or die "Can't close OLDOUT: $!";
}

sub make_output_directory {
    my $cwd = getcwd();
    my $output_directory = $cwd . "/deago_test_output";

    eval { make_path($output_directory) };
    if ( $@ || $output_directory !~ m/deago_test_output/ ) {
        print "Couldn't create $output_directory: $@";
    } 
    die "Could not create or define output_directory" if ( !-d $output_directory || $output_directory !~ m/deago_test_output/ || $output_directory eq "" );
    return $output_directory;
}

sub build_star_delimited_annotation_file {
    my $tab_delim_annotation = read_text('t/data/example_mart_annotation.tsv');
    my $star_delim_annotation = $tab_delim_annotation;
    $star_delim_annotation =~ s/\t/\*\*/g;
    write_text('star_delimited_annotation.txt', $star_delim_annotation);
}

sub check_deago_environment_variables {    
    my $original_path = $ENV{PATH};
    my $original_rlibs = $ENV{R_LIBS};

    # Change R executable and libraries here if this pair of tests fail!
    my $deago_r = "/software/R-3.4.0/bin";
    my $deago_rlibs = "/software/pathogen/external/lib/R-3.4";

    $ENV{PATH} = join(":", $deago_r, $ENV{PATH});
    $ENV{R_LIBS} = $deago_rlibs;

    like( $ENV{PATH}, qr/^$deago_r/, 'DEAGO_R (R version bin) added to PATH');
    is( $ENV{R_LIBS}, $deago_rlibs, 'DEAGO_R_LIBS (R libraries) added to R_LIBS');

    $ENV{PATH} = $original_path;
    $ENV{R_LIBS} = $original_rlibs;
}

no Moose;
1;