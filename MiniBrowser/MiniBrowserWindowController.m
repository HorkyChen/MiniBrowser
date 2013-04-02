//
//  MiniBrowserWindowController.m
//  MiniBrowser
//
//  Created by Horky Chen on 4/1/13.
//  Copyright (c) 2013 Horky Chen. All rights reserved.
//

#import "MiniBrowserWindowController.h"
#import "MiniBrowserFrameLoaderClients.h"

#define kBackToolbarItemID      @"Back"
#define kForwardToolbarItemID      @"Forward"
#define kRefreshToolbarItemID      @"Refresh"
#define kStopToolbarItemID      @"Stop"

#define kDefaultWebPage @"http://www.baidu.com"

//#define OPEN_IN_NEW_WINDOW

@interface MiniBrowserWindowController ()
{
    MiniBrowserFrameLoaderClients * frameLoaderClient;
}
@end

@implementation MiniBrowserWindowController
@synthesize webView;

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

- (void)awakeFromNib
{
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
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
    
    [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kDefaultWebPage]]];
}

- (void)windowDidResize:(NSNotification *)notification {
    [webView setFrame:[[[self window] contentView] bounds]];
}

#pragma mark - WebView UI Delegates
-(WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
#ifdef OPEN_IN_NEW_WINDOW
    id myDocument = [[NSDocumentController sharedDocumentController] openUntitledDocumentAndDisplay:YES error:nil];
    id myController = [[myDocument windowForSheet] delegate];
    [myController performSelector:@selector(loadRequest:) withObject:request];
    return [myController webView];
#else
    [self loadRequest:request];
    return webView;
#endif
}

- (void)webViewShow:(WebView *)sender
{
    id myDocument = [[NSDocumentController sharedDocumentController] documentForWindow:[sender window]];
    [myDocument showWindows];
}
#pragma mark - UI Actions
-(void)loadURL:(NSString *)url
{
    [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

-(void)loadRequest:(NSURLRequest *)urlRequest
{
    [[webView mainFrame] loadRequest:urlRequest];
}


#pragma mark - Toolbar Delegates
- (NSToolbarItem *)toolbarItemWithIdentifier:(NSString *)identifier
                                       label:(NSString *)label
                                 paleteLabel:(NSString *)paletteLabel
                                     toolTip:(NSString *)toolTip
                                      target:(id)target
                                 itemContent:(id)imageOrView
                                      action:(SEL)action
                                        menu:(NSMenu *)menu
{
    // here we create the NSToolbarItem and setup its attributes in line with the parameters
    NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:identifier] autorelease];
    
    [item setLabel:label];
    [item setPaletteLabel:paletteLabel];
    [item setToolTip:toolTip];
    [item setTarget:target];
    [item setAction:action];
    
    // Set the right attribute, depending on if we were given an image or a view
    if([imageOrView isKindOfClass:[NSImage class]]){
        [item setImage:imageOrView];
    } else if ([imageOrView isKindOfClass:[NSView class]]){
        [item setView:imageOrView];
    }else {
        assert(!"Invalid itemContent: object");
    }
    
    
    // If this NSToolbarItem is supposed to have a menu "form representation" associated with it
    // (for text-only mode), we set it up here.  Actually, you have to hand an NSMenuItem
    // (not a complete NSMenu) to the toolbar item, so we create a dummy NSMenuItem that has our real
    // menu as a submenu.
    //
    if (menu != nil)
    {
        // we actually need an NSMenuItem here, so we construct one
        NSMenuItem *mItem = [[[NSMenuItem alloc] init] autorelease];
        [mItem setSubmenu:menu];
        [mItem setTitle:label];
        [item setMenuFormRepresentation:mItem];
    }
    
    return item;
}

#pragma mark - NSToolbarDelegate

