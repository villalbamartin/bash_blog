#!/usr/bin/perl -w
##
# Creates an html file from a (properly formatted) text file, and some certain
# templates placed in a particular directory.
##

use HTML::Template;
use File::Path qw( make_path );
use strict;
use warnings;
if($#ARGV < 0)
{
	print "Missing or incorrect filename\n";
	print "Usage: ./simple_page.pl <input file> <output file>\n";
	exit;
}

# Base directories
my $OUTPUT_FILE="/dev/null";

if($ARGV[0] =~ /^$ENV{'BASE_DIR'}\/content\/.*\/([^\/]+).txt$/)
{
	$OUTPUT_FILE = "$ENV{'OUTPUT_DIR'}/$1.html";
}
elsif($#ARGV == 1)
{
	$OUTPUT_FILE = $ARGV[1];
}

# Templates
my @fileparts=("header.html", "wrap_post_before.html", "post.html",
	    "wrap_post_after.html", "comments.html", "footer.html" );

# Step 1: extract all the information from the text file
my $title;
my @categories;
my $date;
my $text;
my $defined=0;

open TEXT, "<$ARGV[0]" or die "Could not open content file";
while(<TEXT>)
{
	if($defined == 0)
	{
		if($_ =~ /^title: (.*)$/) 	{ $title=$1; }
		elsif($_ =~ /^category: (.*)$/) { @categories=split(',',$1); }
		elsif($_ =~ /^date: (.*)$/) 	{ $date=$1; }
		elsif($_ =~ /^--/) 		{ $defined=1; }
	}
	else
	{
		$text = $text . $_;
	}
}
close TEXT;

# Step 2: output the info into a set of templates, and output that info into
# a single post file
my $template;
open OUTFILE, ">${OUTPUT_FILE}" or die "Cannot open output file ${OUTPUT_FILE}";
foreach my $part (@fileparts)
{
	$template= HTML::Template->new(filename => "$ENV{'TEMPLATE_DIR'}/${part}",
					die_on_bad_params => 0);
	$template->param(TITLE => $title);
	$template->param(DATE => $date);
	$template->param(TEXT => $text);
	$template->param(CATEGORIES => make_cats(@categories));
	if(has_sidenote($text))
	{
		$template->param(WIDTH => "pure-u-med-4-5");
	}
	print OUTFILE $template->output;
}
close OUTFILE;


sub has_sidenote
{
	return ($_[0] =~ /^(.+)<aside>.+?<\/aside>(.+)$/msg)
}

sub make_cats
{
	my $retval = "";
	my $buffer;
	my @letras;
	foreach my $cat (@_)
	{
		$buffer=0;
		@letras = split(//,$cat);
		foreach my $letra (@letras)
		{
			$buffer += ord($letra);
		}
		$buffer = $buffer % 10;
		# TODO: the category should be lowercase
		$retval .= "<a class=\"post-category post-category-${buffer}\" href=\"categories/${cat}\">${cat}</a> ";
	}
	if(length($retval) == 0)
	{
		$retval = "no category";
	}
	return $retval;
}
