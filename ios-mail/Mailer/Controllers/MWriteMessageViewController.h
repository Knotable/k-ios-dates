//
//  MWriteMessageViewController.h
//  Mailer
//
//  Created by Martin Ceperley on 10/22/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AssetsLibrary/AssetsLibrary.h>
#import "TITokenFieldView.h"


@class MMessageHeaderView, Message, MCOAttachment;

@interface MWriteMessageViewController : UIViewController <UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,TITokenFieldViewDelegate,TITokenFieldDelegate>
{
    
    //Modified by 3E ------START------
    
    NSMutableArray *emailArray;
    
    NSMutableArray *tableDataArray;
    
    UITableView *tableViewEmail;
    
    int removeStrLength;
    
    NSString *toStr;
    
    UIButton *uploadButton;
    
    UIImagePickerController *picker;
    
    CGFloat totalSize;
    
    TITokenFieldView * tokenFieldView;
    
	UITextView * messageView;
	CGFloat keyboardHeight;

   
//    int loop;
    
    //Modified by 3E ------End------
}


@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) MMessageHeaderView *headerView;
@property (nonatomic, strong) Message *originalMessage;

@property (nonatomic, strong) MCOAttachment *textPart;
@property (nonatomic, strong) MCOAttachment *htmlPart;

//Modified by 3E ------START------
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSString *locationStr;
@property (nonatomic, readwrite) BOOL isReply,isReplyAll,isForward;
@property (nonatomic , assign) int boolVal;
@property (nonatomic, strong)NSString *summaryStr;
@property (nonatomic, strong)NSMutableArray *imageArray,*imageNameArray;
@property (nonatomic , strong) UITableView *tableView;

//Modified by 3E ------End------

- (IBAction)cancel:(id)sender;
- (IBAction)send:(id)sender;

@end
