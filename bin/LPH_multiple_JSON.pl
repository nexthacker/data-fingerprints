#!/usr/bin/env perl
$|=1;
use strict;

####
#
# This software library computes data fingerprints.
# 
# Copyright 2017 by Gustavo Glusman, Institute for Systems Biology, Seattle, WA, USA.
# It is provided by the Institute for Systems Biology as open source software.
# See the accompanying LICENSE file for information about the governing license.
#
####
#
# The first parameter is the directory where the JSON objects are located.
# The second parameter is the fingerprint size to be used.
# The third parameter specifies whether fingerprints need to be normalized.
#
# The standard output consists of fingerprints of the JSON objects in the directory, one per line.
# The first column is the identifier (filename).
# The second column is the number of 'statements' observed while computing the fingerprint.
# The remaining columns are the fingerprint itself.
#
####

use lib "/users/gglusman/proj/LPH";
use LIBLPH;
my $LPH = new LIBLPH;

use JSON;
my($dir, $L, $normalize) = @ARGV;
$L ||= 50;
$LPH->{'L'} = $L;
my(%cache, %cacheCount);
my $decimals = 3;

foreach my $scanfile (fulldirlist($dir)) {
	if ($scanfile =~ /\.gz$/) {
		open JF, "gunzip -c $scanfile.gz |";
	} else {
		open JF, $scanfile;
	}
	my @jsonContent = <JF>;
	close JF;
	chomp(@jsonContent);
	my $jsonString = join("", @jsonContent);
	next unless $jsonString;
	$scanfile .= "Y" if $jsonString =~ /chrY/;
	my $content = decode_json($jsonString);
	
	$LPH->resetFingerprint();
	$LPH->recurseStructure($content);
	my $fp;
	if ($normalize) {
		$fp = $LPH->normalize();
	} else {
		$fp = $LPH->{'fp'};
	}
	print join("\t", $scanfile, $LPH->{'statements'}, map {sprintf("%.${decimals}f", $fp->[$_])} (0..$L-1)), "\n";
}
close TB;


sub fulldirlist {
	my($self, $dir) = @_;
	opendir (DIR, $dir);
	my @files = grep /^[^.]/, readdir DIR;
	closedir DIR;
	return @files;
}

