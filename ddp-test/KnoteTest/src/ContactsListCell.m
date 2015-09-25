//
//  ContactsListCell.m
//  Example
//
//  Created by wuli on 2/9/15.
//  Copyright (c) 2015 smart4c. All rights reserved.
//

#import "ContactsListCell.h"
#import "Masonry.h"
#import "UIImage+RoundedCorner.h"
#import "CUtil.h"
#define kImgH 30.0f
@interface ContactsListCell ()
@property (nonatomic, strong) SDImageCache *imageCache;
@end
@implementation ContactsListCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imageCache = [[SDImageCache alloc] init];
        self.imageView0 = [[UIImageView alloc] init];
        [self.contentView addSubview:self.imageView0];
        [self.imageView0 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(2));
            make.left.equalTo(@(2));
            make.width.equalTo(@(kImgH));
            make.height.equalTo(@(kImgH));
        }];
        self.imageView1 = [[UIImageView alloc] init];
        [self.contentView addSubview:self.imageView1];
        [self.imageView1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(2));
            make.left.equalTo(self.imageView0.mas_right).offset(2);
            make.width.equalTo(@(kImgH));
            make.height.equalTo(@(kImgH));
        }];
        self.imageView2 = [[UIImageView alloc] init];
        [self.contentView addSubview:self.imageView2];
        [self.imageView2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(2));
            make.left.equalTo(self.imageView1.mas_right).offset(2);
            make.width.equalTo(@(kImgH));
            make.height.lessThanOrEqualTo(@(kImgH));
        }];
        self.imageView3 = [[UIImageView alloc] init];
        [self.contentView addSubview:self.imageView3];
        [self.imageView3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(2));
            make.left.equalTo(self.imageView2.mas_right).offset(2);
            make.width.equalTo(@(kImgH));
            make.height.equalTo(@(kImgH));
        }];
        self.imageView4 = [[UIImageView alloc] init];
        [self.contentView addSubview:self.imageView4];
        [self.imageView4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(2));
            make.left.equalTo(self.imageView3.mas_right).offset(2);
            make.width.equalTo(@(kImgH));
            make.height.equalTo(@(kImgH));
        }];
        self.nameLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.nameLabel];
        self.nameLabel.font = [UIFont boldSystemFontOfSize:10];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView0.mas_bottom);
            make.left.equalTo(@(2));
            make.right.equalTo(@(-2));
            make.height.lessThanOrEqualTo(@(12));
        }];
        self.fullNameLabel = [[UILabel alloc] init];
        self.fullNameLabel.font = [UIFont boldSystemFontOfSize:10];
        [self.contentView addSubview:self.fullNameLabel];
        [self.fullNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom);
            make.left.equalTo(@(2));
            make.right.equalTo(@(-2));
            make.height.lessThanOrEqualTo(@(12));
        }];
        
        self.emailLabel = [[UILabel alloc] init];
        self.emailLabel.font = [UIFont boldSystemFontOfSize:10];
        self.emailLabel.numberOfLines = 2;
        self.emailLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:self.emailLabel];
        [self.emailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.fullNameLabel.mas_bottom);
            make.left.equalTo(@(2));
            make.right.equalTo(@(-2));
            make.bottom.equalTo(@(-2));
        }];
        self.fullNameLabel.textColor = [UIColor darkGrayColor];
        self.nameLabel.textColor = [UIColor darkGrayColor];
//        self.fullNameLabel.backgroundColor = [UIColor purpleColor];
//        self.nameLabel.backgroundColor = [UIColor redColor];
//        self.emailLabel.backgroundColor = [UIColor blueColor];
        self.emailLabel.textColor = [UIColor darkGrayColor];
    }
    return self;
}
- (void)awakeFromNib {
    // Initialization code
}

