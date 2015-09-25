//
//  MKnotesViewController.m
//  Mailer
//
//  Created by Mac 7 on 17/02/14.
//  Copyright (c) 2014 Knotable. All rights reserved.
//

#import "MKnotesViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MDesignManager.h"


@interface MKnotesViewController ()

@end

@implementation MKnotesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor clearColor];
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"topbar.png"]];
    
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    if (height == 1024) {
         self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"topbar"]];
    }
    else{
         self.view.backgroundColor = [MDesignManager patternImage];
    }

    
//  [txtvw addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"paper_clip.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    _accountArray = [NSMutableArray arrayWithArray:nil];
    _knoteArray = [NSMutableArray arrayWithArray:nil];
    _tableListArray = [NSMutableArray arrayWithArray:nil];
    
    txtvw.text = @"";
    txtvw.layer.cornerRadius = 10.0;
    txtvw.layer.borderWidth = 10.0;
    txtvw.layer.borderColor = (__bridge CGColorRef)([UIColor redColor]);
    
    txtvw.contentOffset = (CGPoint){.x = 0, .y = 0};
    
    [self gettingKnotes];
    
}

//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    
//    UITextView *tv = object;
//    //Top vertical alignment
//    tv.contentOffset = (CGPoint){.x = 0, .y = 0};
//    

    
    //Bottom vertical alignment
//    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height);
//    topCorrect = (topCorrect <0.0 ? 0.0 : topCorrect);
//    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
    
    
    //Center vertical alignment
    //CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
    //topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    //tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)backAction:(id)sender{
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Getting Knotes from Plist

-(void)gettingKnotes{
    
    [_tableListArray removeAllObjects];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *stringsPlistPath = [documentsDirectory stringByAppendingPathComponent:@"KnotePlist.plist"];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:stringsPlistPath];
//    NSLog(@"plistData OK=%@",plistData);
    
    
    [_tableListArray addObjectsFromArray:[plistData objectForKey:@"Knote"]];
//    NSLog(@"_tableListArray=%@",_tableListArray);
    
//    [resultAddressArray addObjectsFromArray:[plistData objectForKey:@"address"]];
//    NSLog(@"resultAddressArray=%@",resultAddressArray);
    
//    NSLog(@"resultNameArray count=%d",[resultNameArray count]);
    [tablevw reloadData];
}


#pragma mark - Add Knotes to Plist

-(IBAction)addKnotes:(id)sender  {
    
    [txtvw resignFirstResponder];
    
    NSString *strValidation = txtvw.text;
    strValidation = [strValidation stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if ([strValidation length]) {
        
      
    
    [_accountArray removeAllObjects];
    [_knoteArray removeAllObjects];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"KnotePlist.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];//create instance of NSFileManager
    
    if ( ![fileManager fileExistsAtPath:filePath] ) {
        
        NSLog(@"File not exists");
    }
    
    else {
        
        NSLog(@"File exists");
        NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:filePath] ;
        NSString *storedname = [plistData objectForKey:@"Account"];
        
        if (storedname!= NULL) {
            
//            NSLog(@"plistData=%@",plistData);
            [_accountArray addObjectsFromArray:[plistData objectForKey:@"Account"]];
            [_knoteArray addObjectsFromArray:[plistData objectForKey:@"Knote"]];
        }
        
        [_accountArray addObject:@"1"];
        [_knoteArray addObject:txtvw.text];
        
        NSMutableDictionary *plist = [[NSDictionary dictionaryWithContentsOfFile:filePath] mutableCopy];
        [plist setObject:_accountArray forKey:@"Account"];
        [plist setObject:_knoteArray forKey:@"Knote"];
//        NSLog(@"plist=%@",plist);
        [plist writeToFile:filePath atomically:YES];
        
    }

    txtvw.text = @"";
    
    [self gettingKnotes];
        
    }
    else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter some text" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
    }
}


#pragma mark - Table View delegate & datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return _tableListArray.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
//    [self configureCell:cell atIndexPath:indexPath];

    
    static NSString *CellIdentifier = @"Cell";
    
//     UITableViewCell *cell  =  [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    }
    
//    NSLog(@"cell.frame.size.width = %f",cell.frame.size.width);

