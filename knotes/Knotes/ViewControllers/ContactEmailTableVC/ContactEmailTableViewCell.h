//
//  ContactEmailTableViewCell.h
//  Knotable
//
//  Created by Emiliano Barcia Lizarazu on 14/1/15.
//
//

#import <UIKit/UIKit.h>

@interface ContactEmailTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

-(void)initWitDescription:(NSString *) description andMail:(NSString *)mail;

@end
