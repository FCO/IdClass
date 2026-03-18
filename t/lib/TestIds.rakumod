use IdClass;

id-class("CustomerId");
id-class("InvoiceId", "INV", 35, <A B C 1 2 3>);

sub EXPORT() { IdClass.export }
