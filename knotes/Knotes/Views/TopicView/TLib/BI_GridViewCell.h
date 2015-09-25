//
//  BI_GridViewCell.h
//  BaiduIMLib
//
//  Created by backup on 11-10-9.
//  Copyright 2011年 backup. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BI_GridFrame;

@interface BI_GridViewCell : UIView {
	NSInteger	   tag_;
    BOOL           redrawNow_;
    BOOL           selected_;
    BOOL           highlighted_;
    NSString      *reuseIdentifier_;
    BI_GridFrame  *frameInfo_;
}

@property (nonatomic, assign)   NSInteger	  tag;
@property (nonatomic, assign)   BOOL          selected;
@property (nonatomic, assign)   BOOL          highlighted;
@property (nonatomic, readonly) NSString     *reuseIdentifier;
@property (nonatomic, retain)   BI_GridFrame *frameInfo;

- (void)reset;
- (void)twinkle; //高亮的时候闪一下，依赖是否开启了redrawNow
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;
@end
