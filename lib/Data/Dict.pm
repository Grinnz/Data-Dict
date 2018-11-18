package Data::Dict;

use strict;
use warnings;
use Exporter 'import';

our $VERSION = '0.001';

our @EXPORT_OK = 'd';

sub d { __PACKAGE__->new(@_) }

sub new {
  my $class = shift;
  return bless {@_}, ref $class || $class;
}

sub TO_JSON { +{%{$_[0]}} }

sub delete {
  my $self = shift;
  my $deleted = $self->slice(@_);
  delete @$self{keys %$deleted} if keys %$deleted;
  return $deleted;
}

sub each {
  my ($self, $cb) = @_;
  return map { [$_, $self->{$_}] } sort keys %$self unless $cb;
  $cb->($_, $self->{$_}) for sort keys %$self;
  return $self;
}

sub extract {
  my ($self, $cb) = @_;
  return $self->delete(grep { m/$cb/ } sort keys %$self) if ref $cb eq 'Regexp';
  return $self->delete(grep { $cb->($_, $self->{$_}) } sort keys %$self);
}

sub grep {
  my ($self, $cb) = @_;
  return $self->new(map { ($_, $self->{$_}) } grep { m/$cb/ } sort keys %$self) if ref $cb eq 'Regexp';
  return $self->new(map { ($_, $self->{$_}) } grep { $cb->($_, $self->{$_}) } sort keys %$self);
}

sub map {
  my ($self, $cb) = @_;
  return map { $cb->($_, $self->{$_}) } sort keys %$self;
}

sub size { scalar keys %{$_[0]} }

sub slice {
  my $self = shift;
  return $self->new(map { ($_, $self->{$_}) } @_);
}

sub tap {
  my ($self, $cb) = (shift, shift);
  $_->$cb(@_) for $self;
  return $self;
}

sub to_array { [%{$_[0]}] }

sub to_hash { +{%{$_[0]}} }

sub transform {
  my ($self, $cb) = @_;
  return $self->new(map { $cb->($_, $self->{$_}); } sort keys %$self);
}

sub values {
  my ($self, $cb) = (shift, shift);
  return map { $self->{$_} } sort keys %$self unless $cb;
  do { $_->$cb(@_) for $self->{$_} } for sort keys %$self;
  return $self;
}

# define this last because CORE::keys doesn't work before 5.20
sub keys {
  my ($self, $cb) = @_;
  return wantarray ? sort keys %$self : keys %$self unless $cb;
  $cb->($_) for sort keys %$self;
  return $self;
}

1;

=head1 NAME

Data::Dict - Hash-based dictionary object

=head1 SYNOPSIS

  use Data::Dict;

  my $dictionary = Data::Dict->new(a => 1, b => 2, c => 3);
  delete $dictionary->{b};
  print join "\n", $dictionary->keys;

  $dictionary->slice(qw(a b))->grep(sub { defined $_[1] })->each(sub {
    my ($key, $value) = @_;
    print "$key: $value\n";
  });

  use Data::Dict 'd';
  use experimental 'signatures';
  my $num_highest = d(%counts)->transform(sub ($k, $v) { ($k, $v+1) })->grep(sub ($k, $v) { $v > 5 })->size;

=head1 DESCRIPTION

L<Data::Dict> is a hash-based container for dictionaries, with heavy
inspiration from L<Mojo::Collection>.

  # Access hash directly to manipulate dictionary
  my $dict = Data::Dict->new(a => 1, b => 2, c => 3);
  $dict->{b} += 100;
  print "$_\n" for values %$dict;

=head1 FUNCTIONS

=head2 d

  my $dict = d(a => 1, b => 2);

Construct a new hash-based L<Data::Dict> object. Exported on demand.

=head1 METHODS

=head2 new

  my $dict = Data::Dict->new(a => 1, b => 2);

Construct a new hash-based L<Data::Dict> object.

=head2 TO_JSON

Alias for L</"to_hash">.

