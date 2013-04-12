package Number::Closest::NonOO;

use 5.010001;
use strict;
use warnings;

use Data::Clone;
use Scalar::Util 'looks_like_number';

# VERSION

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(find_closest_number find_farthest_number);
our %SPEC;

sub _find {
    my %args = @_;

    my $num = $args{number};
    my $nan = $args{nan} // 'nothing';
    my $inf = $args{inf} // 'number';
    my @nums = @{ $args{numbers} };
    if ($nan eq 'exclude' && $inf eq 'exclude') {
        @nums = grep {
            looks_like_number($_) && $_ != 'inf' && $_ != '-inf'
        } @nums;
    } elsif ($nan eq 'exclude') {
        @nums = grep {
            my $l = looks_like_number($_);
            $l &&
                $l != 36 && # nan
                    $l != 44; # -nan
        } @nums;
    }
    if ($inf eq 'exclude') {
        @nums = grep {
            !looks_like_number($_) ? 1 : ($_ != 'inf' && $_ != '-inf')
        } @nums;
    }

    my @mapped;
    my @res;
    if ($inf eq 'number' && ($num == "inf" || $num == "-inf")) {
        @res =map {
            my $m = [$_];
            if    ($num ==  'inf' && $_ ==  'inf') { push @$m, 0, 0   }
            elsif ($num ==  'inf' && $_ == '-inf') { push @$m, 'inf', 'inf' }
            elsif ($num == '-inf' && $_ ==  'inf') { push @$m, 'inf', 'inf' }
            elsif ($num == '-inf' && $_ == '-inf') { push @$m, 0, 0   }
            elsif ($num ==  'inf') { push @$m,  $num, -$_ }
            elsif ($num == '-inf') { push @$m, -$num,  $_ }
            $m;
        } @nums;
        #use Data::Dump; dd \@res;
        @res = sort {$a->[1] <=> $b->[1] || $a->[2] <=> $b->[2]} @res;
    } else {
        @res = sort {$a->[1] <=> $b->[1]} map {[$_, abs($_-$num)]} @nums;
    }
    @res = map {$_->[0]} @res;

    my $items = $args{items} // 1;
    @res = reverse @res if $args{-farthest};
    splice @res, $items unless $items >= @res;

    if ($items == 1) {
        return $res[0];
    } else {
        return \@res;
    }
}

$SPEC{find_closest_number} = {
    v => 1.1,
    summary => 'Find number(s) closest to a number in a list of numbers',
    args => {
        number => {
            summary => 'The target number',
            schema => 'num*',
            req => 1,
        },
        numbers => {
            summary => 'The list of numbers',
            schema => 'array*',
            req => 1,
        },
        items => {
            summary => 'Return this number of closest numbers',
            schema => ['int*', min=>1, default=>1],
        },
        nan => {
            summary => 'Specify how to handle NaN and non-numbers',
            schema => ['str', in=>['exclude', 'nothing'], default=>'exclude'],
            description => <<'_',

`exclude` means the items will first be excluded from the list. `nothing` will
do nothing about it, meaning there will be warnings when comparing non-numbers.

_
        },
        inf => {
            summary => 'Specify how to handle Inf',
            schema => ['str', in=>['number', 'nothing', 'exclude'],
                       default=>'number'],
            description => <<'_',

`exclude` means the items will first be excluded from the list. `nothing` will
do nothing about it and will produce a warning if target number is an infinite,
`number` will treat Inf like a very large number, i.e. Inf is closest to Inf and
largest positive numbers, -Inf is closest to -Inf and after that largest
negative numbers.

_
        },
    },
    result_naked => 1,
};
sub find_closest_number {
    my %args = @_;
    _find(%args);
}

$SPEC{find_farthest_number} = clone($SPEC{find_closest_number});
$SPEC{find_farthest_number}{summary} =
    'Find number(s) farthest to a number in a list of numbers';
sub find_farthest_number {
    my %args = @_;
    _find(%args, -farthest=>1);
}

1;
# ABSTRACT: Find number(s) closest to a number in a list of numbers

=head1 SYNOPSIS

 use Number::Closest::NonOO qw(find_closest_number find_farthest_number);
 my $nums = find_closest_number(number=>3, numbers=>[1, 3, 5, 10], items => 2);
 # => [3, 1];

 $nums = find_farthest_number(number=>3, numbers=>[1, 3, 5, 10]);


=head1 DESCRIPTION


=head1 FAQ

=head2 How do I find closest numbers that are {smaller, larger} than specified number?

You can filter (grep) your list of numbers first, for example to find numbers
that are closest I<and smaller or equal to> 3:

 my @nums = (1, 3, 5, 2, 4);
 @nums = grep {$_ <= 3} @nums;
 my $res = find_closest_number(number => 3, numbers => \@nums);

=head2 How do I find unique closest number(s)?

Perform uniq() (see L<List::MoreUtils>) on the resulting numbers.


=head1 SEE ALSO

L<Number::Closest>. Number::Closest::NonOO is a non-OO version of
Number::Closest, with some additional features: customize handling NaN/Inf, find
farthest number.

=cut
