//
//  UPStackMenu.h
//  UPStackButtonDemo
//
//  Created by Paul Ulric on 21/01/2015.
//  Copyright (c) 2015 Paul Ulric. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UPStackMenuItem.h"
#import "DesignManager.h"
#import "MFSideMenuShadow.h"


typedef enum {
    UPStackMenuStackPosition_up = 0,
    UPStackMenuStackPosition_down
} UPStackMenuStackPosition_e;

typedef enum {
    UPStackMenuAnimationType_linear = 0,
    UPStackMenuAnimationType_progressive,
    UPStackMenuAnimationType_progressiveInverse
} UPStackMenuAnimationType_e;


@protocol UPStackMenuDelegate;


@interface UPStackMenu : UIView <UPStackMenuItemDelegate>

// Vertical spacing between each stack menu item
@property (nonatomic, readwrite)            CGFloat                     itemsSpacing;
// Whether the items should bounce at the end of the opening animation, or a the beginning of the closing animaton
@property (nonatomic, readwrite)            BOOL                        bouncingAnimation;
@property (nonatomic, readwrite)            BOOL                        isSelector;

// Opening animation total duration (in seconds)
@property (nonatomic, readwrite)            NSTimeInterval              openAnimationDuration;
// Closing animation total duration (in seconds)
@property (nonatomic, readwrite)            NSTimeInterval              closeAnimationDuration;
// Delay between each item animation start during opening (in seconds)
@property (nonatomic, readwrite)            NSTimeInterval              openAnimationDurationOffset;
// Delay between each item animation start during closing (in seconds)
@property (nonatomic, readwrite)            NSTimeInterval              closeAnimationDurationOffset;
@property (nonatomic, readwrite)            UPStackMenuStackPosition_e  stackPosition;
@property (nonatomic, readwrite)            UPStackMenuAnimationType_e  animationType;
@property (nonatomic, readonly)             BOOL                        isOpen;
@property (nonatomic, unsafe_unretained)    id<UPStackMenuDelegate>     delegate;
@property (nonatomic, strong)            UIImageView * icon;
@property (nonatomic, strong)UIView *  conView;
@property (nonatomic, strong)UIView *  shadowView;

- (id)initWithImage:(UIImage*)img inSelection:(BOOL)arg;
- (void)addItem:(UPStackMenuItem*)item;
- (void)addItems:(NSArray*)items;
- (void)removeItem:(UPStackMenuItem*)item;
- (void)removeItemAtIndex:(NSUInteger)index;
- (void)removeAllItems;

- (NSArray*)items;

- (void)openStack;
- (void)closeStack;

@end



@protocol UPStackMenuDelegate <NSObject>

@optional
- (void)stackMenuWillOpen:(UPStackMenu*)menu;
- (void)stackMenuDidOpen:(UPStackMenu*)menu;
- (void)stackMenuWillClose:(UPStackMenu*)menu;
- (void)stackMenuDidClose:(UPStackMenu*)menu;
- (void)stackMenu:(UPStackMenu*)menu didTouchItem:(UPStackMenuItem*)item atIndex:(NSUInteger)index;
-(void) openStackwithSelector;
@end
// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net