[![Actions Status](https://github.com/FCO/IdClass/actions/workflows/test.yml/badge.svg)](https://github.com/FCO/IdClass/actions)

NAME
====

IdClass - role for typed string IDs

SYNOPSIS
========

```raku
use IdClass;

class BlaId does IdClass {
    method prefix { "BLA" }
}

my BlaId $id = BlaId.new;
say $id;              # BLA-<ts>-<rest>

my Str $raw = $id.Str;
my BlaId $from-str = BlaId($raw);
say $from-str === $id; # True

sub load-item(BlaId() $item-id) {
    say "loading {$item-id}";
}

load-item $raw;   # coerces Str into BlaId
```

DESCRIPTION
===========

IdClass provides a compact, typed identifier object with predictable string format and fast coercion from strings. The default string representation is:

    PREFIX-TS-REST

Where `PREFIX` is a short, human-readable prefix, `TS` is a time-based segment, and `REST` is a random segment. The role is used directly in a class with custom methods like `prefix`, `size`, `chars`, and `ts-scale`.

ROLE
====

Use the role directly in a class and override the configuration methods when needed.

METHODS
=======

prefix
------

```raku
method prefix
```

Returns the prefix string. Override this method in your class to supply the prefix.

size
----

```raku
method size
```

Returns the total size target used to compute the random segment length. The default is 40.

chars
-----

```raku
method chars
```

Returns the character list used to generate the random segment.

ts-scale
--------

```raku
method ts-scale
```

Returns the numeric scale applied to `now` when generating the timestamp segment. The default is 1000000.

Str
---

```raku
method Str
```

Returns the canonical string representation `PREFIX-TS-REST`.

gist
----

```raku
method gist
```

Same as `Str`.

COERCE
------

```raku
method COERCE(Str $id)
```

Coerces a string into the current class when the prefix matches. Coercion into `IdClass` itself is not implemented yet; only class-specific coercion is supported.

WHICH
-----

```raku
method WHICH
```

Provides identity semantics based on the class name and string value.

FUNCTIONS
=========

There are no helper factory functions. Define a class that does `IdClass` directly.

COERCION RULES
==============

- A string must match `PREFIX-TS-REST` with three word-like segments. - If coercing into a specific IdClass-derived type, the prefix must match. - Coercion into `IdClass` itself is not implemented yet. - Invalid strings throw an exception.

EXAMPLES
========

```raku
use IdClass;

class UserId does IdClass {
    method prefix { "USR" }
}

class SessionId does IdClass {
    method prefix { "SES" }
}

class ShortId does IdClass {
    method prefix { "SHR" }
    method size   { 20 }
    method chars  { <A B C 1 2 3> }
}

class FastId does IdClass {
    method prefix            { "FST" }
    method ts-scale          { 1000 }
}

my UserId $user-id = UserId.new;
my Str $stored = $user-id.Str;      # save to storage

# Later: restore from storage
my UserId $restored = UserId($stored);

# Function parameters can coerce from Str
sub open-session(SessionId() $sid) {
    say "open {$sid}";
}

open-session SessionId.new.Str;
```

SEE ALSO
========

Raku Pod6/Rakudoc: https://docs.raku.org/language/pod