-(void)setContentDic:(NSDictionary *)contentDic
{
//    if (_contentDic != contentDic)
    {
        _contentDic = contentDic;
        NSString *avatar_mini = @"";
        if (contentDic[@"avatar"] && [contentDic[@"avatar"] isKindOfClass:[NSDictionary class]] && [contentDic[@"avatar"][@"mini"]  isKindOfClass:[NSString class]]) {
            avatar_mini = contentDic[@"avatar"][@"mini"];
        }
        NSString *avatar_path = @"";
        if (contentDic[@"avatar"] && [contentDic[@"avatar"] isKindOfClass:[NSDictionary class]] && [contentDic[@"avatar"][@"path"]  isKindOfClass:[NSString class]]) {
            avatar_path = contentDic[@"avatar"][@"path"];
        }
        NSString *avatar_uploaded_mini = @"";
        if (contentDic[@"avatar_uploaded"] && [contentDic[@"avatar_uploaded"] isKindOfClass:[NSDictionary class]] && [contentDic[@"avatar_uploaded"][@"mini"]  isKindOfClass:[NSString class]]) {
            avatar_uploaded_mini = contentDic[@"avatar_uploaded"][@"mini"];
        }
        NSString *avatar_uploaded_path = @"";
        if (contentDic[@"avatar_uploaded"] && [contentDic[@"avatar_uploaded"] isKindOfClass:[NSDictionary class]] && [contentDic[@"avatar_uploaded"][@"path"]  isKindOfClass:[NSString class]]) {
            avatar_uploaded_path = contentDic[@"avatar_uploaded"][@"path"];
        }
        if (avatar_mini && [avatar_mini isKindOfClass:[NSString class]]) {
            [self.imageView0 sd_setImageWithURL:[NSURL URLWithString:avatar_mini] placeholderImage:[UIImage imageNamed:@"avator_placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image) {
                    self.imageView0.image = [image circleImageWithSize:kImgH];
                }
            }];
        } else {
            [self.imageView0 sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"red_light"]];
        }
        if (avatar_path && [avatar_path isKindOfClass:[NSString class]]) {
            [self.imageView1 sd_setImageWithURL:[NSURL URLWithString:avatar_path] placeholderImage:[UIImage imageNamed:@"avator_placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image) {
                    self.imageView1.image = [image circleImageWithSize:kImgH];
                }
            }];
        } else {
            [self.imageView1 sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"red_light"]];
        }
        if (avatar_uploaded_mini && [avatar_uploaded_mini isKindOfClass:[NSString class]]) {
            [self.imageView2 sd_setImageWithURL:[NSURL URLWithString:avatar_uploaded_mini] placeholderImage:[UIImage imageNamed:@"avator_placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image) {
                    self.imageView2.image = [image circleImageWithSize:kImgH];
                }
            }];
        } else {
            [self.imageView2 sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"red_light"]];
        }
        if (avatar_uploaded_path && [avatar_uploaded_path isKindOfClass:[NSString class]]) {
            [self.imageView3 sd_setImageWithURL:[NSURL URLWithString:avatar_uploaded_path] placeholderImage:[UIImage imageNamed:@"avator_placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image) {
                    self.imageView3.image = [image circleImageWithSize:kImgH];
                }
            }];
        } else {
            [self.imageView3 sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"red_light"]];
        }
        NSString *username = contentDic[@"username"];
        self.nameLabel.text = [NSString stringWithFormat:@"%@(username)",username];
        NSString *fullname = contentDic[@"fullname"];
        self.fullNameLabel.text = [NSString stringWithFormat:@"%@(fullname)",fullname];
        NSArray *emails = contentDic[@"emails"];
        if ([emails isKindOfClass:[NSArray class]]) {
            self.emailLabel.text = [NSString stringWithFormat:@"%@(emails)",[emails componentsJoinedByString:@"|"]];
        } else if ([emails isKindOfClass:[NSString class]]) {
            self.emailLabel.text = [NSString stringWithFormat:@"%@(emails)",emails];
        }
        if (fullname && [fullname isKindOfClass:[NSString class]]) {
            NSArray *names = [fullname componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSMutableString *sub = [@"" mutableCopy];
            for (NSString *tmp in names) {
                if ([tmp length]>=1) {
                    [sub appendString:[[tmp substringWithRange:NSMakeRange(0, 1)] uppercaseString]];
                }
            }
            NSString *key = [NSString stringWithFormat:@"%@%@",fullname,contentDic[@"bgcolor"]];
            UIImage *img = [self.imageCache imageFromDiskCacheForKey:key];
            if (!img) {
                img = [[CUtil imageText:sub withBackground:contentDic[@"bgcolor"] size:CGSizeMake(kImgH, kImgH) rate:0.6] circleImageWithSize:kImgH];
                [self.imageCache storeImage:img forKey:key toDisk:YES];
            }
            self.imageView4.image = img;
        } else if (username && [username isKindOfClass:[NSString class]]) {
            NSArray *names = [username componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSMutableString *sub = [@"" mutableCopy];
            for (NSString *tmp in names) {
                if ([tmp length]>=1) {
                    [sub appendString:[[tmp substringWithRange:NSMakeRange(0, 1)] uppercaseString]];
                }
            }
            NSString *key = [NSString stringWithFormat:@"%@%@",username,contentDic[@"bgcolor"]];
            UIImage *img = [self.imageCache imageFromDiskCacheForKey:key];
            if (!img) {
                img =  [[CUtil imageText:sub withBackground:contentDic[@"bgcolor"] size:CGSizeMake(kImgH, kImgH) rate:0.6] circleImageWithSize:kImgH];
                [self.imageCache storeImage:img forKey:key toDisk:YES];
            }
            self.imageView4.image = img;
        }  else {
            NSArray *names = [self.emailLabel.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSMutableString *sub = [@"" mutableCopy];
            for (NSString *tmp in names) {
                if ([tmp length]>=1) {
                    [sub appendString:[[tmp substringWithRange:NSMakeRange(0, 1)] uppercaseString]];
                }
            }
            self.imageView4.image = [[CUtil imageText:sub withBackground:contentDic[@"bgcolor"] size:CGSizeMake(kImgH, kImgH) rate:0.6] circleImageWithSize:kImgH];
        }
        NSLog(@"%@",avatar_mini);
        NSLog(@"%@",avatar_path);
        NSLog(@"%@",avatar_uploaded_mini);
        NSLog(@"%@",avatar_uploaded_path);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
