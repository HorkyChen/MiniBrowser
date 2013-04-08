//
//  MiniBrowserDocument.m
//  MiniBrowser
//
//  Created by Horky Chen on 4/1/13.
//  Copyright (c) 2013 Horky Chen. All rights reserved.
//

#import "MiniBrowserDocument.h"
#import "MiniBrowserWindowController.h"

@implementation MiniBrowserDocument
@synthesize currentUserAgent;

- (id)init
{
    self = [super init];
    if (self) {
        self.currentUserAgent = USER_AGENT_SAFARI_IPAD;
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MiniBrowserDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (void)makeWindowControllers {
    NSArray *myControllers = [self windowControllers];
    
    // If this document displaced a transient document, it will already have been assigned a window controller. If that is not the case, create one.
    if ([myControllers count] == 0)
    {
        [self addWindowController:[[[MiniBrowserWindowController allocWithZone:[self zone]] init] autorelease]];
    }
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return YES;
}

- (IBAction)saveDocument:(id)sender
{
    return;
}

-(IBAction)chooseUCBrowserIpadUserAgent:(id)sender
{
    self.currentUserAgent = USER_AGENT_UCBROWSER_IPAD;
    [self reloadAfterUAChanged];
    [self updateUAMenuItems:(NSMenuItem *) sender];
    ASLogInfo(@"Changed UA to UCBrowser(iPad)");
}

-(IBAction)chooseSafariIpadUserAgent:(id)sender
{
    self.currentUserAgent = USER_AGENT_SAFARI_IPAD;
    [self reloadAfterUAChanged];
    [self updateUAMenuItems:(NSMenuItem *) sender];
    ASLogInfo(@"Changed UA to Safari(iPad)");
}
-(IBAction)chooseSafariMacOSUserAgent:(id)sender
{
    self.currentUserAgent = USER_AGENT_SAFARI_MACOS;
    [self reloadAfterUAChanged];
    [self updateUAMenuItems:(NSMenuItem *) sender];
    ASLogInfo(@"Changed UA to Safari(Mac OS)");
}
-(IBAction)chooseChromeUserAgent:(id)sender
{
    self.currentUserAgent = USER_AGENT_CHROME;
    [self reloadAfterUAChanged];
    [self updateUAMenuItems:(NSMenuItem *) sender];
    ASLogInfo(@"Changed UA to Chrome(Mac OS)");
}
-(void)updateUAMenuItems:(NSMenuItem *)item
{
    NSMenu *menu = [item menu];
    for(NSMenuItem *subitem in [menu itemArray])
    {
        [subitem setState:NSOffState];
    }
    [item setState:NSOnState];
}

-(void)reloadAfterUAChanged
{
    for(id controller in [self windowControllers])
    {
        if ([controller respondsToSelector:@selector(forceReload)])
        {
            [controller performSelector:@selector(forceReload)];
        }
    }
}
@end
