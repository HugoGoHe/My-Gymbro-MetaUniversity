//
//  PostPreviewViewController.h
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 7/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PostPreviewViewControllerDelegate

- (void) didPost;

@end

@interface PostPreviewViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *progressPic;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextField *weightLabel;
@property (strong, nonatomic) UIImage *selectedImage;

@property (strong, nonatomic) id<PostPreviewViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
