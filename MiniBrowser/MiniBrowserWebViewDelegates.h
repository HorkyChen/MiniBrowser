//
//  MiniBrowserWebViewDelegates.h
//  MiniBrowser
//
//  Created by Horky Chen on 4/9/13.
//  Copyright (c) 2013 Horky Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MiniBrowserWindowController.h"

@interface MiniBrowserWebViewDelegates : NSObject
{
    MiniBrowserWindowController * controller;
}
-initWithController:(MiniBrowserWindowController *)aController;
@end
