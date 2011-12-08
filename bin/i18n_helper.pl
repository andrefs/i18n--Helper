#!/usr/bin/env perl
use strict; use warnings;
use Data::Dumper;


show_intro();
until(show_menu()){};


sub ymlvsyml{
	print "ymlvsyml\n";	
	my $yml1 = list_ymls();
	my $yml2 = list_ymls();
}

sub list_ymls {
	my $pwd = qx{pwd};
	open FILES,'-|',"find . -type f | grep 'config/locales' | grep -v -i vendor | grep -P 'yml\$|yaml\$'";
	my @files = <FILES>;
	print "[$_] ",$files[$_-1] foreach (1..int(@files));
	print "\n[0] Cancel.\n";
	my $opt;
	until(valid_option($opt,int(@files))){
		print "\nChoose a YAML file:\n";
		my $opt = <>;
		print valid_option($opt),"\n";
		chomp $opt;
		print "'$opt'\n";
	}
	exit if $opt == 0;
	return $files[$opt-1];
}

sub ymlvsdir{
	print "ymlvsdir\n";	
}


sub dirvsyml{
	print "dirvsyml\n";	
}


sub show_intro {
		print "\nWelcome to i18n_helper!\nThis script helps to find missing or unnused translations\nin Rails apps and YAML files, and it is based on the\ni18n::Helper Perl module.\n\n";
}

sub valid_option{
	my ($opt,$max) = shift;
	chomp $opt;
	return undef unless defined($opt);
	return undef unless $opt =~ /^\d+/;
	return undef if $opt < 0;
	return undef if $opt > $max;
	return $opt;
}

sub show_menu {

	my @options = (
		{	text => 'Compare 2 YAML files      ( YAML vs YAML )',
			func => \&ymlvsyml,  								},
		{	text => 'Find unnused translations ( YAML vs dir  )',
			func => \&ymlvsdir,									},
		{	text => 'Find missing translations ( dir  vs YAML )',
			func => \&dirvsyml,									}
	);

	print "[$_] ",$options[$_-1]->{text},"\n" foreach (1..int(@options));
	print "\n[0] Quit.\n";
	print "\nWhich one do you want to do?\n";
	my $opt = <>;
	chomp $opt;
	if($opt eq '' or ! defined($opt)){
		system 'clear';
		print "Undefined option!\n";
		return undef;
	}
	if($opt !~ /^\d+$/){
		system 'clear';
		print "'$opt' is not a number!\n";
		return undef;
	}
	if($opt < 1 or $opt > @options){
		system 'clear';
		print "'$opt' is invalid!\n";
		return undef;
	}
	$options[$opt-1]->{func}();
	return 1;
}
