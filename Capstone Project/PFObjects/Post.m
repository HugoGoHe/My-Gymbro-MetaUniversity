//
//  Post.m
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 7/11/22.
//

#import "Post.h"

@implementation Post

@dynamic postedAt;
@dynamic weight;
@dynamic image;
@dynamic author;

+ (nonnull NSString *)parseClassName {
    return @"Post";
}

+ (void) postUserImage: ( UIImage * _Nullable )image withWeight: (float)weight  withDate: (NSDate *_Nullable)postedAt withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    Post *newPost = [Post new];
    newPost.postedAt = postedAt;
    newPost.weight = weight;
    newPost.image = [self getPFFileFromImage:image];
    newPost.author = [PFUser currentUser];
    [newPost saveInBackgroundWithBlock:completion];
}

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
    // check if image is not nil
    if (!image) {
        return nil;
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}
@end
