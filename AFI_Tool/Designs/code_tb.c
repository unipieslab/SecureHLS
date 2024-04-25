/* compute tables of Sbox & its inverse; print 'em out */
#include <stdio.h>
#include <stdint.h>

int main() {

	uint8_t input = 208; //0xd0

	uint16_t output = top_function(input);


	printf("%x is %x\n", input,output);


	/*
	for (int i = 0; i < 256; i = i + 1) {

		Sbox_val = Sbox(i);

	}
	*/

	return 0;
}
