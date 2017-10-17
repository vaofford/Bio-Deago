package Bio::Deago::Markdown;

use Moose;
use Cwd qw(abs_path);
use File::Basename;
use Text::Template;
use File::Slurper qw(write_text);

has 'config_file' 				=> ( is => 'ro', isa => 'Str', 							required => 1);
has 'config_hash' 				=> ( is => 'rw', isa => 'Config::General', 	required => 1);
has 'contrasts'						=> ( is => 'ro', isa => 'ArrayRef', 				required => 1);
has 'num_samples'					=> ( is => 'rw', isa => 'Num', 							default => 0);
has 'replacement_values'	=> ( is => 'ro', isa => 'HashRef',					lazy => 1, builder => '_define_replacement_values');
has 'output_filename'			=> ( is => 'ro', isa => 'Str', 							default => './deago_markdown.Rmd' );
has 'template_files'			=> ( is => 'rw', isa => 'HashRef', 					lazy => 1, builder => '_get_template_files');
has 'template_directory'	=> ( is => 'rw', isa => 'Str', 							lazy => 1, builder => '_get_template_directory');
has 'final_markdown'			=> ( is => 'ro', isa => 'ArrayRef',					lazy => 1, builder => '_build_markdown');

no Moose;

sub BUILD {
	my ($self) = @_;

	$self->template_directory;
	$self->template_files;
	$self->_templates_exist;
	$self->final_markdown;
	$self->_write_markdown;
}