=head2 delete

  my $deleted = $dict->delete(@keys);

Delete selected keys from the dictionary and return a new dictionary containing
the deleted keys and values.

=head2 each

  my @pairs = $dict->each;
  $dict     = $dict->each(sub {...});

Evaluate callback for each pair in the dictionary in sorted-key order, or
return pairs as list of key/value arrayrefs in sorted-key order if none has
been provided. The callback will receive the key and value as arguments.

  $dict->each(sub {
    my ($key, $value) = @_;
    print "$key: $value\n";
  });

  # values can be modified in place
  $dict->each(sub { $_[1] = $_[0]x2 });

=head2 extract

  my $extracted = $dict->extract(qr/foo/);
  my $extracted = $dict->extract(sub {...});

Evaluate regular expression on each key, or call callback on each key/value
pair in the dictionary in sorted-key order, and remove all pairs that matched
the regular expression, or for which the callback returned true. Return a new
dictionary with the removed keys and values. The callback will receive the key
and value as arguments.

  my $high_numbers = $dict->extract(sub { $_[1] > 100 });

=head2 grep

  my $new = $dict->grep(qr/foo/);
  my $new = $dict->grep(sub {...});

Evaluate regular expression on each key, or call callback on each key/value
pair in the dictionary in sorted-key order, and return a new dictionary with
all pairs that matched the regular expression, or for which the callback
returned true. The callback will receive the key and value as arguments.

  my $banana_dict = $dict->grep(qr/banana/);

  my $fruits_dict = $dict->grep(sub { $_[1]->isa('Fruit') });

=head2 keys

  my @keys = $dict->keys;
  $dict    = $dict->keys(sub {...});

Evaluate callback for each key in the dictionary in sorted-key order, or return
all keys as a sorted list if none has been provided. The key will be the first
argument passed to the callback, and is also available as C<$_>.

=head2 map

  my @results = $dict->map(sub { ... });

Evaluate callback for each key/value pair in the dictionary in sorted-key order
and return the results as a list. The callback will receive the key and value
as arguments.

  my @pairs = $dict->map(sub { [@_] });

  my @values = $dict->map(sub { $_[1] });

=head2 size

  my $size = $dict->size;

Number of keys in dictionary.

=head2 slice

  my $new = $dict->slice(@keys);

Create a new dictionary with all selected keys.

  print join ' ', d(a => 1, b => 2, c => 3)->slice('a', 'c')->map(sub { join ':', @_ });
  # a:1 c:3

=head2 tap

  $dict = $dict->tap(sub {...});

Perform callback and return the dictionary object for further chaining, as in
L<Mojo::Base/"tap">. The dictionary object will be the first argument passed to
the callback, and is also available as C<$_>.

=head2 to_array

  my $array = $dict->to_array;

Turn dictionary into even-sized array reference in sorted-key order.

=head2 to_hash

  my $hash = $dict->to_hash;

Turn dictionary into hash reference.

=head2 transform

  my $new = $dict->transform(sub { ... });

Evaluate callback for each key/value pair in the dictionary in sorted-key order
and create a new dictionary from the returned keys and values (assumed to be an
even-sized key/value list). The callback will receive the key and value as
arguments.

  my $reversed = $dict->transform(sub { ($_[1], $_[0]) });

  my $doubled = $dict->transform(sub {
    my ($k, $v) = @_;
    return ($k => $v, ${k}x2 => $v);
  });

=head2 values

  my @values = $dict->values;
  $dict      = $dict->values(sub {...});

Evaluate callback for each value in the dictionary in sorted-key order, or
return all values as a list in sorted-key order if none has been provided. The
value will be the first argument passed to the callback, and is also available
as C<$_>.

  # values can be modified in place
  $dict->values(sub { $_++ });

=head1 BUGS

Report any issues on the public bugtracker.

=head1 AUTHOR

Dan Book <dbook@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Dan Book.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=head1 SEE ALSO

L<Mojo::Collection>
