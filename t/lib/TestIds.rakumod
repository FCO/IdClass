use IdClass;

class CustomerId does IdClass {
	method prefix { "CustomerId" }
}

class InvoiceId does IdClass {
	method prefix { "INV" }
	method size { 40 }
	method chars { <A B C 1 2 3> }
}
