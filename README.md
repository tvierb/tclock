# tclock.pl -- a simple analog clock for the terminal

Usage:
    ./tclock.pl [--delay 15] [--stretch 2.25] [--help]

This clock is heavily inspired by the famous awk terminal clock by Antoni Sawicki --> https://github.com/tenox7/aclock/blob/master/sources/aclock.awk

But I did it in Perl (18:39):

                                  . .  12  . .
                            .  .               .  .
                       .  11                        1  .
                     .                                   .
                   .                                       .
                  .                                         .
                10                                            2
               .                                               .
              .                                                 .

             .                                                   .
             .                                                   .
             9                                                   3
             .                      M MH                         .
             .                  M M   H                          .
                              M      H
              .            MM       H                           .
               .       M M         H                           .
                8    M             H                          4
                  .               H                         .
                   .                                       .
                     .                                   .
                       .  7                         5  .
                            .  .               .  .
                                  . .  6  . .

you can resize the terminal window and the clock will adapt the new size within seconds.

## Ideas for future versions

* have a thicker hour hand
* colors
* Draw other characters in the circle like ',:!?
* two circles of numbers: one for hours and another for minutes
* (24 hour mode)
* different clock faces

## Other

A great extensive list of terminal codes can be found at https://www-user.tu-chemnitz.de/~heha/hsn/terminal/terminal.htm on the time of writing this line.

