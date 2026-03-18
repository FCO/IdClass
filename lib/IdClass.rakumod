my %types;
 
=begin pod

=head1 NAME

IdClass - lightweight typed identifiers with prefixes

=head1 SYNOPSIS

=begin code :lang<raku>

use IdClass;

my $UserId = id-class('UserId', 'usr');
my $OrderId = id-class('OrderId', 'ord', 36);

my $uid = $UserId.new;
say $uid.Str;          # usr-<timestamp>-<random>
say $uid.gist;         # same as Str

my $oid = $OrderId.new;
my IdClass() $from = $uid.Str;

=end code

=head1 DESCRIPTION

IdClass provides a role that generates compact, sortable, and
type-dispatchable identifiers using a prefix, a timestamp, and a random
suffix. Each id has the format:

=code <prefix>-<timestamp>-<random>

The timestamp is encoded in a base-like alphabet (default digits and
ASCII letters). The random part is generated from the same alphabet by
default, and the total length can be tuned per id class.

=head1 EXPORTS

=head2 id-class

=begin code :lang<raku>

sub id-class(Str $name, Str $prefix = $name, UInt $size?, @chars?) is export

=end code

Creates and returns a new id class type. The type composes the IdClass role
with the provided parameters and is registered for COERCE lookups by prefix.

=head1 ROLE PARAMETERS

=head2 $prefix

String used as the id prefix. Also used to register the type for COERCE.

=head2 $size

Total size for the id body. The final output length includes the prefix and
two dashes. The timestamp portion is generated first and the remaining
characters are used for the random suffix.

=head2 @chars

Alphabet used for timestamp encoding and random generation. Defaults to
digits plus ASCII letters.

=head1 METHODS

=head2 Str

Stringifies the id as C<prefix-timestamp-random>.

=head2 gist

Returns the same output as C<Str>.

=head2 COERCE

=begin code :lang<raku>

my IdClass() $id = 'usr-...';

=end code

Parses a string and returns a new instance of the matching id class when
used through type constraints. Dies if the string is not a valid id.

=head2 export

On IdClass type, returns a map of exported id classes for convenient import.

=head1 USAGE

=head2 Basic id types

=begin code :lang<raku>

my $UserId = id-class('UserId', 'usr');
my $InvoiceId = id-class('InvoiceId', 'inv', 48);

my $user = $UserId.new;
say $user.Str;  # usr-...

=end code

=head2 Parsing and validation

=begin code :lang<raku>

my $value = 'usr-abc-def';
my IdClass() $id = $value;  # returns a UserId instance

# invalid prefix or format throws

=end code

=head2 Custom alphabets

=begin code :lang<raku>

my @chars = <A B C D E F 0 1 2 3>;
my $ShortId = id-class('ShortId', 'sh', 24, @chars);

=end code

=head2 Exporting and importing types

=begin code :lang<raku>

# in Ids.rakumod
use IdClass;

id-class('CustomerId');
id-class('InvoiceId', 'INV');

sub EXPORT() { IdClass.export }

# in app.rakumod
use Ids;

my $customer = CustomerId.new;
my $invoice = InvoiceId.new;

=end code

=head1 USE CASES

=item Domain-specific ids (UserId, OrderId, InvoiceId) with fast type checks

=item Readable prefixes for debugging, logging, and tracing

=item Sortable ids using timestamp-first encoding

=item Compact ids without external dependencies

=head1 NOTES

=item The random suffix is generated from C<@default-chars> in this module.

=item C<COERCE> only succeeds for prefixes registered with C<id-class>.

=end pod

my @default-chars = (|^10, |("A".."Z"), |("a".."z"));

unit role IdClass[Str $prefix = "", UInt $size = 40, @chars = @default-chars];

sub to-base64(Int() $int --> Str) {
	my @use-chars = @chars.elems ?? @chars !! @default-chars;
	@use-chars[$int.polymod(@use-chars xx *).reverse].join;
}

sub ts {
	my $ts = floor now * 1000000;
	to-base64 $ts;
}

sub gen-id(UInt $size where $size > 1 = 30) {
	my $id = @default-chars.roll($size).join;
	$id
}

has Str $.prefix = $prefix;
has Str $.ts     = ts;
has Str $.rest   = gen-id(($size // 40) - 1 - $!ts.chars);

multi method Str(::?CLASS:D:) { "{$prefix}-{$!ts}-{$!rest}" }
multi method gist(::?CLASS:D:) { $.Str }

multi method COERCE(Str $id) {
	if $id ~~ /^ (\w+) "-" (\w+) "-" (\w+) $/ {
		return unless %types{~$0}:exists;
		return %types{~$0}.new: :prefix(~$0), :ts(~$1), :rest(~$2)
	}
	die "'$id' is not a valid id"
}

multi method WHICH(::?CLASS:D:) { ValueObjAt.new: "{self.^name}|{self.Str}" }
multi method WHICH(::?CLASS:U:) { ValueObjAt.new: self.^name }

multi method export(IdClass:U \SELF where {.^name eq "IdClass"}:) {
	Map.new: %types.values.map: {
		.^name => .self
	}
}

multi method export(IdClass:U:) {
	Map.new: ($.^name => self)
}

sub id-class(Str $name, Str $prefix = $name, UInt $size?, @chars?) is export {
	my \id-class-type = Metamodel::ClassHOW.new_type: :$name;
	id-class-type.^add_role: IdClass[$prefix, $size, @chars];
	id-class-type.^compose;
	%types{$prefix} := id-class-type;
	# CALLER::PACKAGE::{$name} := id-class-type;
	return id-class-type
}
