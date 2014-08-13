//
//  SocialSharing.h
//  VBall ScoreMaster
//
//  Created by Frank Bara on 8/12/14.
//  Copyright (c) 2014 BaraLabs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface SocialSharing : UIViewController
{
    SLComposeViewController *twitterController;
    SLComposeViewController *facebookController;
}

//@property (nonatomic, strong)SLComposeViewController *twitterController;
//@property (nonatomic, strong)SLComposeViewController *facebookController;


- (void)sendFacebook:(SLComposeViewController *)facebookAccount;
- (void)sendTwitter:(NSString *)sendText image:(UIImage *)sendImage url:(NSString *)sendURL;

@end
