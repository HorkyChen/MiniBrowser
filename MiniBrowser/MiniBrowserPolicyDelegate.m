//
//  MiniBrowserPolicyDelegate.m
//  MiniBrowser
//
//  Created by Horky Chen on 4/8/13.
//  Copyright (c) 2013 Horky Chen. All rights reserved.
//
#import <WebKit/WebKit.h>
#import "MiniBrowserPolicyDelegate.h"

@implementation MiniBrowserPolicyDelegate
- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation
        request:(NSURLRequest *)request frame:(WebFrame *)frame
        decisionListener:(id)listener
{
    NSString *host = [[request URL] host];
    if ([host hasSuffix:@"360.cn"])
    {
        [listener ignore];
    }
    else
    {
        [listener use];
    }
}
@end
