//
//  SceneDelegate.m
//  Capstone Project
//
//  Created by Hugo Gomez Herrera on 7/7/22.
//

#import "SceneDelegate.h"
#import "Parse/Parse.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    // Setting up my parse server with the app
    
    //Code for connecting the parse serer to the app
    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"gZYgnXe8SCncbFRTGiF9ibJQbwzGVGnaBubEk1S8"; //
        configuration.clientKey = @"Ueb4CzWBeeNdFArFuOpFxIZoiqS71UlxDIgnVm7y";
        configuration.server = @"https://parseapi.back4app.com";
    }];

    [Parse initializeWithConfiguration:config];
    
    //User can stay logged in
    if (PFUser.currentUser) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarViewController"];
        self.window.rootViewController = tabBarController;
        //So it goes to the second item of the tab bar first
        [tabBarController setSelectedViewController:[tabBarController.viewControllers objectAtIndex:1]];
            }
}
@end
