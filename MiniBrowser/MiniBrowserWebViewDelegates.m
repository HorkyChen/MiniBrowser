//
//  MiniBrowserWebViewDelegates.m
//  MiniBrowser
//
//  Created by Horky Chen on 4/9/13.
//  Copyright (c) 2013 Horky Chen. All rights reserved.
//

#import "MiniBrowserWebViewDelegates.h"

@implementation MiniBrowserWebViewDelegates
-initWithController:(MiniBrowserWindowController *)aController
{
    self = [super init];
    
    if(self)
    {
        controller = aController;
    }
    return self;
}
@end
