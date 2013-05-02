//
//  CustomCell.h
//  BayBrowser
//
//  Created by Ethan Arbuckle on 3/23/13.
//
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell
@property (nonatomic, unsafe_unretained) IBOutlet UITextView *titleLabel;
@property (nonatomic, unsafe_unretained) IBOutlet UILabel *seederslabel;
@property (nonatomic, unsafe_unretained) IBOutlet UILabel *sizeLabel;
@property (nonatomic, unsafe_unretained) IBOutlet UILabel *uploadedLabel;
@property (nonatomic) IBOutlet UIButton *descriptionButton;
@end
