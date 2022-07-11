//
//  PostPreviewViewController.h
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 7/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PostPreviewViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *progressPic;

@end

NS_ASSUME_NONNULL_END
