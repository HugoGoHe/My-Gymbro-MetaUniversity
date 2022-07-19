//
//  Post.h
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 7/11/22.
//
#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProgressPic : PFObject<PFSubclassing>

@property (nonatomic, strong) NSDate *postedAt;
@property (nonatomic) float weight;
@property (nonatomic, strong) PFFileObject *image;
@property (nonatomic, strong) PFUser *author;

+ (void) postUserImage: ( UIImage * _Nullable )image withWeight: (float)weight  withDate: (NSDate *_Nullable)postedAt withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
