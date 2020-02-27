#!/bin/bash

# Static blog generator, by Martin
#
# I'm fairly sure there's a good reason I'm doing this by hand, but right now I
# can't think of anything. Anyway, this script updates the blog status

# Debug output and environment variables
set -e
source variables.cfg

# Generic functions
get_date()
{
	grep -e "^date:" $1 | sed 's/^ *date: \?\(.*\)/\1/'
}

# Specific functions
write_single_pages()
{
	echo "Creating single pages..."
	while read post
	do
		FILE=$(echo ${post} | sed 's/.*:://')
		./simple_page.pl "${FILE}"
		echo "Writing: ${FILE}"
	done
	echo "Done"
}

write_frontpage()
{
	echo -n "Creating the front page..."
	./frontpage.pl "$1"
	echo " Done"
}

write_archives()
{
	echo -n "Creating the archive..."
	./archive.pl "$1"
	echo " Done"
}

# Preprocessing
LANG=en_US

# Get the data from each post, send it to a file with the date - it is intended
# to be retrieved through sort, and therefore in (reverse) chronological order.
# I bet there's a better way.
find $POST_DIR -type f -iname \*txt | while read post
do
	DATE=$(get_date ${post})
	echo "${DATE}::${post}"
done | sort -nr > ${SORTEDFILE}

# Step 1: write the page for a single post
write_single_pages < ${SORTEDFILE}

# Step 2: Main page (and RSS feed)
write_frontpage ${SORTEDFILE}

# Step 3: Monthly archives
write_archives ${SORTEDFILE}

# Step 4: cleaning up
rm ${SORTEDFILE}

exit
