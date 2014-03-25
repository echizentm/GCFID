#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok('GCFID') };

test_001();

sub test_001 {
    my @values = (0, 32, 33, 255, 256);
    my @ranks  = (0, 1, 2, 3, 4);

    my @list;
    for (0 .. $values[@values - 1]) { $list[$_] = 0 };
    for (@values)                   { $list[$_] = 1 };

    my $fid = GCFID->new();
    ok($fid, 'new()');

    $fid->build(\@list);

    is($fid->total_size(), 257, 'total_size()');
    is($fid->size(1)     , 5  , 'size(1)');
    is($fid->size(0)     , 252, 'size(0)');

    my @result_values;
    my $value = 0;
    while ($value < $fid->total_size()) {
        push(@result_values, $value) if ($fid->lookup($value));
        $value++;
    }
    is_deeply(\@result_values, \@values, 'lookup()');

    my @result_ranks = map { $fid->rank($_); } @values;
    is_deeply(\@result_ranks, \@ranks, 'rank()');

    my @result_selects = map { $fid->select($_); } @ranks;
    is_deeply(\@result_selects, \@values, 'select()');

    done_testing();
}
