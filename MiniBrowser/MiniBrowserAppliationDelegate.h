//
//  MiniBrowserAppliationDelegate.h
//  MiniBrowser
//
//  Created by Horky Chen on 4/8/13.
//  Copyright (c) 2013 Horky Chen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface MiniBrowserAppliationDelegate : NSObject<NSApplicationDelegate>
{
    
}
@property (nonatomic) NSInteger currentUserAgent;
-(IBAction)chooseUCBrowserIpadUserAgent:(id)sender;
-(IBAction)chooseSafariIpadUserAgent:(id)sender;
-(IBAction)chooseSafariMacOSUserAgent:(id)sender;

@end
