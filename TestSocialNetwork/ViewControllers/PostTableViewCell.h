//
//  PostTableViewCell.h
//  TestSocialNetwork
//
//  Created by Roman on 6/8/15.
//  Copyright (c) 2015 Roman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UILabel *lbUserName;
@property (weak, nonatomic) IBOutlet UILabel *lbNamePic;
@property (weak, nonatomic) IBOutlet UILabel *lbLocation;
//@property (weak, nonatomic) IBOutlet UIButton *btnPlay;

@end
