//
//  ShowPDFController.h
//  Knotable
//
//  Created by Martin Ceperley on 3/12/14.
//
//



@class FileEntity;

@interface ShowPDFController : UIViewController <UIWebViewDelegate>

@property (nonatomic, weak) id delegate;

- (id)initWithFile:(FileEntity *)file;

@end
