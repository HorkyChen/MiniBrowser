//
//  WebInspector.h
//  MiniBrowser
//
//  Created by Horky Chen on 4/9/13.
//  Copyright (c) 2013 Horky Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebInspector : NSObject
{
    WebView *_webView;
}
- (id)initWithWebView:(WebView *)webView;
- (void)detach:(id)sender;
- (void)show:(id)sender;
- (void)showConsole:(id)sender;
@end
