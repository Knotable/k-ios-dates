//
//  CommentViewController.m
//  Knotable
//
//  Created by Troy DeMar on 6/25/15.
//
//

#import "CommentViewController.h"
#import "ThreadItemManager.h"

#import "UIImage+FontAwesome.h"




@interface CommentViewController ()

@property (assign, nonatomic)   BOOL isReady_toGetRest;

@end

@implementation CommentViewController


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithTopic:(CItem *)item {
    //self = [super init];
    self = [super initWithTableViewStyle:UITableViewStylePlain];
    
    if (self) {
        self.itemInfo = item;

        self.navigationItem.title = @"Comments";
    }
    
    return self;
}

- (void)setItemInfo:(CItem *)itemInfo{
    _itemInfo = itemInfo;
    _arrOfComments = [NSKeyedUnarchiver unarchiveObjectWithData:_itemInfo.userData.replys];
    _arrOfComments = [[[_arrOfComments reverseObjectEnumerator] allObjects] mutableCopy];
    
    [self.tableView reloadData];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
//    CGRect frame = self.view.bounds;
//    self.tblOfComments=[[UITableView alloc] initWithFrame:frame];
//    self.tblOfComments.delegate=self;
//    self.tblOfComments.dataSource=self;
//    self.tblOfComments.separatorStyle=UITableViewCellSeparatorStyleNone;
//    [self.view addSubview:self.tblOfComments];

//    [self.tblOfComments mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(@0.0);
//    }];
    
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.inverted = NO;
    self.textInputbar.autoHideRightButton = NO;
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    
    self.navigationItem.hidesBackButton = YES;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    UIImage *backImage = [UIImage imageWithIcon:@"fa-angle-left" backgroundColor:[UIColor clearColor] iconColor:[UIColor blackColor] andSize:CGSizeMake(30, 30)];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backButton setImage:backImage forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(0, 0, backImage.size.width, backImage.size.height)];
    
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    
    [backButton addTarget:self action:@selector(threadPopBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.navigationItem.leftBarButtonItem = backButtonItem;
}



- (void)threadPopBack {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didPressRightButton:(id)sender {
    NSLog(@"didPressRightButton");
    
    NSString *noteId      = self.itemInfo.itemId;
    NSString *commentBody = self.textView.text;
    NSString *topicId     = self.itemInfo.userData.topic_id;
    
    BOOL emptyNoteId = [noteId isEqualToString:@""] || noteId == NULL;
    
    if (!emptyNoteId) {
        [[ThreadItemManager sharedInstance] addComment:commentBody
                                          toNoteWithId:noteId
                                         inTopicWithId:topicId];
    }
    
    
    [super didPressRightButton:sender];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    return [_arrOfComments count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    if (indexPath.row == 0) {
//        UITableViewCell *cell;
//        cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell"];
//        return cell;
//    }
    
    
    static NSString *cellID = @"identifier";
    CReplyCell *cell = (CReplyCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[CReplyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //cell.delegate = self.commentDelegate;
    cell.gotReply = [_arrOfComments objectAtIndex:indexPath.row];
    
    return cell;
}



#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CreplyUtils *celltemp=[[CreplyUtils alloc]init];
    return [celltemp getHeightOfCell:[_arrOfComments objectAtIndex:indexPath.row]] + 15;
}


@end
