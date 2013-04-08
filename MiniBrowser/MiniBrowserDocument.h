//
//  MiniBrowserDocument.h
//  MiniBrowser
//
//  Created by Horky Chen on 4/1/13.
//  Copyright (c) 2013 Horky Chen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface MiniBrowserDocument : NSDocument
@property (nonatomic) NSInteger currentUserAgent;

-(IBAction)chooseUCBrowserIpadUserAgent:(id)sender;
-(IBAction)chooseSafariIpadUserAgent:(id)sender;
-(IBAction)chooseSafariMacOSUserAgent:(id)sender;
@end
