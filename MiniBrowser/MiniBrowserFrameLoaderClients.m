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
{
    int resourceCount;
    int resourceFailedCount;
    int resourceCompletedCount;
}
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
        
        resourceFailedCount = 0;
    }
}

- (id)webView:(WebView *)sender
identifierForInitialRequest:(NSURLRequest *)request fromDataSource:(WebDataSource
                                                                    *)dataSource
{
    // Return some object that can be used to identify this resource
    return [NSNumber numberWithInt:resourceCount++];
}

-(NSURLRequest *)webView:(WebView *)sender
                resource:(id)identifier
         willSendRequest:(NSURLRequest *)request
        redirectResponse:(NSURLResponse *)redirectResponse
          fromDataSource:(WebDataSource *)dataSource
{
    // Update the status message
    [self updateResourceStatus];
    return request;
}

-(void)webView:(WebView *)sender resource:(id)identifier
didFailLoadingWithError:(NSError *)error
fromDataSource:(WebDataSource *)dataSource
{
    resourceFailedCount++;
    // Update the status message
    [self updateResourceStatus];
}

-(void)webView:(WebView *)sender
      resource:(id)identifier
didFinishLoadingFromDataSource:(WebDataSource *)dataSource
{
    resourceCompletedCount++;
    // Update the status message
    [self updateResourceStatus];
}

-(void)updateResourceStatus
{
    [controller updateProgress:resourceCompletedCount withTotalCount:resourceCount withErrorCount:resourceFailedCount];
}
@end
