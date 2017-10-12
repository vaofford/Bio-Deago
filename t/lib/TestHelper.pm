package TestHelper;

# ABSTRACT: Test helper
# Functionality has been borrowed from Roary (Andrew Page)

=head1 SYNOPSIS
Test helper
=cut

use Moose::Role;
use Test::Most;
use Data::Dumper;
use Test::Files;
use Test::Output;
use Cwd;
use File::Path qw(make_path);
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

sub make_results_directory {
    my $cwd = getcwd();
    my $results_directory = $cwd . "/deago_test_results";
    eval { make_path($results_directory) };
    if ( $@ || $results_directory !~ m/deago_test_results/ ) {
        print "Couldn't create $results_directory: $@";
    } 
    die "Could not create or define results_directory" if ( !-d $results_directory || $results_directory !~ m/deago_test_results/ || $results_directory eq "" );
    return $results_directory;
}

no Moose;
1;