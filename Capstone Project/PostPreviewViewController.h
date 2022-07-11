//
//  PostPreviewViewController.h
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 7/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PostPreviewViewController : UIViewController 
@property (strong, nonatomic) IBOutlet UIImageView *progressPic;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) UIImage *selectedImage;

@end

NS_ASSUME_NONNULL_END
