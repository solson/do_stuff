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

I suggest setting up a shell alias or a symlink named `t` for `do_stuff`.

Usage
-----

See `t -h`. Examples of use below.

```
[~]$ t That thing I need to do.
Added #1: That thing I need to do.
[~]$ t
1. That thing I need to do.
[~]$ t -e # edit the todo.txt in $EDITOR
[~]$ t Another thing.
Added #3: Another thing.
[~]$ t And another.
Added #4: And another.
[~]$ t ALL the things.
Added #5: ALL the things.
[~]$ t
1. That thing I need to do.
2. That thing I added from -e.
3. Another thing.
4. And another.
5. ALL the things.
[~]$ t 2
Erased #2: That thing I added from -e.
[~]$ t 4
Erased #4: And another.
[~]$ t
1. That thing I need to do.
3. Another thing.
5. ALL the things.
[~]$ t Edit my todo list.
Added #2: Edit my todo list.
[~]$ t
1. That thing I need to do.
2. Edit my todo list.
3. Another thing.
5. ALL the things.
[~]$ t -e2 # start $EDITOR at task 2 in todo.txt (if possible)
```

