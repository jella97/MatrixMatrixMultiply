//
//  AppDelegate.h
//  MatrixMatrixMultiplication
//
//  Created by John on 12/11/12.
//  Copyright (c) 2012 IBS. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

// outlets
@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *lblMatrixSize;
@property (weak) IBOutlet NSTextField *lblRunTime;

// properties
@property int M;
@property int K;
@property int N;
@property NSString *stringLog;
@property NSDate *startTime;
@property double timeInterval;

// methods

- (IBAction)matrixmultiply:(id)sender;


@end
