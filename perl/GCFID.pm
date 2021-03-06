package GCFID;
use strict;
use warnings;

sub new {
    my ($class, $self) = @_;
    $self = {} unless ($self);
    return bless($self, $class);
}

sub build {
    my ($self, $list) = @_;

    $self->{grammar} = [
        { left => -1, right => -1, length => 1, rank => 0 },
        { left => -1, right => -1, length => 1, rank => 1 },
    ];
    while (@$list > 1) { $list = $self->_compress($list); }
}

sub total_size {
    my ($self) = @_;
    return $self->{grammar}[@{$self->{grammar}} - 1]{length};
}

sub size {
    my ($self, $bit) = @_;
    my $value = $self->{grammar}[@{$self->{grammar}} - 1]{rank};
    return $bit ? $value : ($self->total_size() - $value);
}

sub lookup {
    my ($self, $pos) = @_;
    return $self->_search($pos, 'lookup');
}

sub rank {
    my ($self, $pos) = @_;
    return $self->_search($pos, 'rank');
}

sub select {
    my ($self, $pos) = @_;
    return $self->_search($pos, 'select');
}

sub _compress {
    my ($self, $list) = @_;

    my %dic;
    for my $i (0 .. (@$list - 2)) {
        $dic{"$list->[$i] $list->[$i + 1]"}++;
    }
    my @sorted = sort { $dic{$b} <=> $dic{$a} } keys %dic;
    my ($left, $right) = split(/ /, $sorted[0]);
    push(@{$self->{grammar}}, {
        left   => $left,
        right  => $right,
        length => $self->{grammar}[$left]{length} + $self->{grammar}[$right]{length},
        rank   => $self->{grammar}[$left]{rank}   + $self->{grammar}[$right]{rank},
    });

    my @new_list;
    my $skip = 0;
    for my $i (0 .. (@$list - 1)) {
        if ($skip) { $skip = 0; next; }
        if ($i < (@$list - 1) and "$list->[$i] $list->[$i + 1]" eq $sorted[0]) {
            push(@new_list, @{$self->{grammar}} - 1);
            $skip = 1;
        } else {
            push (@new_list, $list->[$i]);
        }
    }
    return \@new_list;
}

sub _search {
    my ($self, $pos, $mode) = @_;

    my $g = $self->{grammar}[@{$self->{grammar}} - 1];
    return 0          if ($mode eq 'lookup' and $pos >= $g->{length});
    return $g->{rank} if ($mode eq 'rank'   and $pos >= $g->{length});
    return -1         if ($mode eq 'select' and $pos >= $g->{rank});

    my $value = 0;
    while (1) {
        my $left_length = $self->{grammar}[$g->{left}]{length};
        my $left_rank   = $self->{grammar}[$g->{left}]{rank};
        if ($pos < (($mode eq 'select') ? $left_rank : $left_length)) {
            $g = $self->{grammar}[$g->{left}];
        } else {
            $value += (($mode eq 'select') ? $left_length : $left_rank);
            $pos   -= (($mode eq 'select') ? $left_rank   : $left_length);
            $g      = $self->{grammar}[$g->{right}];
        }
        last if ($g->{length} == 1);
    }
    return ($mode eq 'lookup') ? $g->{rank} : $value;
}

1;
