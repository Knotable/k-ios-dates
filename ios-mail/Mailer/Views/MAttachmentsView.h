//
//  MAttachmentsView.h
//  Mailer
//
//  Created by Martin Ceperley on 10/24/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAttachmentsView : UIView

@property (nonatomic, copy) NSArray *attachments;
@property (nonatomic, retain) NSMutableArray *imageViews;
@property (nonatomic, retain) NSMutableArray *featureViews;
@property (nonatomic, strong) NSString *mimeTypeStr;

@end
