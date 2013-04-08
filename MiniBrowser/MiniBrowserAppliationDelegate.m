//
//  MiniBrowserAppliationDelegate.m
//  MiniBrowser
//
//  Created by Horky Chen on 4/8/13.
//  Copyright (c) 2013 Horky Chen. All rights reserved.
//

#import "MiniBrowserAppliationDelegate.h"
#include "CommonDefinition.h"

@implementation MiniBrowserAppliationDelegate
@synthesize currentUserAgent;

-(IBAction)chooseUCBrowserIpadUserAgent:(id)sender
{
    self.currentUserAgent = USER_AGENT_UCBROWSER_IPAD;
}

-(IBAction)chooseSafariIpadUserAgent:(id)sender
{
    self.currentUserAgent = USER_AGENT_SAFARI_IPAD;
}
-(IBAction)chooseSafariMacOSUserAgent:(id)sender
{
    self.currentUserAgent = USER_AGENT_SAFAR_MACOS;
}
@end
