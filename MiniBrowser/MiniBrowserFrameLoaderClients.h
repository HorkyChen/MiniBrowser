//
//  MiniBrowserFrameLoaderClients.h
//  MiniBrowser
//
//  Created by Horky Chen on 4/1/13.
//  Copyright (c) 2013 Horky Chen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MiniBrowserWindowController.h"

@interface MiniBrowserFrameLoaderClients : NSObject
{
    MiniBrowserWindowController * controller;
}
-initWithController:(MiniBrowserWindowController *)aController;
@end
