#!/usr/bin/perl -w

##
# Creates an html file with the archives for all posts
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
my @templates=("header.html", "wrap_post_before.html", "post.html",
		"wrap_post_after.html", "footer.html");
my $template;
my $title;
my $last;
my $file;
my $date;
my $month;
my $url;
my $text;

open ARCHIVE, ">$ENV{'ARCHIVEPAGE'}" or die "Could not create archive";
open SORTEDPOSTS, "<$ARGV[0]" or die "Could not open post list";

foreach my $part (@templates)
{
	if($part eq "post.html")
	{
		$last="";
		$text="";
		while(<SORTEDPOSTS>)
		{
			if($_ =~ /^(....-(..)-..)::(.*\/([^\/]+))\.txt$/)
			{
				$date=$1;
				$month=$2;
				$file=$3;
				$title=`cat ${file}.txt | grep "^title:" | sed 's/^title: //'`;
				# Check this variable
				$url="$ENV{'BASE_URL'}/$4.html";

				# Generate the correct HTML
				if (!($month eq $last))
				{
					if(!($last eq ""))
					{
						$text .= "</ul>\n";
					}
					$last=$month;
					$date=`date -d $date +'%B %Y' | sed 's/^./\U&/'`;
					$text .= "<h2>$date</h2><ul>\n";
				}
				$text .= "<li><a href=\"${url}\">${title}</a></li>\n";
			}
		}
		$text .= "</ul>\n";
		$title = "Monthly archives";
		$template=HTML::Template->new(
				filename => "$ENV{'TEMPLATE_DIR'}/${part}",
				die_on_bad_params => 0);

		$template->param(TITLE => $title);
		$template->param(DATE => $date);
		$template->param(TEXT => $text);		
		print ARCHIVE $template->output;
		
	}
	else
	{
		$title = "Monthly archives";
		$date = `date -R`;
		$template= HTML::Template->new(
				filename => "$ENV{'TEMPLATE_DIR'}/${part}",
				die_on_bad_params => 0);
		$template->param(TITLE => $title);
		$template->param(DATE => $date);
		print ARCHIVE $template->output;
	}
}
close(ARCHIVE);
close(SORTEDPOSTS);
