void main(){
	bool test_opr = false;
	bool a = true, b = false;

	test_opr = (a == b);
	test_opr = (b && a);
	test_opr = (b || a);
	test_opr = (false && true);
	test_opr = (true || false);
	test_opr = (1 <= 0);
	test_opr = (1 >= 0);
	test_opr = ( 1 == 0);
	test_opr = (a == b);
	test_opr = (test_opr == a);
}

