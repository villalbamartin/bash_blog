# bash_blog
A blogging enging I wrote using only Unix command-line tools.

This repository contains a (now-discontinued) set of scripts I used to
write my own blog. It started as an attempt to write everything in Bash to
see if I could, and eventually incorporated some Perl scripts when I finally
accepted that just because I *could* it didn't mean I *should*.

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
