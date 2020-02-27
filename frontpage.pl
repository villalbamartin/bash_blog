#!/usr/bin/perl -w
##
# Creates an html file with the frontpage of the blog, plus the RSS feed.
# It assembles a set of templates
##

use HTML::Template;
use strict;
use warnings;

if($#ARGV != 0)
{
	print "Missing or incorrect filename\n";
	exit;
}

# Templates
my @template_frontp=("header.html", "wrap_post_before.html", "post.html",
	    "wrap_post_after.html", "footer.html" );
my @template_rss=("rss_header.xml", "rss_item.xml", "rss_footer.xml" );

# Step 1: get all the information about each post
my $title;
my $date;
my $postfile;
my $template;
my @allposts;

open ALLFILES, "<$ARGV[0]" or die "Could not open content file";
my $i=0;
while(<ALLFILES>)
{
	if($_ =~ /^(.*)::(.*)$/ and $i < $ENV{'MAXPOSTS'})
	{
		# Loads information from each individual post
		my %tmp = get_post_data($2);
		$allposts[$i]{'title'}=$tmp{'title'};
		$allposts[$i]{'categories'}=$tmp{'categories'};
		$allposts[$i]{'date'}=$tmp{'date'};
		$allposts[$i]{'text'}=$tmp{'text'};
		$allposts[$i]{'short_text'}=$tmp{'short_text'};
		$allposts[$i]{'url'}=$tmp{'url'};
		$i++;
	}
}
close ALLFILES;

# Step 2: write the main page
my $post;
my $filename;
open FRONTPAGE, ">$ENV{'MAINPAGE'}" or die "Could not write frontpage";
foreach my $part (@template_frontp)
{
	if($part eq "post.html")
	{
		for($i=0; $i<$ENV{'MAXPOSTS'}; $i++)
		{
			if($i==0)
			{
				$filename = "$ENV{'TEMPLATE_DIR'}/pinned_post.html";
			}
			else
			{
				$filename = "$ENV{'TEMPLATE_DIR'}/post.html";
			}
			$template= HTML::Template->new(filename => $filename,
							die_on_bad_params => 0);
			$template->param(TITLE => "<a href=\"" .
				 $allposts[$i]{'url'} . "\">" .
				 $allposts[$i]{'title'} . "</a>");
			$template->param(DATE => $allposts[$i]{'date'});
			$template->param(TEXT => $allposts[$i]{'short_text'});
			$template->param(CATEGORIES => make_cats(split(',',$allposts[$i]{'categories'})));
			print FRONTPAGE $template->output;
		}
	}
	else
	{
		$title = "Main page";
		$date = `date -R`;
		$template= HTML::Template->new(
					filename => "$ENV{'TEMPLATE_DIR'}/${part}",
					die_on_bad_params => 0);
		$template->param(TITLE => $title);
		$template->param(DATE => $date);
		print FRONTPAGE $template->output;
	}
}
close FRONTPAGE;

# Step 3: write the RSS feed
# This is very similar to the way we write the frontpage,
# but it's cleaner to have it here
open RSSFEED, ">$ENV{'RSSFILE'}" or die "Could not write rss file";
foreach my $part (@template_rss)
{
	if($part eq "rss_item.xml")
	{
		for($i=0; $i<$ENV{'MAXPOSTS'}; $i++)
		{
			$filename = "$ENV{'TEMPLATE_DIR'}/${part}";
			$template= HTML::Template->new(filename => $filename,
							die_on_bad_params => 0);
			$template->param(TITLE => $allposts[$i]{'title'});
			$template->param(DATE => $allposts[$i]{'date'});
			$template->param(TEXT => $allposts[$i]{'text'});
			$template->param(LINK => $allposts[$i]{'url'});
			print RSSFEED $template->output;
		}
	}
	else
	{
		$title = "example.com - My blog";
		$date = `date -R`;
		$template= HTML::Template->new(
					filename => "$ENV{'TEMPLATE_DIR'}/${part}",
					die_on_bad_params => 0);
		$template->param(TITLE => $title);
		$template->param(DATE => $date);
		print RSSFEED $template->output;
	}
}
close RSSFEED;

# Gets all information from a post into a hash, and returns that
sub get_post_data
{
	my $defined = 0;
	my $short=0;
	my %data;
	open POST, "<$_[0]" or die "Could not open file $_[0]";
	if($_[0] =~ /^(.*)\/([^\/]+).txt$/)
	{
		$data{'url'}="$ENV{'BASE_URL'}/$2.html";
	}
	while(<POST>)
	{
		if($defined == 0)
		{
			if($_ =~ /^title: (.*)$/)
			{
				$data{'title'}=$1;
			}
			elsif($_ =~ /^category: (.*)$/)
			{
				$data{'categories'}=$1;
			}
			elsif($_ =~ /^date: (.*)$/)
			{
				$data{'date'}=$1;
			}
			elsif($_ =~ /^--/) 
			{
				$defined=1;
				$data{'text'}="";
				$data{'short_text'}="";
			}
		}
		else
		{
			$data{'text'} .= $_;
			if($short == 0)
			{
				if($_ =~ /(.*)<!--more-->(.*)/)
				{
					$data{'short_text'}.=$1;
					$data{'short_text'}.=
				" <a href=\"$data{'url'}\">Keep reading...</a>";
					$short=1;
				}
				else
				{
					$data{'short_text'}.=$_;
				}
			}
		}
	}
	close POST;
	# An extra step: remove the footnotes (ie, the "aside" tags) from the
	# short preview
	while ($data{'short_text'} =~ /^(.+)<aside>.+?<\/aside>(.+)$/msg)
	{
		$data{'short_text'} = $1 . $2;
	}
	return %data;
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
