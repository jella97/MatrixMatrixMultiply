//
//  AppDelegate.m
//  MatrixMatrixMultiplication
//
//  Created by John on 12/11/12.
//  Copyright (c) 2012 IBS. All rights reserved.
//

/*
 void cblas_dgemm (
 const enum CBLAS_ORDER Order,		(Specifies row-major (C) or column-major (Fortran) data ordering: CblasRowMajor, CblasColMajor)
 const enum CBLAS_TRANSPOSE TransA,	(Specifies whether to transpose matrix A: CblasNoTrans, CblasTrans, CblasConjTrans, AtlasConj)
 const enum CBLAS_TRANSPOSE TransB, (Specifies whether to transpose matrix B: CblasNoTrans, CblasTrans, CblasConjTrans, AtlasConj)
 
 const int M, (Number of rows in matrices A and C.)
 const int N, (Number of columns in matrices B and C.)
 const int K, (Number of columns in matrix A; number of rows in matrix B.)
 
 const double alpha, (Scaling factor for the product of matrices A and B.)
 
 const double *A,	(matrix A)
 const int lda,		(The size of the first dimention of matrix A; if you are passing a matrix A[M][K], the value should be M.)
 
 const double *B,	(matrix B)
 const int ldb,		(The size of the first dimention of matrix B; if you are passing a matrix B[K][N], the value should be K.)
 
 const double beta, (beta)
 
 double *C,			(matrix C)
 const int ldc		(The size of the first dimention of matrix C; if you are passing a matrix C[M][N], the value should be M.)
 );
 
 Discussion
 This function multiplies A * B and multiplies the resulting matrix by alpha. It then multiplies matrix C by beta. It stores the sum of these two products in matrix C.
 Thus, it calculates either
 C←αAB + βC
 or
 C←αBA + βC
 with optional use of transposed forms of A, B, or both.
 
 */

/*
 Pass the address of the integer, not the integer itself. appendBytes:length: expects a pointer to a data buffer and the size of the data buffer. In this case, the "data buffer" is the integer.
 
 [myData appendBytes:&myInteger length:sizeof(myInteger)];
 Keep in mind, though, that this will use your computer's endianness to encode it. If you plan on writing the data to a file or sending it across the network, you should use a known endianness instead. For example, to convert from host (your machine) to network endianness, use htonl():
 
 uint32_t theInt = htonl((uint32_t)myInteger);
 [myData appendBytes:&theInt length:sizeof(theInt)];
 
 */

#import "AppDelegate.h"
#import <Accelerate/Accelerate.h>

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    int i; // index for matrix
    
    int M = 10000; // M must be >= MAX(K, 1)  (rows in matrices A and C)                 M = lda = ldc
	int N = 10000; // M >= K >= N             (columns in matrices B and C)
	int K = 10000; // K must be >= MAX(N, 1)  (columns in matrix A; rows in matrix B)    K = ldb
    
	double alpha = 1.0;    // (Scaling factor for the product of matrices A and B.)
    
    double *A = malloc( M * K * sizeof(double));  // (matrix A) M x K
    for ( i = 0; i < M * K; i++ ) A[ i ] = [self getRandomDouble];
    NSLog(@"matrix A created");
    
    double *B = malloc( K * N * sizeof(double));  // (matrix B) K x N
	for ( i = 0; i < K * N; i++ ) B[ i ] = [self getRandomDouble];
    NSLog(@"matrix B created");
    
	double beta = 0.0;
    double *C = malloc( M * N * sizeof(double));  // (matrix C) M x N
    NSLog(@"matrix C malloc");
    
	NSLog(@"start cblas_dgemm");
	// Compute C = A B
	cblas_dgemm (CblasRowMajor, CblasNoTrans, CblasNoTrans,
				 M, N, K,
				 
				 alpha,
				 A, M,
				 B, K,
				 
				 beta,
				 C, M);
	NSLog(@"end cblas_dgemm");
    
    NSLog(@"%f", C[0]);
}


- (double)getRandomDouble
{
	return ( (double)arc4random_uniform(1000) / 1000 );
}
@end
