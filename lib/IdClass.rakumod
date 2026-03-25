unit role IdClass;

has Str $.ts   = self!ts;
has Str $.rest = self!gen-rest;

method !to-base64(Int() $int --> Str) {
	self.chars[$int.polymod(self.chars.elems xx *).reverse].join;
}

method !gen-rest(UInt $size where $size > 1 = $.size) {
	my $diff      = 2 + $.ts.chars + self.prefix.chars;
	my $rest-size = $size - $diff;
	die "Id size is too small" if $rest-size < 1;
	my $id = self.chars.roll($rest-size).join;
	$id
}

method size { 40 }

method chars { |^10, |("A".."Z"), |("a".."z") }

method ts-scale { 1000000 }

method !ts {
	my $ts = floor now * $.ts-scale;
	self!to-base64: $ts;
}

multi method Str(::?CLASS:D:) { "{$.prefix}-{$!ts}-{$!rest}" }
multi method gist(::?CLASS:D:) { $.Str }

multi method COERCE(Str $id where *.starts-with: $.prefix) {
	if $id ~~ /^ \w+ "-" (\w+) "-" (\w+) $/ {
		return self.new: :ts(~$0), :rest(~$1)
	}
	die "'$id' is not a valid id"
}

multi method WHICH(::?CLASS:D:) { ValueObjAt.new: "{self.^name}|{self.Str}" }
multi method WHICH(::?CLASS:U:) { ValueObjAt.new: self.^name }
