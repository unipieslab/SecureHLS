/* sbox.c
 *
 * by: David Canright
 *
 * illustrates compact implementation of AES S-box via subfield operations
 *   case # 4 : [d^16, d], [alpha^8, alpha^2], [Omega^2, Omega]
 *   nu = beta^8 = N^2*alpha^2, N = w^2
 */

#include <stdio.h>
#include <stdint.h>
#include <sys/types.h>

/* to convert between polynomial (A^7...1) basis A & normal basis X */
/* or to basis S which incorporates bit matrix of Sbox */
static uint8_t A2X_1[8] = { 0x98, 0xF3, 0xF2, 0x48, 0x09, 0x81, 0xA9, 0xFF };
static uint8_t X2S_1[8] = { 0x58, 0x2D, 0x9E, 0x0B, 0xDC, 0x04, 0x03, 0x24 };

static uint8_t A2X_2[8] = { 0x98, 0xF3, 0xF2, 0x48, 0x09, 0x81, 0xA9, 0xFF };
static uint8_t X2S_2[8] = { 0x58, 0x2D, 0x9E, 0x0B, 0xDC, 0x04, 0x03, 0x24 };

/* multiply in GF(2^2), using normal basis (Omega^2,Omega) */
uint8_t G4_mul_1(uint8_t x, uint8_t y) {
	uint8_t a, b, c, d, e, p, q;

	a = (x & 0x2) >> 1;
	b = (x & 0x1);
	c = (y & 0x2) >> 1;
	d = (y & 0x1);
	e = (a ^ b) & (c ^ d);
	p = (a & c) ^ e;
	q = (b & d) ^ e;
	return ((p << 1) | q);
}

/* scale by N = Omega^2 in GF(2^2), using normal basis (Omega^2,Omega) */
uint8_t G4_scl_N_1(uint8_t x) {
	uint8_t a, b, p, q;

	a = (x & 0x2) >> 1;
	b = (x & 0x1);
	p = b;
	q = a ^ b;
	return ((p << 1) | q);
}

/* scale by N^2 = Omega in GF(2^2), using normal basis (Omega^2,Omega) */
uint8_t G4_scl_N2_1(uint8_t x) {
	uint8_t a, b, p, q;

	a = (x & 0x2) >> 1;
	b = (x & 0x1);
	p = a ^ b;
	q = a;
	return ((p << 1) | q);
}

/* square in GF(2^2), using normal basis (Omega^2,Omega) */
/* NOTE: inverse is identical */
uint8_t G4_sq_1(uint8_t x) {
	uint8_t a, b;

	a = (x & 0x2) >> 1;
	b = (x & 0x1);
	return ((b << 1) | a);
}

/* multiply in GF(2^4), using normal basis (alpha^8,alpha^2) */
uint8_t G16_mul_1(uint8_t x, uint8_t y) {
	uint8_t a, b, c, d, e, p, q;

	a = (x & 0xC) >> 2;
	b = (x & 0x3);
	c = (y & 0xC) >> 2;
	d = (y & 0x3);
	e = G4_mul_1(a ^ b, c ^ d);
	e = G4_scl_N_1(e);
	p = G4_mul_1(a, c) ^ e;
	q = G4_mul_1(b, d) ^ e;
	return ((p << 2) | q);
}

/* square & scale by nu in GF(2^4)/GF(2^2), normal basis (alpha^8,alpha^2) */
/*   nu = beta^8 = N^2*alpha^2, N = w^2 */
uint8_t G16_sq_scl_1(uint8_t x) {
	uint8_t a, b, p, q;

	a = (x & 0xC) >> 2;
	b = (x & 0x3);
	p = G4_sq_1(a ^ b);
	q = G4_scl_N2_1(G4_sq_1(b));
	return ((p << 2) | q);
}

/* inverse in GF(2^4), using normal basis (alpha^8,alpha^2) */
uint8_t G16_inv_1(uint8_t x) {
	uint8_t a, b, c, d, e, p, q;

	a = (x & 0xC) >> 2;
	b = (x & 0x3);
	c = G4_scl_N_1(G4_sq_1(a ^ b));
	d = G4_mul_1(a, b);
	e = G4_sq_1(c ^ d);   // really inverse, but same as square
	p = G4_mul_1(e, b);
	q = G4_mul_1(e, a);

	return ((p << 2) | q);
}

/* inverse in GF(2^8), using normal basis (d^16,d) */
uint8_t G256_inv_1(uint8_t x) {
	uint8_t a, b, c, d, e, p, q;

	a = (x & 0xF0) >> 4;
	b = (x & 0x0F);
	c = G16_sq_scl_1(a ^ b);
	d = G16_mul_1(a, b);
	e = G16_inv_1(c ^ d);
	p = G16_mul_1(e, b);
	q = G16_mul_1(e, a);

	return ((p << 4) | q);
}

