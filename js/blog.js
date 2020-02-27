function random_tagline()
{
	tagline = ["Random tagline 1", 
		"Random tagline 2",
		"Random tagline 3"];
	index = Math.floor(tagline.length*Math.random());
	return tagline[index];
}
