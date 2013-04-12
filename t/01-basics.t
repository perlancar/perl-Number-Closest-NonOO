#!/perl

use 5.010;
use strict;
use warnings;
use Number::Closest::NonOO qw(find_closest_number find_farthest_number);
use Test::More 0.98;

is(find_closest_number(number=>1, numbers=>[1, 2, 3]), 1, "items=1 (default) returns scalar");
is_deeply(find_closest_number(number=>1, numbers=>[1, 2, 3], items=>2), [1, 2], "items>1 returns array");

is(find_farthest_number(number=>1, numbers=>[1, 2, 3]), 3, "find_farthest_number");

is_deeply(find_closest_number(number=>1, numbers=>["-inf", -2, -1, 0, 1, 2, "inf"], items => 2),
          [1, 0], "inf=nothing 1");

is_deeply(find_closest_number(number=> "inf", numbers=>["-inf", -2, -1, 0, 1, 2, "inf"], items => 10),
          ["inf", 2, 1, 0, -1, -2, "-inf"], "inf=number 1");
is_deeply(find_closest_number(number=>"-inf", numbers=>["-inf", -2, -1, 0, 1, 2, "inf"], items => 10),
          ["-inf", -2, -1, 0, 1, 2, "inf"], "inf=number 2");

done_testing;