//--------------------------------------------------------------------------------------------------
// This is an optional delegate method, called when a new item is about to be added to the toolbar.
// This is a good spot to set up initial state information for toolbar items, particularly ones
// that you don't directly control yourself (like with NSToolbarPrintItemIdentifier here).
// The notification's object is the toolbar, and the @"item" key in the userInfo is the toolbar item
// being added.
//--------------------------------------------------------------------------------------------------
- (void)toolbarWillAddItem:(NSNotification *)notif
{
    NSToolbarItem *addedItem = [[notif userInfo] objectForKey:@"item"];
    
    // Is this the printing toolbar item?  If so, then we want to redirect it's action to ourselves
    // so we can handle the printing properly; hence, we give it a new target.
    //
    if ([[addedItem itemIdentifier] isEqual: NSToolbarPrintItemIdentifier])
    {
        [addedItem setToolTip:@"Print your document"];
        [addedItem setTarget:self];
    }
}

//--------------------------------------------------------------------------------------------------
// This method is required of NSToolbar delegates.
// It takes an identifier, and returns the matching NSToolbarItem. It also takes a parameter telling
// whether this toolbar item is going into an actual toolbar, or whether it's going to be displayed
// in a customization palette.
//--------------------------------------------------------------------------------------------------
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem *toolbarItem = nil;
    
    if ([itemIdentifier isEqualToString:kBackToolbarItemID])
    {
        // 2) Refresh toolbar item
        toolbarItem = [self toolbarItemWithIdentifier:kRefreshToolbarItemID
                                                label:@"Back"
                                          paleteLabel:@"Back"
                                              toolTip:@"Backward."
                                               target:webView
                                          itemContent:[NSImage imageNamed:@"back.png"]
                                               action:@selector(goBack:)
                                                 menu:nil];
    }
    else if ([itemIdentifier isEqualToString:kForwardToolbarItemID])
    {
        // 2) Refresh toolbar item
        toolbarItem = [self toolbarItemWithIdentifier:kRefreshToolbarItemID
                                                label:@"Forward"
                                          paleteLabel:@"Forward"
                                              toolTip:@"Forward."
                                               target:webView
                                          itemContent:[NSImage imageNamed:@"forward.png"]
                                               action:@selector(goForward:)
                                                 menu:nil];
    }
    else if ([itemIdentifier isEqualToString:kRefreshToolbarItemID])
    {
        // 2) Refresh toolbar item
        toolbarItem = [self toolbarItemWithIdentifier:kRefreshToolbarItemID
                                                label:@"Refresh"
                                          paleteLabel:@"Refresh"
                                              toolTip:@"Refresh current opening website."
                                               target:webView
                                          itemContent:[NSImage imageNamed:@"refresh.png"]
                                               action:@selector(reload:)
                                                 menu:nil];
    }
    else if ([itemIdentifier isEqualToString:kStopToolbarItemID])
    {
        // 2) Refresh toolbar item
        toolbarItem = [self toolbarItemWithIdentifier:kRefreshToolbarItemID
                                                label:@"Stop"
                                          paleteLabel:@"Stop"
                                              toolTip:@"Stop the loading"
                                               target:webView
                                          itemContent:[NSImage imageNamed:@"stop.png"]
                                               action:@selector(stopLoading:)
                                                 menu:nil];
    }
    
    return toolbarItem;
}

//--------------------------------------------------------------------------------------------------
// This method is required of NSToolbar delegates.  It returns an array holding identifiers for the default
// set of toolbar items.  It can also be called by the customization palette to display the default toolbar.
//--------------------------------------------------------------------------------------------------
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:  kBackToolbarItemID,
            kForwardToolbarItemID,
            kRefreshToolbarItemID,
            kStopToolbarItemID,
            nil];
    // note:
    // that since our toolbar is defined from Interface Builder, an additional separator and customize
    // toolbar items will be automatically added to the "default" list of items.
}

//--------------------------------------------------------------------------------------------------
// This method is required of NSToolbar delegates.  It returns an array holding identifiers for all allowed
// toolbar items in this toolbar.  Any not listed here will not be available in the customization palette.
//--------------------------------------------------------------------------------------------------
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:  kBackToolbarItemID,
            kForwardToolbarItemID,
            kRefreshToolbarItemID,
            kStopToolbarItemID,
            nil];
    // note:
    // that since our toolbar is defined from Interface Builder, an additional separator and customize
    // toolbar items will be automatically added to the "default" list of items.
}
@end
