//
//  MDetailViewController.h
//  Mailer
//
//  Created by Martin Ceperley on 9/20/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MailCore/MailCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>




@class MPlainTextMessageView, Message, MAttachmentsView;

@interface MDetailViewController : UIViewController <MCOHTMLRendererDelegate, UIWebViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate,UIActionSheetDelegate>{
    CGSize _originalContentSize;
    BOOL _loadingMessage;
    CGFloat _initialYOffset;
    CGSize _initialSize;
    CGFloat _initialZoom;

    UIPinchGestureRecognizer *_pinchRecognizer;
    
    MCOMessageParser *_parser;
    BOOL _haveHTML;
    BOOL _havePlaintext;
    MCOAbstractPart *_textPart;
    MCOAbstractPart *_htmlPart;

    MPlainTextMessageView *_plainView;
    
    CGFloat _webviewHeight;
    
    NSDate *_loadTime;
    NSTimer *_timeTimer;
    
    AVAudioPlayer *theAudio;
    MPMoviePlayerViewController *videoPlayerView;
    UIButton *swipeDetailBut;
    
    
    
}

@property (strong, nonatomic) Message *message;
@property (weak, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) BOOL shortMode,peopleMode,isPictureMode;
@property (strong, nonatomic) NSMutableArray *messageArray;

@property (strong, nonatomic) IBOutlet UILabel *fromLabel;
@property (strong, nonatomic) IBOutlet UILabel *toLabel;
@property (strong, nonatomic) IBOutlet UILabel *subjectLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateReceivedLabel;
@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) UIView *webBrowserView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (strong, nonatomic) id<MASConstraint> webviewHeightConstraint;
@property (strong, nonatomic) id<MASConstraint> textviewHeightConstraint;


@property (strong, nonatomic) MAttachmentsView *attachmentsView;

@property (nonatomic,assign)int replyType;
//@property (nonatomic, readonly) MPMoviePlaybackState playbackState;

@end
