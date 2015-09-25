//
//  MFetchMessageContentsOperation.h
//  Mailer
//
//  Created by Martin Ceperley on 11/14/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MFetchMessageContentsOperation : NSOperation

- (void)start;
- (BOOL)isConcurrent;
- (BOOL)isExecuting;
- (BOOL)isFinished;


@end
