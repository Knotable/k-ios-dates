//
//  MLogTableViewController.m
//  Mailer
//
//  Created by backup on 14-6-6.
//  Copyright (c) 2014年 Knotable. All rights reserved.
//

#import "MLogTableViewController.h"
#import "Debug.h"
#import "MSwipedButtonManager.h"
#import "MWriteMessageViewController.h"
#import "MMailManager.h"
#import <MessageUI/MFMailComposeViewController.h>
@interface MLogTableViewController ()<MFMailComposeViewControllerDelegate>
@property(nonatomic, strong) NSArray *contentArray;
@property(nonatomic, strong) UIButton *rightItem;
@property(nonatomic, strong) NSString *contentStr;
@end

@implementation MLogTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Log View";
    self.contentStr = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%s",LOG_PATH] encoding:NSUTF8StringEncoding error:nil];
    self.contentArray = [self.contentStr componentsSeparatedByString:@"\n"];
    self.rightItem = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60 , 40)];
    if ([Debug defaultDebug].enableLog) {
        [self.rightItem setTitle:@"Disable" forState:UIControlStateNormal];
    } else {
        [self.rightItem setTitle:@"Enable" forState:UIControlStateNormal];
    }
    [self.rightItem addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.rightItem setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightItem];
    UIBarButtonItem *passItem = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(passPressed)];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithTitle:@"Clean"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(archivePressed)];
    self.toolbarItems = @[passItem, spacer, deleteItem];



}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:NO];

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:NO];
}
-(void)rightBtnClicked
{
    [Debug defaultDebug].enableLog = ![Debug defaultDebug].enableLog;
    if ([Debug defaultDebug].enableLog) {
        [self.rightItem setTitle:@"Disable" forState:UIControlStateNormal];
    } else {
        [self.rightItem setTitle:@"Enable" forState:UIControlStateNormal];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.contentArray count];
}

- (CGFloat)getLabelHeight:(NSString *)string labelWidth:(CGFloat)width textFont:(UIFont *)font
{
    if (string) {
        CGSize size = CGSizeMake(width,CGFLOAT_MAX);
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:string
                                                                             attributes:@{ NSFontAttributeName: font }];
        CGRect rect = [attributedText boundingRectWithSize:size
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
        CGSize labelSize = rect.size;
        CGFloat labelHeight = labelSize.height;
        return labelHeight;
    } else {
        return 44;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str = [[[self.contentArray objectAtIndex:indexPath.row] componentsSeparatedByString:@"|"] objectAtIndex:0];
    
    return [self getLabelHeight:str labelWidth:320 textFont:[UIFont systemFontOfSize:14]]+30;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"logCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    }
    NSString *str = [self.contentArray objectAtIndex:indexPath.row];
    if ([str length]>0) {
        NSLog(@"%@",str);
        cell.textLabel.text = [[str componentsSeparatedByString:@"|"] objectAtIndex:0];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
        cell.detailTextLabel.text = [[str componentsSeparatedByString:@"|"] objectAtIndex:1];
    }

    return cell;
}

-(void)archivePressed
{
    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%s",LOG_PATH] error:nil];
    self.contentStr = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%s",LOG_PATH] encoding:NSUTF8StringEncoding error:nil];
    self.contentArray = [self.contentStr componentsSeparatedByString:@"\n"];
    [self.tableView reloadData];
}
- (void)passPressed
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    // Set the subject of email
    [picker setSubject:@"Logs my iPhone!"];
    
    // Add email addresses
    // Notice three sections: "to" "cc" and "bcc"
    [picker setToRecipients:[NSArray arrayWithObjects:@"yan.make@gmail.com", nil]];
    [picker setCcRecipients:[NSArray arrayWithObjects:@"a@knote.com",@"liam@knote.com",@"yan.make@gmail.com",nil]];
//    [picker setBccRecipients:[NSArray arrayWithObject:@"wulitest@gmail.com"]];
    
    // Fill out the email body text
    NSString *emailBody = @"Log";
    
    // This is not an HTML formatted email
    [picker setMessageBody:emailBody isHTML:NO];
    
    // Create NSData object as PNG image data from camera image
    NSData *data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%s",LOG_PATH]];
    // Attach image data to the email
    // 'CameraImage.png' is the file name that will be attached to the email
    [picker addAttachmentData:data mimeType:@"text/plain" fileName:@"log.txt"];
    
    // Show email view
    [self presentViewController:picker animated:YES completion:^{
        
    }];
    
}
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:^{
        [self archivePressed];
    }];
}

@end
