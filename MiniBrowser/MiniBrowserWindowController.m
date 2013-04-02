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
#define kAddressBarID @"Address"

#define kDefaultWebPage @"http://www.baidu.com"

#define kToolBarICONWidth 32
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
    [toolbar setDisplayMode:NSToolbarDisplayModeIconOnly];
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

#pragma mark - Window Controller Interface
-(void)updateTitleAndURL:(NSString *)title withURL:(NSString *)url
{
    [[self window] setTitle:title];
}

-(void)updateURL:(NSString *)url
{
    NSToolbarItem * item = [self getToolbarItemWithIdentifier:kAddressBarID];
    assert(item);
    [(NSTextField *)[item view] setStringValue:url];
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

-(NSToolbarItem *) getToolbarItemWithIdentifier:(NSString *)identifier
{
    NSToolbarItem * result;
    for(NSToolbarItem * item in [[[self window] toolbar] items])
    {
        if([[item itemIdentifier] isEqualToString:kAddressBarID])
        {
            result = item;
            break;
        }
    }
    return result;
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
    
    if (menu != nil)
    {
        // we actually need an NSMenuItem here, so we construct one
        NSMenuItem *mItem = [[[NSMenuItem alloc] init] autorelease];
        [mItem setSubmenu:menu];
        [mItem setTitle:label];
        [item setMenuFormRepresentation:mItem];
    }
    
    if ([identifier isEqual: kAddressBarID])
    {
        [item setMinSize: NSSizeFromString(@"{width=100; height=32}")];
        [item setMaxSize: NSSizeFromString(@"{width=800; height=32}")];
        [item setTarget:self];
    }
    return item;
}

#pragma mark - NSToolbarDelegate

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem *toolbarItem = nil;
    
    if ([itemIdentifier isEqualToString:kBackToolbarItemID])
    {
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
        toolbarItem = [self toolbarItemWithIdentifier:kRefreshToolbarItemID
                                                label:@"Stop"
                                          paleteLabel:@"Stop"
                                              toolTip:@"Stop the loading"
                                               target:webView
                                          itemContent:[NSImage imageNamed:@"stop.png"]
                                               action:@selector(stopLoading:)
                                                 menu:nil];
    }
    else if ([itemIdentifier isEqualToString:kAddressBarID])
    {
        NSRect editorRect = NSRectFromCGRect(CGRectMake(4*kToolBarICONWidth,5,200,kToolBarICONWidth));
        NSTextField * addressEditor = [[NSTextField alloc] initWithFrame:editorRect];
        [addressEditor setBezelStyle:NSTextFieldRoundedBezel];
        [addressEditor setDelegate:self];
        
        toolbarItem = [self toolbarItemWithIdentifier:kAddressBarID
                                                label:@""
                                          paleteLabel:@""
                                              toolTip:@"Enter the URL."
                                               target:webView
                                          itemContent: addressEditor
                                               action:nil
                                                 menu:nil];
    }
    
    return toolbarItem;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:  kBackToolbarItemID,
            kForwardToolbarItemID,
            kRefreshToolbarItemID,
            kStopToolbarItemID,
            kAddressBarID,
            nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:  kBackToolbarItemID,
            kForwardToolbarItemID,
            kRefreshToolbarItemID,
            kStopToolbarItemID,
            kAddressBarID,
            nil];
}
@end
