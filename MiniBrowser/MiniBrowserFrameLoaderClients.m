//
//  MiniBrowserFrameLoaderClients.m
//  MiniBrowser
//
//  Created by Horky Chen on 4/1/13.
//  Copyright (c) 2013 Horky Chen. All rights reserved.
//
#import <WebKit/WebKit.h>
#import "MiniBrowserFrameLoaderClients.h"
#import "ASLogger.h"

@interface MiniBrowserFrameLoaderClients ()
{
    int resourceCount;
    int resourceFailedCount;
    int resourceCompletedCount;
}
@end

@implementation MiniBrowserFrameLoaderClients

#pragma mark - Frame Loading Delegate
- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
    if (frame == [sender mainFrame])
    {
        NSString *url = [[[[frame provisionalDataSource] request] URL] absoluteString];
        [controller handleStartingWithConfirmedURL:url];
        [self clearResourceCount];
    }
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    if (frame == [sender mainFrame])
    {
        NSString *url = [sender mainFrameURL];
        [controller updateTitleAndURL:title withURL:url];
    }
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    if (frame == [sender mainFrame])
    {
        [controller finishedFrameLoading];
    }
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    if (frame == [sender mainFrame])
    {
        [controller handleErrorInformation:error];
    }
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    if (frame == [sender mainFrame])
    {
        [controller handleErrorInformation:error];
    }
}

#pragma mark - Resource Loading Delegate

- (id)webView:(WebView *)sender identifierForInitialRequest:(NSURLRequest *)request fromDataSource:(WebDataSource *)dataSource
{
    ASLogInfo(@"Loading:%@",[[request URL] relativeString]);
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

-(void)webView:(WebView *)sender resource:(id)identifier  didFailLoadingWithError:(NSError *)error
fromDataSource:(WebDataSource *)dataSource
{
    if([dataSource subresources] && [[dataSource subresources] count])
    {
        ASLogInfo(@"Failed:%@",[[[[dataSource subresources] objectAtIndex:0] URL] relativeString]);
    }
    else
    {
        ASLogInfo(@"Failed:%@",[[[dataSource request] URL] relativeString]);
    }
    resourceFailedCount++;
    // Update the status message
    [self updateResourceStatus];
}

-(void)webView:(WebView *)sender
      resource:(id)identifier
    didFinishLoadingFromDataSource:(WebDataSource *)dataSource
{
    if([dataSource subresources] && [[dataSource subresources] count] )
    {
        ASLogInfo(@"Loaded:%@",[[[[dataSource subresources] objectAtIndex:0] URL] relativeString]);
    }
    else
    {
        ASLogInfo(@"Loaded:%@",[[[dataSource request] URL] relativeString]);
    }
    resourceCompletedCount++;
    // Update the status message
    [self updateResourceStatus];
}

-(void)updateResourceStatus
{
    [controller updateProgress:resourceCompletedCount withTotalCount:resourceCount withErrorCount:resourceFailedCount];
}

-(void)clearResourceCount
{
    resourceCompletedCount = 0;
    resourceCount = 0;
    resourceFailedCount = 0;
}
@end
