# Untitled Bash blog

A blogging engine I wrote using only Unix command-line tools.

This repository contains a (now-discontinued) set of scripts I used to
write my own blog. It started as an attempt to write everything in Bash to
see if I could, and eventually incorporated some Perl scripts when I finally
accepted that just because I *could* it didn't mean I *should*.

Setting everything up
---------------------
Seeing how this code was never meant to be public, the current "proper" way
to set everything up is to look for all files where I wrote `example.com` and
replace it with the proper URL.

As part of the publication effort, I'll publish a proper usage guide soon.

Basic Usage
-----------
All new blog articles are placed in the `content` folder. Files ending in
`.txt` are considered published, and the filename will be used as the
article's URL, replacing `.txt` with `.html`. Posts are written in plain HTML.

Once you are ready to update, you first need to load the necessary environment
variables with the command

```
source variables.cfg
```

If your variables are properly set, running the `generate.sh` script should
output your entire website to wherever your `BASE_DIR` variable says it should.



Is this blog platform for me?
-----------------------------
No. I wrote this code because I wanted to challenge myself, and for that
purpose I consider it a success. That said, there are plenty of better 
static blog generators out there, and you should definitely use one of them
(I have personally switched to [Pelican](https://blog.getpelican.com/)).
This code is published more for educational and archival purposes than for
real-life usage.