/* convert to new basis in GF(2^8) */
/* i.e., bit matrix multiply */
uint8_t G256_newbasis_1(uint8_t x, uint8_t b[]) {
	uint8_t y = 0;

	label_0: for (int i = 7; i >= 0; --i) {
		if (x & 1)
			y ^= b[i];
		x >>= 1;
	}
	return (y);
}


/* multiply in GF(2^2), using normal basis (Omega^2,Omega) */
uint8_t G4_mul_2(uint8_t x, uint8_t y) {
	uint8_t a, b, c, d, e, p, q;

	a = (x & 0x2) >> 1;
	b = (x & 0x1);
	c = (y & 0x2) >> 1;
	d = (y & 0x1);
	e = (a ^ b) & (c ^ d);
	p = (a & c) ^ e;
	q = (b & d) ^ e;
	return ((p << 1) | q);
}

/* scale by N = Omega^2 in GF(2^2), using normal basis (Omega^2,Omega) */
uint8_t G4_scl_N_2(uint8_t x) {
	uint8_t a, b, p, q;

	a = (x & 0x2) >> 1;
	b = (x & 0x1);
	p = b;
	q = a ^ b;
	return ((p << 1) | q);
}

/* scale by N^2 = Omega in GF(2^2), using normal basis (Omega^2,Omega) */
uint8_t G4_scl_N2_2(uint8_t x) {
	uint8_t a, b, p, q;

	a = (x & 0x2) >> 1;
	b = (x & 0x1);
	p = a ^ b;
	q = a;
	return ((p << 1) | q);
}

/* square in GF(2^2), using normal basis (Omega^2,Omega) */
/* NOTE: inverse is identical */
uint8_t G4_sq_2(uint8_t x) {
	uint8_t a, b;

	a = (x & 0x2) >> 1;
	b = (x & 0x1);
	return ((b << 1) | a);
}

/* multiply in GF(2^4), using normal basis (alpha^8,alpha^2) */
uint8_t G16_mul_2(uint8_t x, uint8_t y) {
	uint8_t a, b, c, d, e, p, q;

	a = (x & 0xC) >> 2;
	b = (x & 0x3);
	c = (y & 0xC) >> 2;
	d = (y & 0x3);
	e = G4_mul_2(a ^ b, c ^ d);
	e = G4_scl_N_2(e);
	p = G4_mul_2(a, c) ^ e;
	q = G4_mul_2(b, d) ^ e;
	return ((p << 2) | q);
}

/* square & scale by nu in GF(2^4)/GF(2^2), normal basis (alpha^8,alpha^2) */
/*   nu = beta^8 = N^2*alpha^2, N = w^2 */
uint8_t G16_sq_scl_2(uint8_t x) {
	uint8_t a, b, p, q;

	a = (x & 0xC) >> 2;
	b = (x & 0x3);
	p = G4_sq_2(a ^ b);
	q = G4_scl_N2_2(G4_sq_2(b));
	return ((p << 2) | q);
}

/* inverse in GF(2^4), using normal basis (alpha^8,alpha^2) */
uint8_t G16_inv_2(uint8_t x) {
	uint8_t a, b, c, d, e, p, q;

	a = (x & 0xC) >> 2;
	b = (x & 0x3);
	c = G4_scl_N_2(G4_sq_2(a ^ b));
	d = G4_mul_2(a, b);
	e = G4_sq_2(c ^ d);   // really inverse, but same as square
	p = G4_mul_2(e, b);
	q = G4_mul_2(e, a);

	return ((p << 2) | q);
}

/* inverse in GF(2^8), using normal basis (d^16,d) */
uint8_t G256_inv_2(uint8_t x) {
	uint8_t a, b, c, d, e, p, q;

	a = (x & 0xF0) >> 4;
	b = (x & 0x0F);
	c = G16_sq_scl_2(a ^ b);
	d = G16_mul_2(a, b);
	e = G16_inv_2(c ^ d);
	p = G16_mul_2(e, b);
	q = G16_mul_2(e, a);

	return ((p << 4) | q);
}

/* convert to new basis in GF(2^8) */
/* i.e., bit matrix multiply */
uint8_t G256_newbasis_2(uint8_t x, uint8_t b[]) {
	uint8_t y = 0;

	label_0: for (int i = 7; i >= 0; --i) {
		if (x & 1)
			y ^= b[i];
		x >>= 1;
	}
	return (y);
}



uint8_t Sbox_1(uint8_t input) {
#pragma HLS INTERFACE ap_ctrl_hs register port=return

	uint8_t t;

	t = G256_newbasis_1(input, A2X_1);

	t = G256_inv_1(t);

	t = G256_newbasis_1(t, X2S_1);


	return (t ^ 0x63);
}

uint8_t Sbox_2(uint8_t input) {
#pragma HLS INTERFACE ap_ctrl_hs register port=return

	uint8_t t;

	t = G256_newbasis_2(input, A2X_2);

	t = G256_inv_2(t);

	t = G256_newbasis_2(t, X2S_2);


	return (t ^ 0x63);
}


uint16_t top_function(uint8_t input) {


	return (Sbox_2(input)<<8) ^ Sbox_1(input);

}

