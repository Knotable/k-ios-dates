//
//  BubbleView.m
//  Knotable
//
//  Created by Emiliano Barcia on 17/6/15.
//
//

#import "BubbleView.h"
#import "NSString+FontAwesome.h"
#import "UIImage+FontAwesome.h"

@interface BubbleView()

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSArray * cells;

@end

@implementation BubbleView

#define LIGHT_GRAY [UIColor colorWithRed:235.0f/255.0f green:235.0f/255.0f blue:235.0f/255.0f alpha:1.0];
#define WHITE [UIColor whiteColor];

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    
    [self bringSubviewToFront:self.tableView];
    self.tableView.hidden = YES;
    [self initTableView];
    [self initCells];
    
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    
    return self;

}

-(void)initCells{
    
    UITableViewCell * firstCell = [[UITableViewCell alloc] init];
    firstCell.backgroundColor = WHITE;
    firstCell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.0];
    firstCell.textLabel.textColor = [UIColor blackColor];
    firstCell.textLabel.text = @"Unread";
    firstCell.imageView.image = [UIImage imageWithIcon:@"fa-circle" backgroundColor:[UIColor clearColor] iconColor:[UIColor blackColor] fontSize:18];
    
    UITableViewCell * thirdCell = [[UITableViewCell alloc] init];
    thirdCell.backgroundColor = WHITE;
    thirdCell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.0];
    thirdCell.textLabel.textColor = [UIColor blackColor];
    thirdCell.textLabel.text = @"Files";
    thirdCell.imageView.image = [UIImage imageWithIcon:@"fa-paperclip" backgroundColor:[UIColor clearColor] iconColor:[UIColor blackColor] fontSize:18];
    
    
     UITableViewCell * secondCell = [[UITableViewCell alloc] init];
     secondCell.backgroundColor = WHITE;
     secondCell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.0];
     secondCell.textLabel.textColor = [UIColor blackColor];
     secondCell.textLabel.text = @"Bookmarked";
     secondCell.imageView.image = [UIImage imageWithIcon:@"fa-bookmark" backgroundColor:[UIColor clearColor] iconColor:[UIColor blackColor] fontSize:18];
    
    self.cells = @[firstCell, thirdCell, secondCell];
    
}

-(void)initTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 6, self.frame.size.width, self.frame.size.height - 6)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self addSubview:self.tableView];
    
    UIImageView * menuImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"upArrow.png"]];
    menuImageView.frame = CGRectMake((self.frame.size.width - 12)/2, 0, 12, 6);
    [self addSubview:menuImageView];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
        case 0:
        {
            [self.delegate filterWithFilter:UNREAD];
            break;
        }
        case 1:
        {
            [self.delegate filterWithFilter:FILES];
            break;
        }
        case 2:
        {
            [self.delegate filterWithFilter:BOOKMARKED];
            break;
        }
            
        default:
            break;
    }
    
    [self removeFromSuperview];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.cells objectAtIndex:indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.cells.count;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
}
*/

@end








