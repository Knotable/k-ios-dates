//
//  ContactEmailTableTableViewController.m
//  Knotable
//
//  Created by Emiliano Barcia Lizarazu on 12/1/15.
//
//

#import "ContactEmailTableTableViewController.h"
#import "ContactEmailTableViewCell.h"
#import "ContactManager.h"
#import "AJNotificationView.h"

static NSString *simpleTableIdentifier = @"ContactEmailTableViewCell";

@interface ContactEmailTableTableViewController ()

@property (nonatomic, strong) UINavigationItem *navItem;

@end

@implementation ContactEmailTableTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:simpleTableIdentifier bundle:nil] forCellReuseIdentifier:simpleTableIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsMultipleSelection = YES;
    
    
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

-(void)goBackNavButtonPressed:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)addSelectedMails:(id)sender{
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    NSString * email;
    for(NSIndexPath * auxIndex in selectedIndexPaths){
        ContactEmailTableViewCell *cell = (ContactEmailTableViewCell *) [self.tableView cellForRowAtIndexPath:auxIndex];
        [[ContactManager sharedInstance] performRemoteEmailAdd:cell.emailLabel.text];
        email = cell.emailLabel.text;
    }
    
   /* [AJNotificationView showNoticeInView:[[[UIApplication sharedApplication] delegate] window]
                                    type:AJNotificationTypeGreen
                                   title:[NSString stringWithFormat:@"%@%@", email, @" added."]
                         linedBackground:AJLinedBackgroundTypeAnimated
                               hideAfter:2.5f
                                  offset:64.0f
                                   delay:0.0f
                                response:^{
                                }
     ];*/
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mails.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#define HEADER_AND_NAVIGATION_BAR_SIZE 20
#define NAVIGATION_BAR_SIZE 64

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UINavigationBar *navbar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, 320, NAVIGATION_BAR_SIZE)];
    self.navItem = [UINavigationItem alloc];
    self.navItem.title = @"Select an email";
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(goBackNavButtonPressed:)];
    leftButton.tintColor = [UIColor whiteColor];
    self.navItem.leftBarButtonItem = leftButton;
    
    
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Add"
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector(addSelectedMails:)];
    rightButton.enabled = NO;
    rightButton.tintColor = [UIColor whiteColor];
    self.navItem.rightBarButtonItem = rightButton;
    [navbar pushNavigationItem:self.navItem animated:false];
    
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, HEADER_AND_NAVIGATION_BAR_SIZE + NAVIGATION_BAR_SIZE)];
    [headerView addSubview:navbar];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return HEADER_AND_NAVIGATION_BAR_SIZE + NAVIGATION_BAR_SIZE;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContactEmailTableViewCell *cell = (ContactEmailTableViewCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ContactEmailTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [cell initWitDescription:@"Email" andMail:[self.mails objectAtIndex:indexPath.row]];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    self.navItem.rightBarButtonItem.enabled = (selectedIndexPaths.count > 0);
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    self.navItem.rightBarButtonItem.enabled = (selectedIndexPaths.count > 0);
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
