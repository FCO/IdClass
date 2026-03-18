use IdClass;

my \OnlyId = id-class("OnlyId", "ONE", 30, <A B 1 2>);

sub EXPORT() { OnlyId.export }
