[![Actions Status](https://github.com/FCO/IdClass/actions/workflows/test.yml/badge.svg)](https://github.com/FCO/IdClass/actions)

NAME
====

IdClass - role and factory for typed string IDs

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

# Optional factory for a new type
my \OrderId = id-class "OrderId";
my OrderId $order-id = OrderId.new;
```

DESCRIPTION
===========

IdClass provides a compact, typed identifier object with predictable string format and fast coercion from strings. The default string representation is:

    PREFIX-TS-REST

Where `PREFIX` is a short, human-readable prefix, `TS` is a time-based segment, and `REST` is a random segment. The role can be used directly in a class with a custom `prefix` method, or via the `id-class` factory.

ROLE
====

```raku
role IdClass[Str $prefix = "", UInt $size = 40, @chars = @default-chars]
```

The role parameter `$prefix` sets a default prefix used for stringification and coercion. The generated identifier length depends on `$size` and the current timestamp length. The optional `@chars` controls the character set used for the random portion when generating identifiers.

METHODS
=======

prefix
------

```raku
method prefix
```

Returns the prefix string. When using the role without a fixed parameter, you can override this method in your class to supply the prefix.

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

Coerces a string into an appropriate IdClass-derived type based on the prefix in the string, or into the current class when the prefix matches.

WHICH
-----

```raku
method WHICH
```

Provides identity semantics based on the class name and string value.

FUNCTIONS
=========

id-class
--------

```raku
id-class(Str $name, Str $prefix = $name, UInt $size?, @chars?)
```

Creates a new class with the given name that does `IdClass` and uses `$prefix` for its string representation. The returned type can be stored with a sigiled lexical (`\TypeName`) and used like any class.

EXPORTS
=======

Using `IdClass` exports a mapping of known IdClass-derived types. This is used internally for coercion by prefix when only a string is provided.

COERCION RULES
==============

- A string must match `PREFIX-TS-REST` with three word-like segments. - If coercing into a specific IdClass-derived type, the prefix must match. - If coercing into `IdClass` itself, the prefix selects the registered type. - Invalid strings throw an exception.

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

my UserId $user-id = UserId.new;
my Str $stored = $user-id.Str;      # save to storage

# Later: restore from storage
my UserId $restored = UserId($stored);

# Function parameters can coerce from Str
sub open-session(SessionId() $sid) {
    say "open {$sid}";
}

open-session SessionId.new.Str;

# Parse a generic string into the right type
my IdClass $any = IdClass($stored);
say $any.^name;                     # UserId
```

SEE ALSO
========

Raku Pod6/Rakudoc: https://docs.raku.org/language/pod

