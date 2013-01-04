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

@synthesize M, K, N, stringLog;
@synthesize startTime, timeInterval;

- (id)init
{
    self = [super init];
    if ( self )
    {
        [self setM:4096];  // M must be >= MAX(K, 1)  (rows in matrices A and C)                M = lda = ldc
        [self setK:4096];  // M >= K >= N             (columns in matrices B and C)
        [self setN:4096];  // K must be >= MAX(N, 1)  (columns in matrix A; rows in matrix B)   K = ldb
        startTime = [NSDate date];
        timeInterval = 0;
        [self setStringLog:@"log"];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

}

- (IBAction)matrixmultiply:(id)sender
{
    dispatch_queue_t asyncQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(asyncQueue, ^{
        
        int i; // index for matrix
        
        double alpha = 1.0;    // (Scaling factor for the product of matrices A and B.)
        
        double *A = calloc( (double) M * K, (double) 8 );  // (matrix A) M x K
        for ( i = 0; i < M * K; i++ ) A[ i ] = [self getRandomDouble];
        [self setStringLog:@"matrix A created"];
        NSLog(@"matrix A created");
        
        double *B = calloc( (double) K * N, (double) 8 );  // (matrix B) K x N
        for ( i = 0; i < K * N; i++ ) B[ i ] = [self getRandomDouble];
        [self setStringLog:[[self stringLog] stringByAppendingString:@"\nmatrix B created"]];
        NSLog(@"matrix B created");
        
        double beta = 0.0;
        double *C = calloc( (double) M * N, (double) 8 );  // (matrix C) M x N
        [self setStringLog:[[self stringLog] stringByAppendingString:@"\nmatrix C malloc"]];
        NSLog(@"matrix C malloc");
        
        [self setStringLog:[[self stringLog] stringByAppendingString:@"\nstart cblas_dgemm"]];

        NSLog(@"start cblas_dgemm");
        startTime = [NSDate date];

        // Compute C = A B
        cblas_dgemm (CblasRowMajor, CblasNoTrans, CblasNoTrans,
                     M, N, K,
                     
                     alpha,
                     A, M,
                     B, K,
                     
                     beta,
                     C, M);

        [self setTimeInterval:[startTime timeIntervalSinceNow] * -1];

        [self setStringLog:[[self stringLog] stringByAppendingString:@"\nend cblas_dgemm"]];
        NSLog(@"end cblas_dgemm");
        
        [self setStringLog:[[self stringLog] stringByAppendingString:[NSString stringWithFormat:@"\n%f", C[0]]]];
        NSLog(@"C[0] = %f", C[0]);
        
        free(A);
        free(B);
        free(C);

        NSLog(@"timeInterval = %f", timeInterval);
});

}

- (double)getRandomDouble
{
	return ( (double)arc4random_uniform(100) / 100 );
}
@end
