use strict;
use warnings;
use Test::Needs 'Mojo::Collection';
use Test::More;
use Data::Dict 'd';
use Scalar::Util 'blessed';

# each_c
my $dict = d(a => 3, b => 2, c => 1);
my $c = $dict->each_c;
ok blessed($c) && $c->isa('Mojo::Collection'), 'collection object';
is_deeply [map { [@$_] } @$c], [['a',3], ['b',2], ['c',1]], 'right elements';

# keys_c
$dict = d();
$c = $dict->keys_c;
ok blessed($c) && $c->isa('Mojo::Collection'), 'collection object';
is @$c, 0, 'no keys';
is_deeply [@$c], [], 'no keys';
$dict = d(a => 3, b => 2, c => 1);
$c = $dict->keys_c;
ok blessed($c) && $c->isa('Mojo::Collection'), 'collection object';
is @$c, 3, 'right number of keys';
is_deeply [@$c], [qw(a b c)], 'right keys';

# map_c
$dict = d(a => 1, b => 2, c => 3);
$c = $dict->map_c(sub { $_[1] + 1 });
ok blessed($c) && $c->isa('Mojo::Collection'), 'collection object';
is join('', @$c), '234', 'right result';
$c = $dict->map_c(sub { my $v = $_[1]; $v + 2 });
ok blessed($c) && $c->isa('Mojo::Collection'), 'collection object';
is join('', @$c), '345', 'right result';

# values_c
$dict = d();
$c = $dict->values_c;
ok blessed($c) && $c->isa('Mojo::Collection'), 'collection object';
is @$c, 0, 'no values';
is_deeply [@$c], [], 'no values';
$dict = d(a => 3, b => 2, c => 1);
$c = $dict->values_c;
ok blessed($c) && $c->isa('Mojo::Collection'), 'collection object';
is @$c, 3, 'right number of values';
is_deeply [@$c], [qw(3 2 1)], 'right values';

done_testing;
