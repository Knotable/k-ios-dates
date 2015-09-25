//
//  DemoTableControllerViewController.m
//  FPPopoverDemo
//
//  Created by Alvise Susmel on 4/13/12.
//  Copyright (c) 2012 Fifty Pixels Ltd. All rights reserved.
//

#import "DemoTableController.h"

@interface customCell : UITableViewCell
@property(nonatomic, strong) UITextField *playerTextField;
@end
@implementation customCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.playerTextField  = [[UITextField alloc] initWithFrame:CGRectMake(150, 10, 86, 30)];
        self.playerTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.playerTextField .adjustsFontSizeToFitWidth = YES;
        self.playerTextField .textColor = [UIColor blackColor];
        self.playerTextField .keyboardType = UIKeyboardTypeEmailAddress;
        self.playerTextField .returnKeyType = UIReturnKeyNext;
        [self addSubview:self.playerTextField];
    }
    return self;
}
@end
@interface DemoTableController ()
@property(nonatomic, strong) NSArray *contentArray;
@property(nonatomic, strong) NSMutableArray *selectedArray;

@end

@implementation DemoTableController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"settings";
    self.selectedArray = [NSMutableArray new];
    self.contentArray = @[
                          @"Show if includes",
                          //                          @"Show if includes word \"xx\" with a text box so you can make words to filter on",
                          @"Show if FROM VIP",
                          @"Show if New",
                          @"Show if Read",
                          @"Show if Archived",
                          @"Show if Flagged",
                          @"Show if Long",
                          @"Show if Short",
                          @"Show if File",
                          @"Show if Picture",

                          ];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.contentArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    customCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        cell = [[customCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    if (indexPath.row <[self.contentArray count]) {
        cell.textLabel.text = self.contentArray[indexPath.row];
        if ([self.contentArray[indexPath.row] isEqualToString:@"Show if includes"]) {
            [cell.playerTextField setFrame:CGRectMake(150, 10, 86, 30)];
            cell.playerTextField.hidden = NO;
            
        } else if ([self.contentArray[indexPath.row] isEqualToString:@"Show if FROM VIP"]) {
            [cell.playerTextField setFrame:CGRectMake(160, 10, 76, 30)];
            cell.playerTextField.hidden = NO;
            
        } else {
            cell.playerTextField.hidden = YES;
        }
        
    } else {

    }
    BOOL find = NO;
    for (int i = 0; i<[self.selectedArray count]; i++) {
        NSIndexPath *ipath = [self.selectedArray objectAtIndex:i];
        if (ipath.row == indexPath.row) {
            find = YES;
            break;
        }
    }
    if (find) {
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_checked"]];
        cell.accessoryView = image;
    } else {
        cell.accessoryView = nil;
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.contentArray[indexPath.row] isEqualToString:@"Show if includes"] || [self.contentArray[indexPath.row] isEqualToString:@"Show if FROM VIP"]) {
        
    } else {
        BOOL find = NO;
        for (int i = 0; i<[self.selectedArray count]; i++) {
            NSIndexPath *ipath = [self.selectedArray objectAtIndex:i];
            if (ipath.row == indexPath.row) {
                find = YES;
                [self.selectedArray removeObjectAtIndex:i];
                break;
            }
        }
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (!find) {
            UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_checked"]];
            cell.accessoryView = image;
            [self.selectedArray addObject:indexPath];
            
        } else {
            cell.accessoryView = nil;
        }
    }
}

@end
