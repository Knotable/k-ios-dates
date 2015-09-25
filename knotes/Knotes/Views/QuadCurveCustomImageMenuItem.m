//
//  QuadCurveCustomImageMenuItem.m
//  Knotable
//
//  Created by wuli on 14-7-14.
//
//

#import "QuadCurveCustomImageMenuItem.h"
@interface QuadCurveCustomImageMenuItem () {
    UIImage *image;
    UIImage *highlightImage;
}

@end
@implementation QuadCurveCustomImageMenuItem

- (id)initWithImage:(UIImage *)_image
     highlightImage:(UIImage *)_highlightImage {
    
    self = [super init];
    if (self) {
        
        image = _image;
        highlightImage = _highlightImage;
        
    }
    return self;
}

- (QuadCurveMenuItem *)createMenuItemWithDataObject:(id)dataObject {
    if (dataObject) {
        return dataObject;
    }
    return self.item;
}

-(void)setUserData:(id)userData
{
    _userData = userData;
}
@end
