//
//  SocialSharing.m
//  VBall ScoreMaster
//
//  Created by Frank Bara on 8/12/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import "SocialSharing.h"



@implementation SocialSharing

- (BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void)sendTwitter:(NSString *)sendText image:(UIImage *)sendImage url:(NSString *)sendURL
{
    //BOOL success = FALSE;
    
    if ([self userHasAccessToTwitter]) {
        twitterController =  [[SLComposeViewController alloc] init];
        twitterController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
//        self.twitterController.completionHandler = ^(SLComposeViewControllerResult result){
//            // Sets the completion handler.  Note that we don't know which thread the
//            // block will be called on, so we need to ensure that any required UI
//            // updates occur on the main queue
//            switch (result) {
//                    //This means the user cancelled without sending tweet
//                case SLComposeViewControllerResultCancelled:
//                    break;
//                    //This means the user hit 'Send'
//                case SLComposeViewControllerResultDone:
//                default:
//                    break;
//                }
//            };
        
        [twitterController setInitialText:sendText];
        [twitterController addImage:sendImage];
        [twitterController addURL:[NSURL URLWithString:sendURL]];
        
        [self presentViewController:twitterController
                           animated:YES
                         completion:nil];
    }
}

- (void)sendFacebook:(SLComposeViewController *)facebookAccount
{
    
}

@end
