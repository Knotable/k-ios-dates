//
//  UIColor+MailExtensions.m
//  Mailer
//
//  Created by Martin Ceperley on 11/12/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "UIColor+MailExtensions.h"

@implementation UIColor (MailExtensions)

+(UIColor *)colorWithHexString:(NSString *)hexString
{
    if (hexString.length != 6) {
        NSException* myException = [NSException
                                    exceptionWithName:@"NotSixCharacters"
                                    reason:@"hexString must be six characters"
                                    userInfo:nil];
        @throw myException;

    }
    NSString *redString = [hexString substringWithRange:NSMakeRange(0, 2)];
    NSString *greenString = [hexString substringWithRange:NSMakeRange(2, 2)];
    NSString *blueString = [hexString substringWithRange:NSMakeRange(4, 2)];

    NSScanner *redScanner = [NSScanner scannerWithString:redString];
    NSScanner *greenScanner = [NSScanner scannerWithString:greenString];
    NSScanner *blueScanner = [NSScanner scannerWithString:blueString];
    
    unsigned int red, green, blue;
    
    [redScanner scanHexInt:&red];
    [greenScanner scanHexInt:&green];
    [blueScanner scanHexInt:&blue];
    
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}

@end
