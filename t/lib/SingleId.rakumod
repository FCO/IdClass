use IdClass;

class OnlyId does IdClass {
	method prefix { "ONE" }
	method size { 40 }
	method chars { <A B 1 2> }
}
