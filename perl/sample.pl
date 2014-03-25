#!/usr/bin/perl
use strict;
use warnings;
use GCFID;

my $fid = GCFID->new();
while (my $line = <STDIN>) {
    chomp($line);
    my @list = split(//, $line);
    $fid->build(\@list);

    print 'lookup : '.join(' ', map { $fid->lookup($_); } (0 .. $fid->total_size()))."\n";
    print 'rank   : '.join(' ', map { $fid->rank($_);   } (0 .. $fid->total_size()))."\n";
    print 'select : '.join(' ', map { $fid->select($_); } (0 .. $fid->total_size()))."\n";
}
