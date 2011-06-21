package i18n::Helper;

use warnings;
use strict;
use YAML::XS;
use feature 'state';


=head1 NAME

i18n::Helper - The great new i18n::Helper!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use i18n::Helper;

    my $foo = i18n::Helper->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=cut

use base 'Exporter';
our @EXPORT = (qw/
	compare_i18n_yamls
	find_unused
	find_missing_in_yaml
	files2paths
	code2paths
	ymls2paths
	yaml2hash
	hash2paths/);

=head1 SUBROUTINES/METHODS

=head2 compare_i18n_yamls

=cut

sub compare_i18n_yamls {
	my ($left,$right) = @_;
	open LEFT,'>',"/tmp/$$.left";
	open RIGHT,'>',"/tmp/$$.right";
	foreach(sort keys %$left) { print LEFT "$_\n";  }
	foreach(sort keys %$right){ print RIGHT "$_\n"; }
	close LEFT;
	close RIGHT;

	return qx{diff -y --suppress-common-lines /tmp/$$.left /tmp/$$.right};
	unlink "/tmp/$$.left";
	unlink "/tmp/$$.right";
}

=head2 find_unused

=cut

sub find_unused {
	my ($yaml,$paths) = @_;
	my $unused = { %$yaml };

	foreach my $key (keys %$paths){
		delete $unused->{$key} if defined($unused->{$key});
	}
	return $unused;
}

=head2 find_missing_in_yaml

=cut

sub find_missing_in_yaml {
	my ($yaml,$paths) = @_;
	my $missing_in_yaml = { %$paths };
	
	foreach my $key (keys %$yaml){
		delete $missing_in_yaml->{$key} if defined($missing_in_yaml->{$key});
	}
	return $missing_in_yaml;
}
	
=head2 files2paths

=cut

sub files2paths {
	my ($folder) = shift;
	our ($paths,$codepaths) = ({},{});
	open FILES,'-|',qq{find "$folder" -type f};
	while(<FILES>){ chomp; code2paths($_); }
	return { paths => $paths, codepaths => $codepaths };
}
	
=head2 code2paths

=cut

sub code2paths {
	my $file = shift;
	our ($paths,$codepaths);
	if( -f $file and qx{file -iz $file} =~ /text\/plain/){
		unless (open FILE,'<',$file){ warn "Could not open file '$file'"; next;	}
		while(<FILE>){
			if(/\bt\(.*?(['"])(.*?)\1/){
				my $path = $2;
				$paths->{$path} //= [];
				push @{$paths->{$path}}, "$file:$.";
			}
			elsif(/\b(t\(.*?\))/) {
				my $path = $1;
				$codepaths->{$path} //= [];
				#push @$codepaths, {file => $file, path => $2};
				push @{$codepaths->{$path}}, "$file:$.";
			}
		}
		close FILE;
	}
}

=head2 ymls2paths 

=cut

sub ymls2paths {
	my $paths = {};
	my ($igf,$files);
	if(ref($_[0])){
		my $params = shift;
		$igf = $params->{ignore_first};
		$files = $params->{files};
	}
	$igf //= 0;
	$files //= \@_;
	foreach my $file (@$files){
		my $yaml = yaml2hash($file,$igf);
		hash2paths($paths,'',$yaml,$file);
	}
	return $paths;

}

=head2 yaml2hash

=cut

sub yaml2hash {
	my ($file,$igf) = @_;
	if($igf){
		my $hash = YAML::XS::LoadFile($file);
		my ($start_key) = keys %$hash;
		return $hash->{$start_key};
	}
	else {
		return YAML::XS::LoadFile($file);
	}
}

=head2 hash2paths

=cut

sub hash2paths {
    my ($paths,$prev_path,$hash,$file) = @_; 
	if (ref($hash) eq 'HASH'){
		foreach my $key (keys %$hash){
			my $newpath = $prev_path ne '' ?  "$prev_path.$key" : $key;
			hash2paths($paths,$newpath,$hash->{$key},$file);
		}
	}
	else {
		$paths->{$prev_path} //= [];
		push @{$paths->{$prev_path}}, $file;
	}
}



=head1 AUTHOR

Andre Santos, C<< <andrefs at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-i18n-helper at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=i18n-Helper>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc i18n::Helper


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=i18n-Helper>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/i18n-Helper>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/i18n-Helper>

=item * Search CPAN

L<http://search.cpan.org/dist/i18n-Helper/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Andre Santos.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of i18n::Helper
