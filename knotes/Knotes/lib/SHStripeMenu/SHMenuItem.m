//
//  SHMenuItem.m
//  SHStripeMenu
//
//  Created by Narasimharaj on 26/04/13.
//  Copyright (c) 2013 SimHa. All rights reserved.
//

#import "SHMenuItem.h"

@implementation SHMenuItem

+ (SHMenuItem *)initWithName:(NSString *)name Email:(NSString *)email andImage:(UIImage *)image
{
	return [[self alloc] initWithName:name Email:email andImage:image];
}

- (SHMenuItem *)initWithName:(NSString *)name Email:(NSString *)email andImage:(UIImage *)image
{
	if (self = [super init])
	{
		_name	= name;
		_image	= image;
        _email = email;
	}
	return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"SHMenuItem name: %@ email: %@ image: %@", _name, _email, _image];
}

@end
