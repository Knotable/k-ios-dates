//
//  MDesignManager.m
//  Mailer
//
//  Created by Martin Ceperley on 10/29/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "MDesignManager.h"

@implementation MDesignManager


+ (UIColor *) tintColor
{
    // #28ace8
    return [UIColor colorWithRed:40.0/255.0 green:172.0/255.0 blue:232.0/255.0 alpha:1.0];
}

+ (UIColor *) highlightColor
{
    return [UIColor blackColor];
    return [UIColor whiteColor];
}


//Modified by 3E ------START------
+ (UIColor *) patternImage
{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"topbar.png"]];
//    return Nil;

    
}

+ (UIColor *) tintColorUpdated
{
    return [UIColor colorWithRed:108.0/255.0 green:192.0/255.0 blue:216.0/255.0 alpha:0.6];
    
}
+ (UIColor *) barTintColor{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"topbar.png"]];

    return [UIColor colorWithRed:72.0/255.0 green:174.0/255.0 blue:199.0/255.0 alpha:1.0];

}
//Modified by 3E ------END------

@end
