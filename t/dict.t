use strict;
use warnings;
use Data::Dict 'd';
use Test::More;

# Hash
is d(a => 1, b => 2, c => 3)->{b}, 2, 'right result';
is_deeply {%{d(a => 3, b => 2, c => 1)}}, {a => 3, b => 2, c => 1}, 'right result';
my $dict = d(a => 1, b => 2);
$dict->{c} = 3;
is_deeply {%$dict}, {a => 1, b => 2, c => 3}, 'right result';

# Tap into method chain
is_deeply d(a => 1, b => 2, c => 3)->tap(sub { $_->{b} += 2 })->to_hash, {a => 1, b => 4, c => 3}, 'right result';

# each
$dict = d(a => 3, b => 2, c => 1);
is_deeply [$dict->each], [['a',3], ['b',2], ['c',1]], 'right elements';
$dict = d(a => [3], b => [2], c => [1]);
my @results;
$dict->each(sub { push @results, $_[1][0] });
is_deeply \@results, [3, 2, 1], 'right elements';
@results = ();
$dict->each(sub { push @results, $_[0], $_[1][0] });
is_deeply \@results, ['a', 3, 'b', 2, 'c', 1], 'right elements';

# grep
$dict = d(a => 1, b => 2, c => 3, d => 4, e => 5, f => 6, g => 7, h => 8, i => 9);
is_deeply $dict->grep(qr/[f-i]/)->to_hash, {f => 6, g => 7, h => 8, i => 9},
  'right elements';
is_deeply $dict->grep(sub { $_[0] =~ m/[f-i]/ })->to_hash, {f => 6, g => 7, h => 8, i => 9},
  'right elements';
is_deeply $dict->grep(sub { $_[1] > 5 })->to_hash, {f => 6, g => 7, h => 8, i => 9},
  'right elements';
is_deeply $dict->grep(sub { $_[1] < 5 })->to_hash, {a => 1, b => 2, c => 3, d => 4},
  'right elements';
is_deeply $dict->grep(sub { $_[1] == 5 })->to_hash, {e => 5},
  'right elements';
is_deeply $dict->grep(sub { $_[1] < 1 })->to_hash, {}, 'no elements';
is_deeply $dict->grep(sub { $_[1] > 9 })->to_hash, {}, 'no elements';

# map
$dict = d(a => 1, b => 2, c => 3);
is join('', $dict->map(sub { $_[1] + 1 })), '234', 'right result';
is_deeply {%$dict}, {a => 1, b => 2, c => 3}, 'right elements';
is join('', $dict->map(sub { my $v = $_[1]; $v + 2 })), '345', 'right result';
is_deeply {%$dict}, {a => 1, b => 2, c => 3}, 'right elements';

# size
$dict = d();
is $dict->size, 0, 'right size';
$dict = d('' => undef);
is $dict->size, 1, 'right size';
$dict = d(23 => 23);
is $dict->size, 1, 'right size';
$dict = d(23 => {2 => 3});
is $dict->size, 1, 'right size';
$dict = d(a => 5, b => 4, c => 3, d => 2, e => 1);
is $dict->size, 5, 'right size';
$dict = d(a => 1, a => 2);
is $dict->size, 1, 'right size';

# slice
$dict = d(a => 1, b => 2, c => 3, d => 4, e => 5, f => 6, g => 7, h => 10, i => 9, j => 8);
is_deeply $dict->slice('a')->to_hash,       {a => 1}, 'right result';
is_deeply $dict->slice('b')->to_hash,       {b => 2}, 'right result';
is_deeply $dict->slice('c')->to_hash,       {c => 3}, 'right result';
is_deeply $dict->slice('z')->to_hash,       {z => undef}, 'right result';
is_deeply $dict->slice(qw(b c d))->to_hash, {b => 2, c => 3, d => 4}, 'right result';
is_deeply $dict->slice(qw(g b e))->to_hash, {g => 7, b => 2, e => 5}, 'right result';
is_deeply $dict->slice('g'..'j')->to_hash,  {g => 7, h => 10, i => 9, j => 8}, 'right result';

# transform
$dict = d(a => 1, b => 2, c => 3);
is_deeply $dict->transform(sub { $_[1]++ }), {a => 2, b => 3, c => 4}, 'right result';
is_deeply {%$dict}, {a => 1, b => 2, c => 3}, 'right elements';
is_deeply $dict->transform(sub { $_[1] += 2 }), {a => 3, b => 4, c => 5}, 'right result';
is_deeply {%$dict}, {a => 1, b => 2, c => 3}, 'right elements';

done_testing;
