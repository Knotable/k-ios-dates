//
//  QuadCurveCustomMenuItemFactory.m
//  Knotable
//
//  Created by wuli on 14-7-15.
//
//

#import "QuadCurveCustomMenuItemFactory.h"

@interface QuadCurveCustomMenuItemFactory () {
    UIImage *image;
    UIImage *highlightImage;
}

@end

@implementation QuadCurveCustomMenuItemFactory

#pragma mark - Initialization

- (id)initWithImage:(UIImage *)_image
     highlightImage:(UIImage *)_highlightImage {
    
    self = [super init];
    if (self) {
        
        image = _image;
        highlightImage = _highlightImage;
        
    }
    return self;
}

+ (id)defaultMenuItemFactory {
    
    return [[self alloc] initWithImage:[UIImage imageNamed:@"icon-star.png" ]
                        highlightImage:nil];
}

+ (id)defaultMainMenuItemFactory {
    
    return [[self alloc] initWithImage:[UIImage imageNamed:@"icon-plus_rect.png"]
                        highlightImage:nil];
    
}

#pragma mark - QuadCurveMenuItemFactory Adherence

- (QuadCurveMenuItem *)createMenuItemWithDataObject:(id)dataObject {
    
    AGMedallionView *medallionItem = [AGMedallionView new];
    medallionItem = [[AGMedallionView alloc] init];
    medallionItem.borderWidth = 0;
    medallionItem.shadowColor = [UIColor clearColor];
    medallionItem.borderColor = [UIColor clearColor];
    medallionItem.shadowBlur = 0;
    [medallionItem setImage:image];
    [medallionItem setHighlightedImage:highlightImage];
    medallionItem.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    QuadCurveMenuItem *item = [[QuadCurveMenuItem alloc] initWithView:medallionItem];
    
    [item setDataObject:dataObject];
    
    return item;
}

@end
