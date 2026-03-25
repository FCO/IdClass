my %types;

my @default-chars = (|^10, |("A".."Z"), |("a".."z"));

unit role IdClass[Str $prefix = "", UInt $size = 40, @chars = @default-chars];

sub to-base64(Int() $int --> Str) {
	my @use-chars = @chars.elems ?? @chars !! @default-chars;
	@use-chars[$int.polymod(@use-chars.elems xx *).reverse].join;
}

sub ts {
	my $ts = floor now * 1000000;
	to-base64 $ts;
}

sub gen-id(UInt $size where $size > 1 = 30) {
	my $id = @default-chars.roll($size).join;
	$id
}

method prefix { $prefix }
has Str $.ts     = ts;
has Str $.rest   = gen-id(($size // 40) - 1 - $!ts.chars);

multi method Str(::?CLASS:D:) { "{$.prefix}-{$!ts}-{$!rest}" }
multi method gist(::?CLASS:D:) { $.Str }

multi method COERCE(Str $id where { $prefix && .starts-with: $prefix }) {
	if $id ~~ /^ (\w+) "-" (\w+) "-" (\w+) $/ {
		return self.new: :ts(~$1), :rest(~$2)
	}
	die "'$id' is not a valid id"
}

multi method COERCE(\SELF where { .WHAT !=:= IdClass }: Str $id where { $.prefix && .starts-with: $.prefix }) {
	if $id ~~ /^ (\w+) "-" (\w+) "-" (\w+) $/ && $0 eq $.prefix {
		return self.new: :ts(~$1), :rest(~$2)
	}
	die "'$id' is not a valid id"
}

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

quietly %types{$prefix || ::?CLASS.?prefix} := ::?CLASS;
sub id-class(Str $name, Str $prefix = $name, UInt $size?, @chars?) is export {
	my \id-class-type = Metamodel::ClassHOW.new_type: :$name;
	id-class-type.^add_role: IdClass[$prefix, $size, @chars];
	id-class-type.^compose;
	return id-class-type
}
