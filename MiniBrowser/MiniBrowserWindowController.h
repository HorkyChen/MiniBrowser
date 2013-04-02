//
//  MiniBrowserWindowController.h
//  MiniBrowser
//
//  Created by Horky Chen on 4/1/13.
//  Copyright (c) 2013 Horky Chen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface MiniBrowserWindowController : NSWindowController<NSToolbarDelegate>
{
    IBOutlet NSToolbar *toolbar;    
    WebView *webView;
}

@property (nonatomic,readonly) WebView * webView;
@end
