//
//  MiniBrowserWindowController.m
//  MiniBrowser
//
//  Created by Horky Chen on 4/1/13.
//  Copyright (c) 2013 Horky Chen. All rights reserved.
//

#import "MiniBrowserWindowController.h"
#import "MiniBrowserFrameLoaderClients.h"

@interface MiniBrowserWindowController ()
{
    MiniBrowserFrameLoaderClients * frameLoaderClient;
}
@end

@implementation MiniBrowserWindowController

- (id)init {
    if (self = [super initWithWindowNibName:@"MiniBrowserDocument"])
    {
        frameLoaderClient = [[MiniBrowserFrameLoaderClients alloc] initWithController:self];
    }
    return self;
}

-(void)dealloc {
    [frameLoaderClient release];
    [webView release];
    
    [super dealloc];
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSView *mainView = [[self window] contentView];
    webView = [[WebView alloc] initWithFrame:[mainView bounds] frameName:@"" groupName:@""];
    [webView setCustomUserAgent:@"Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A403 Safari/8536.25"];
    
    [webView setUIDelegate:self];
    [webView setFrameLoadDelegate:frameLoaderClient];
    
    [mainView addSubview:webView];
    
    [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
}

- (void)windowDidResize:(NSNotification *)notification {
    [webView setFrame:[[[self window] contentView] bounds]];
}

#pragma mark - Delegate functions of WebView

@end
