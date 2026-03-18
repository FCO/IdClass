[![Actions Status](https://github.com/FCO/IdClass/actions/workflows/test.yml/badge.svg)](https://github.com/FCO/IdClass/actions)

NAME
====

IdClass - lightweight typed identifiers with prefixes

SYNOPSIS
========

```raku
use IdClass;

my $UserId = id-class('UserId', 'usr');
my $OrderId = id-class('OrderId', 'ord', 36);

my $uid = $UserId.new;
say $uid.Str;          # usr-<timestamp>-<random>
say $uid.gist;         # same as Str

my $oid = $OrderId.new;
my IdClass() $from = $uid.Str;
```

DESCRIPTION
===========

IdClass provides a role that generates compact, sortable, and type-dispatchable identifiers using a prefix, a timestamp, and a random suffix. Each id has the format:

    <prefix>-<timestamp>-<random>

The timestamp is encoded in a base-like alphabet (default digits and ASCII letters). The random part is generated from the same alphabet by default, and the total length can be tuned per id class.

EXPORTS
=======

id-class
--------

```raku
sub id-class(Str $name, Str $prefix = $name, UInt $size?, @chars?) is export
```

Creates and returns a new id class type. The type composes the IdClass role with the provided parameters and is registered for COERCE lookups by prefix.

ROLE PARAMETERS
===============

$prefix
-------

String used as the id prefix. Also used to register the type for COERCE.

$size
-----

Total size for the id body. The final output length includes the prefix and two dashes. The timestamp portion is generated first and the remaining characters are used for the random suffix.

@chars
------

Alphabet used for timestamp encoding and random generation. Defaults to digits plus ASCII letters.

METHODS
=======

Str
---

Stringifies the id as `prefix-timestamp-random`.

gist
----

Returns the same output as `Str`.

COERCE
------

```raku
my IdClass() $id = 'usr-...';
```

Parses a string and returns a new instance of the matching id class when used through type constraints. Dies if the string is not a valid id.

export
------

On IdClass type, returns a map of exported id classes for convenient import.

USAGE
=====

Basic id types
--------------

```raku
my $UserId = id-class('UserId', 'usr');
my $InvoiceId = id-class('InvoiceId', 'inv', 48);

my $user = $UserId.new;
say $user.Str;  # usr-...
```

Parsing and validation
----------------------

```raku
my $value = 'usr-abc-def';
my IdClass() $id = $value;  # returns a UserId instance

# invalid prefix or format throws
```

Custom alphabets
----------------

```raku
my @chars = <A B C D E F 0 1 2 3>;
my $ShortId = id-class('ShortId', 'sh', 24, @chars);
```

Exporting and importing types
-----------------------------

```raku
# in Ids.rakumod
use IdClass;

id-class('CustomerId');
id-class('InvoiceId', 'INV');

sub EXPORT() { IdClass.export }

# in app.rakumod
use Ids;

my $customer = CustomerId.new;
my $invoice = InvoiceId.new;
```

USE CASES
=========

  * Domain-specific ids (UserId, OrderId, InvoiceId) with fast type checks

  * Readable prefixes for debugging, logging, and tracing

  * Sortable ids using timestamp-first encoding

  * Compact ids without external dependencies

NOTES
=====

  * The random suffix is generated from `@default-chars` in this module.

  * `COERCE` only succeeds for prefixes registered with `id-class`.

