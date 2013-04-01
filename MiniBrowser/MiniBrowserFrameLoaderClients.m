//
//  MiniBrowserFrameLoaderClients.m
//  MiniBrowser
//
//  Created by Horky Chen on 4/1/13.
//  Copyright (c) 2013 Horky Chen. All rights reserved.
//
#import <WebKit/WebKit.h>
#import "MiniBrowserFrameLoaderClients.h"

@interface MiniBrowserFrameLoaderClients ()

@end

@implementation MiniBrowserFrameLoaderClients

-initWithController:(NSWindowController *)aController
{
    self = [super init];
    
    if(self)
    {
        controller = aController;
    }
    return self;
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    [[controller window] setTitle:title];
}
@end
