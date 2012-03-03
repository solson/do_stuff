do\_stuff
========

Do\_stuff is a minimalistic command line todo list manager that doesn't get in
your way. I created it because I could not find a todo list manager that I
didn't dislike for some reason or another. Do\_stuff is simple in features and
simple in code (written in one night).

Install
-------

``` bash
gem install do_stuff
echo /path/to/todo.txt > ~/.do_stuffrc
```

It turns out using do\_stuff through RubyGems leads to noticably longer
start-up times, so I recommend the following, assuming `~/bin` is in your
`PATH`:

``` bash
do_stuff --standalone ~/bin/t
```

Now you can use `t` just like you would `do_stuff`, and it's fast!

Usage
-----

See `t -h`. Examples of use below.

```
[~]$ t -h
usage: t                    list unfinished tasks
       t <task desc>        add a new task
       t <task num>         erase task
       t -e [task num]      edit task file and jump to given task
       t -h, --help         show this message
[~]$ t That thing I need to do.
Added #1: That thing I need to do.
[~]$ t -e # open the todo file with $EDITOR
Added #2: That thing I added from -e.
[~]$ t Walk the dog.
Added #3: Walk the dog.
[~]$ t Wash my clothes.
Added #4: Wash my clothes.
[~]$ t ALL the things.
Added #5: ALL the things.
[~]$ t
1. That thing I need to do.
2. That thing I added from -e.
3. Walk the dog.
4. Wash my clothes.
5. ALL the things.
[~]$ t 2
Erased #2: That thing I added from -e.
[~]$ t 4
Erased #4: Wash my clothes.
[~]$ t
1. That thing I need to do.
3. Walk the dog.
5. ALL the things.
[~]$ t Edit my todo list in vim.
Added #2: Edit my todo list in vim.
[~]$ t
1. That thing I need to do.
2. Edit my todo list in vim.
3. Walk the dog.
5. ALL the things.
[~]$ t -e2 # edit with $EDITOR, jumping to line with task #2
Changed #2:
-Edit my todo list in vim.
+Finish the demonstration.
```

