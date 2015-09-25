//
//  MFetchMessageContentsOperation.m
//  Mailer
//
//  Created by Martin Ceperley on 11/14/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "MFetchMessageContentsOperation.h"

@implementation MFetchMessageContentsOperation

- (void)start
{
    
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return NO;
}

- (BOOL)isFinished
{
    return YES;
}


@end