sub _get_template_directory {
	my @module_dir_structure = File::Spec->splitdir( Cwd::abs_path(__FILE__) );
	my $module_directory = File::Spec->catdir( splice @module_dir_structure, 0, ($#module_dir_structure-3) );
	my $template_directory = $module_directory . "/markdown_templates";
	return $template_directory;
}

sub _get_template_files {
	my ($self) = @_;

	my %template_files = (
		'qc' => ['header.Rmd', 'config.Rmd', 'import.Rmd', 'deseq.Rmd', 'annotation.Rmd', 'qc_plots.Rmd'],
		'de_main' => ['contrast_main.Rmd'],
		'de_venn' => ['contrast_venn.Rmd'],
		'de_sections' => ['contrast_section.Rmd'],
		'go_main' => ['go_main.Rmd'],
		'go_sections' => ['go_section.Rmd']
	);

	return \%template_files;
}

sub _templates_exist {
	my ($self) = @_;
	foreach my $template_array ( values %{$self->template_files} ) {
		foreach my $template_file (@$template_array) {
			$template_file = $self->template_directory . "/" . $template_file;
			Bio::Deago::Exceptions::FileNotFound->throw( error => "Error: Could not find template file: " . $template_file . "\n" )
    		unless ( -e $template_file && -f $template_file );
    }
	}
	return 1;
}

sub _build_markdown {
	my ($self) = @_;

	$self->replacement_values;

	my @replaced_text;

	my @replaced_qc_text = @{ $self->_replace_template_values( $self->template_files->{'qc'}, $self->replacement_values->{'qc'} ) };
	push( @replaced_text, @replaced_qc_text );

	if ( $self->config_hash->{'config'}{'qc_only'} == 0 ) {
		my @replaced_de_main_text = @{ $self->_replace_template_values( $self->template_files->{'de_main'}, $self->replacement_values->{'de_main'} ) };
		push( @replaced_text, @replaced_de_main_text );

		if ( scalar(@{$self->contrasts}) <= 4 ) {
			my @replaced_de_main_text = @{ $self->_replace_template_values( $self->template_files->{'de_venn'}, $self->replacement_values->{'de_venn'} ) };
			push( @replaced_text, @replaced_de_main_text );
		}

		my @replaced_de_section_text = @{ $self->_get_contrast_text() };
		push( @replaced_text, @replaced_de_section_text );
	}
	return \@replaced_text;
}

sub _get_contrast_text {
	my ($self) = @_;

	my @temporary_contrast_text;
	foreach my $contrast_name ( @{$self->contrasts} ) {
		my %contrast_values = ( 'contrast_name' => $contrast_name ); 
		my @replaced_contrast_text = @{ $self->_replace_template_values( $self->template_files->{'de_sections'}, \%contrast_values ) };
		push( @temporary_contrast_text, @replaced_contrast_text );

		if ( $self->config_hash->{'config'}{'go_analysis'} == 1 ) {
			my @replaced_go_text = @{ $self->_get_go_text($contrast_name) };
			push( @temporary_contrast_text, @replaced_go_text );
		}
	}

	return \@temporary_contrast_text;
}

sub _get_go_text {
	my ($self) = $_[0];
	my $contrast_name = $_[1];

	my %replacement_go_values = ( 'contrast_name' => $contrast_name,
																'go_level' => $self->config_hash->{'config'}{'go_levels'} 
															 );

	my @temporary_go_text;
	my @replaced_main_go_text = @{ $self->_replace_template_values( $self->template_files->{'go_main'}, \%replacement_go_values ) };
	push( @temporary_go_text, @replaced_main_go_text );

	if ( $self->config_hash->{'config'}{'go_levels'} eq 'all' ) {
		my %replacement_bp_values = ( 'contrast_name' => $contrast_name, 'go_level' => 'BP' );
		my @replaced_bp_text = @{ $self->_replace_template_values( $self->template_files->{'go_sections'}, \%replacement_bp_values ) };
		my %replacement_mf_values = ( 'contrast_name' => $contrast_name, 'go_level' => 'MF' );
		my @replaced_mf_text = @{ $self->_replace_template_values( $self->template_files->{'go_sections'}, \%replacement_mf_values ) };
		push( @temporary_go_text, @replaced_bp_text, @replaced_mf_text );
	} else {
		my @replaced_go_section_text = @{ $self->_replace_template_values( $self->template_files->{'go_sections'}, \%replacement_go_values ) };
		push( @temporary_go_text, @replaced_go_section_text );
	}

	return \@temporary_go_text;
}

sub _define_replacement_values {
	my ($self) = @_;

	my $replacement_values = { qc 			=> { 	config_filename   => abs_path($self->config_file),
																						results_directory => $self->config_hash->{'config'}{'results_directory'},
																						count_column 		  => $self->config_hash->{'config'}{'count_column'},
																						skip_lines 			  => $self->config_hash->{'config'}{'skip_lines'},
																						count_delimiter   => $self->config_hash->{'config'}{'count_delim'},
                       										},
                       			 de_main 	=> { alpha => $self->config_hash->{'config'}{'qvalue'} },
                       		 	 go_main 	=> { alpha => $self->config_hash->{'config'}{'qvalue'} }
        										}; 

  $replacement_values->{'qc'} = {%{$replacement_values->{'qc'}}, %{$self->_define_qc_plot_values}};
	return $replacement_values;
}

sub _define_qc_plot_values {
	my ($self) = @_;

	my $qc_values = {	0	 => {	'rc_fig_width' 		=> 9, 'rc_fig_height' 	=> 7,
                  					'sd_fig_width' 		=> 9, 'sd_fig_height' 	=> 7,
	                          'pca_fig_width' 	=> 9, 'pca_fig_height' 	=> 7,
	                          'cd_fig_width' 		=> 9, 'cd_fig_height' 	=> 7,
	                          'dens_fig_width' 	=> 9, 'dens_fig_height' => 7,
	                          'disp_fig_width' 	=> 9, 'disp_fig_height' => 7
					                },
										10 => {	'pca_fig_width' 	=> 10, 'pca_fig_height' 	=> 9
													},
                    20 => {	'pca_fig_width' 	=> 11, 'pca_fig_height' 	=>11,
                          	'dens_fig_width' 	=> 11, 'dens_fig_height' 	=> 11
                        	},
                    30 => {	'sd_fig_width' 		=> 12, 'sd_fig_height' 		=> 11,
                          	'pca_fig_width' 	=> 12, 'pca_fig_height' 	=> 11,
                          	'dens_fig_width' 	=> 11, 'dens_fig_height' 	=> 12
                        	},
                    40 => {	'rc_fig_width' 		=> 10, 'rc_fig_height' 		=> 7,
                          	'sd_fig_width' 		=> 12, 'sd_fig_height' 		=> 11,
                          	'pca_fig_width' 	=> 14, 'pca_fig_height' 	=> 12,
                          	'cd_fig_width' 		=> 10, 'cd_fig_height' 		=> 7,
                          	'dens_fig_width' 	=> 11, 'dens_fig_height' 	=> 12,
                          	'disp_fig_width' 	=> 10, 'disp_fig_height' 	=> 7
                        	}
									};

	if ( $self->num_samples >= 10 && $self->num_samples < 20 ) {
		return { %{$qc_values->{0}}, %{$qc_values->{10}} };
	} elsif ( $self->num_samples >= 20 && $self->num_samples < 30 ) {
		return { %{$qc_values->{0}}, %{$qc_values->{20}} };
	} elsif ( $self->num_samples >= 30 && $self->num_samples < 40 ) {
		return { %{$qc_values->{0}}, %{$qc_values->{30}} };
	} elsif ( $self->num_samples >= 40 ) {
		return { %{$qc_values->{0}}, %{$qc_values->{40}} };
	} else {
		return $qc_values->{0};
	}
}

sub _replace_template_values {
	my ($self) = $_[0];
	my @template_files = @{$_[1]};
	my $replacement_values = $_[2];

	my @template_text;
	foreach my $template_file ( @template_files ) {
		my $template = Text::Template->new(TYPE => 'FILE',  SOURCE => $template_file);
		my $replaced_text = $template->fill_in(HASH => $replacement_values);
		push(@template_text, $replaced_text);
	}

	return \@template_text;
}

sub _write_markdown {
	my ($self) = @_;

	my $text_to_write = join("\n\n", @{$self->final_markdown});
	write_text($self->output_filename, $text_to_write);
	
}

__PACKAGE__->meta->make_immutable;

1;