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

-initWithController:(MiniBrowserWindowController *)aController
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
    if (frame == [sender mainFrame])
    {
        NSString *url = [[[[frame provisionalDataSource] request] URL] absoluteString];
        [controller updateTitleAndURL:title withURL:url];
    }
}

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame {
    // Only report feedback for the main frame.
    if (frame == [sender mainFrame])
    {
        NSString *url = [[[[frame provisionalDataSource] request] URL] absoluteString];
        [controller updateURL:url];
    }
}
@end