//    UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width - 10, 160)];
//    cellView.backgroundColor = [UIColor whiteColor];
//    cellView.layer.cornerRadius = 5.0;
//    
//    [cell.contentView addSubview:cellView];
//    
//    
//    UILabel *textLab = [[UILabel alloc]initWithFrame:CGRectMake(5, 12, cell.frame.size.width-15, 130)];
//    textLab.backgroundColor = [UIColor clearColor];
//    textLab.text = [_tableListArray objectAtIndex:indexPath.row];
//    textLab.lineBreakMode = NSLineBreakByWordWrapping;
//    textLab.numberOfLines = 10;
////    [textLab sizeToFit];
//    textLab.font = [UIFont systemFontOfSize:13.0];
//    
//    CGSize maximumLabelSize = CGSizeMake(310, CGFLOAT_MAX);
//    
//    CGRect textRect = [textLab.text boundingRectWithSize:maximumLabelSize
//                                             options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
//                                          attributes:@{NSFontAttributeName:textLab.font}
//                                             context:nil];
//        
//    textLab.frame = textRect;
//    
//    [cellView addSubview:textLab];
    
    
    UITextView *txtVw = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width - 10, 160)];
    txtVw.backgroundColor = [UIColor whiteColor];
    txtVw.layer.cornerRadius = 10.0;
    txtVw.text = [_tableListArray objectAtIndex:indexPath.row];
    txtVw.userInteractionEnabled = NO;
    [cell.contentView addSubview:txtVw];
    
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
       
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(5.0f, 125.0f, 30.0f, 30.0f)];
    button.tag=  indexPath.row;
    button.adjustsImageWhenHighlighted=NO;
    [button setImage:[UIImage imageNamed:@"TRASH.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:button];
    
    return cell;
}

-(IBAction)deleteAction:(id)sender{
    
    UIButton *button = (UIButton *)sender;
    
    NSInteger tag = button.tag;
    
//    NSLog(@"tag = %d",tag);
    
    [_accountArray removeAllObjects];
    [_knoteArray removeAllObjects];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"KnotePlist.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];//create instance of NSFileManager
    
    if ( ![fileManager fileExistsAtPath:filePath] ) {
        
        NSLog(@"File not exists");
    }
    
    else {
        
        NSLog(@"File exists");
        NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:filePath] ;
        NSString *storedname = [plistData objectForKey:@"Account"];
        
        if (storedname!= NULL) {
            
            //            NSLog(@"plistData=%@",plistData);
            [_accountArray addObjectsFromArray:[plistData objectForKey:@"Account"]];
            [_knoteArray addObjectsFromArray:[plistData objectForKey:@"Knote"]];
        }
        
        [_accountArray removeObjectAtIndex:tag];
        [_knoteArray removeObjectAtIndex:tag];
        
        
        NSMutableDictionary *plist = [[NSDictionary dictionaryWithContentsOfFile:filePath] mutableCopy];
        [plist setObject:_accountArray forKey:@"Account"];
        [plist setObject:_knoteArray forKey:@"Knote"];
        //        NSLog(@"plist=%@",plist);
        [plist writeToFile:filePath atomically:YES];
        
        [self gettingKnotes];
        
    }
    
}

#pragma mark - UITextView View
//
//- (void)textViewDidBeginEditing:(UITextView *)textView{
//    
//      UITextPosition *beginning = [textView beginningOfDocument];
//      [textView setSelectedTextRange:[textView textRangeFromPosition:beginning
//                                                      toPosition:beginning]];
//}


- (BOOL)textView:(UITextView *)textViewlocal shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    NSCharacterSet *doneButtonCharacterSet = [NSCharacterSet newlineCharacterSet];
    NSRange replacementTextRange = [text rangeOfCharacterFromSet:doneButtonCharacterSet];
    NSUInteger location = replacementTextRange.location;
    
    if (textViewlocal.text.length + text.length > 300){//300 characters are in the textView
        if (location != NSNotFound){ //Did not find any newline characters
            [textViewlocal resignFirstResponder];
        }
        UIAlertView *aler = [[UIAlertView alloc] initWithTitle:@"Mailable" message:@"Sorry! The character count is limited upto 300" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [aler show];
        return NO;
    }
    
    else if (location != NSNotFound){ //Did not find any newline characters
        [txtvw resignFirstResponder];
        return NO;
    }
    
    return YES;
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if (![textView.text length]) {
        txtvw.contentOffset = (CGPoint){.x = 0, .y = 0};
    }
}


@end
