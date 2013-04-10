//
//  MiniBrowserWindowController.m
//  MiniBrowser
//
//  Created by Horky Chen on 4/1/13.
//  Copyright (c) 2013 Horky Chen. All rights reserved.
//

#import "MiniBrowserWindowController.h"
#import "MiniBrowserFrameLoaderClients.h"
#import "MiniBrowserPolicyDelegate.h"
#include "CommonDefinition.h"
#import "MiniBrowserDocument.h"
#import "WebInspector.h"
#import "MiniBrowserNavigatorButton.h"

const static int kToolBarICONWidth = 32;
static NSArray * internalPageList;
//#define OPEN_IN_NEW_WINDOW

@interface MiniBrowserWindowController ()
{
    MiniBrowserFrameLoaderClients * frameLoaderClient;
    MiniBrowserPolicyDelegate * policyDelegate;
    WebInspector * inspector;
    
    INTERNAL_PAGE_INDEX currentInternalPage;
    WebView * internalPageWebView;
    
    NSMenu *backMenu;
    NSMenu *forwardMenu;
}
@end

@implementation MiniBrowserWindowController
@synthesize webView;

- (id)init {
    if (self = [super initWithWindowNibName:@"MiniBrowserDocument"])
    {
        frameLoaderClient = [[MiniBrowserFrameLoaderClients alloc] initWithController:self];
        policyDelegate = [[MiniBrowserPolicyDelegate alloc] initWithController:self];
        [self enableWebInspector];
        
        [self initInternalPageList];
    }
    
    return self;
}

-(void)dealloc {
    [frameLoaderClient release];
    [webView release];
    [internalPageWebView release];
    
    [super dealloc];
}

-(void)enableWebInspector
{
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"WebKitDeveloperExtras"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    
    [webView setUIDelegate:self];
    [webView setFrameLoadDelegate:frameLoaderClient];
    [webView setResourceLoadDelegate:frameLoaderClient];
    [webView setPolicyDelegate:policyDelegate];
    
    [mainView addSubview:webView];
    
    [self loadURL:kDefaultWebPage];
}

- (void)close
{
    //Clear the delegates
    [webView setUIDelegate:nil];
    [webView setFrameLoadDelegate:nil];
    [webView setResourceLoadDelegate:nil];
    [webView setPolicyDelegate:nil];
    
    [super close];
}

- (void)windowDidResize:(NSNotification *)notification
{
    [webView setFrame:[[[self window] contentView] bounds]];
}

-(void)updateUserAgent
{
    MiniBrowserDocument * document = [self document];
    NSString * userAgent ;
    switch(document.currentUserAgent)
    {
        case USER_AGENT_SAFARI_IPAD:
            userAgent = UserAgent_SafariIpad;
            break;
        case USER_AGENT_SAFARI_MACOS:
            userAgent = UserAgent_SafariMacOS;
            break;
        case USER_AGENT_CHROME:
            userAgent = UserAgent_Chrome;
            break;
        case USER_AGENT_UCBROWSER_IPAD:
        default:
            userAgent = UserAgent_UCBrowserIpad;
            break;
    }
    
    [webView setCustomUserAgent:userAgent];
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
    if ( currentInternalPage )
    {
        [[self window] setTitle:[self getInternalPageTitle:currentInternalPage]];
    }
    else
    {
        [self bringWebViewOut];
        [[self window] setTitle:title];
    }
    [self addBackPageItem:url withTitle:title];
}

-(void)handleStartingWithConfirmedURL:(NSString *)url
{
    NSToolbarItem * item = [self getToolbarItemWithIdentifier:kAddressToolbarItemID];
    assert(item);
    [(NSTextField *)[item view] setStringValue:url];
    
    currentInternalPage = PAGE_NONE;
}

-(void)finishedFrameLoading
{
    NSToolbarItem * item = [self getToolbarItemWithIdentifier:kProgressToolbaritemID];
    assert(item);
    
    [(NSProgressIndicator *)[item view] stopAnimation:nil];
    [(NSProgressIndicator *)[item view] setHidden:YES];
}

-(void)handleErrorInformation:(NSError *)error
{
    [self showInternalWebPages:PAGE_ERROR withParameter:error];
}

-(void)showWebInspectorWithParameter:(NSNumber *)console
{
    if ( !webView )
        return;
    
    if( !inspector ){
        inspector = [[WebInspector alloc] initWithWebView:webView];
        [inspector detach:webView];
    }
    
    if([console boolValue])
    {
        [inspector showConsole:webView];
    }
    else
    {
        [inspector show:webView];
    }
}

-(void)updateProgress:(int)completedCount withTotalCount:(int)totalCount withErrorCount:(int)errorCount
{
    ASLogDebug(@"Progress:%d,%d,%d",totalCount,completedCount,errorCount);
    
    if( (completedCount+errorCount) >= totalCount)
    {
        [self finishedFrameLoading];
    }
    else
    {
        NSToolbarItem * item = [self getToolbarItemWithIdentifier:kProgressToolbaritemID];
        assert(item);
        [(NSProgressIndicator *)[item view] setHidden:NO];
        [(NSProgressIndicator *)[item view] startAnimation:nil];
    }
}

#pragma mark - Internal Page Management
-(void)showInternalWebPages:(int)pageIndex withParameter:(id)parameter
{
    NSString* pCurPath = [[NSBundle mainBundle] resourcePath];
    
    currentInternalPage = pageIndex;
    
    switch(pageIndex)
    {
        case PAGE_ERROR:
            pCurPath = [NSString stringWithFormat:@"file://%@/%@?errorcode=%ld",pCurPath,
                                            [self getInternalPageFileName:currentInternalPage],
                                            [(NSError*)parameter code]
                                    ];
            break;
        default:
            pCurPath = nil;
            currentInternalPage = PAGE_NONE;
            break;
    }
    
    if(pCurPath)
    {
        [self displayPageWithInternalPageWebView:pCurPath];
    }
}

-(void)displayPageWithInternalPageWebView:(NSString *)pageURL
{
    NSView *mainView = [[self window] contentView];
    
    if(!internalPageWebView)
    {
        internalPageWebView = [[WebView alloc] initWithFrame:[mainView bounds] frameName:@"InternalPageOfMiniBrowser" groupName:@""];
        
        [mainView addSubview:internalPageWebView];
    }
    
    [[internalPageWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:pageURL]]];
    
    [self bringInternalPageWebViewOut];
}

-(void)bringWebViewOut
{
    [internalPageWebView setHidden:YES];
}

-(void)bringInternalPageWebViewOut
{
    [internalPageWebView setHidden:NO];
}

#pragma mark - Internal Page List
-(void)initInternalPageList
{
    if(nil!=internalPageList)
        return;

    internalPageList = [[NSArray arrayWithObjects:
                        // PAGE_TITLE, PAGE_FILE_NAME
                         [NSArray arrayWithObjects:@"",@"", nil], //PAGE_NONE
                         [NSArray arrayWithObjects:@"Failed to load the page",@"errors.html", nil], //PAGE_ERROR
                         nil
                         ] retain];
}

-(NSString *)getInternalPageTitle:(INTERNAL_PAGE_INDEX)pageIndex
{
    return [self getInternalPageStringValue:pageIndex withKeyIndex:PAGE_TITLE];
}

-(NSString *)getInternalPageFileName:(INTERNAL_PAGE_INDEX)pageIndex
{
    return [self getInternalPageStringValue:pageIndex withKeyIndex:PAGE_FILE_NAME];
}

-(NSString *)getInternalPageStringValue:(INTERNAL_PAGE_INDEX)pageIndex withKeyIndex:(INTERNAL_PAGE_LIST_KEY_INDEX)keyIndex
{
    NSString * resString = nil;
    NSArray * pageItem = [internalPageList objectAtIndex:pageIndex];
    if(pageItem)
    {
        resString = [pageItem objectAtIndex:keyIndex];
    }
    
    return resString;
}

#pragma mark - UI Actions
-(void)loadURL:(NSString *)url
{
    NSString * targetURL = url;
    if(! ( [[url lowercaseString] hasPrefix:@"http://"]
          || [[url lowercaseString] hasPrefix:@"https://"]
          || [[url lowercaseString] hasPrefix:@"file://"]))
    {
        targetURL = [NSString stringWithFormat:@"http://%@",url];
    }
    
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:targetURL]]];
}

-(void)loadRequest:(NSURLRequest *)urlRequest
{
    currentInternalPage = PAGE_NONE;
    [self updateUserAgent];
    [[webView mainFrame] loadRequest:urlRequest];
}

- (IBAction)openNewURL:(id)sender
{
    NSToolbarItem * item = [self getToolbarItemWithIdentifier:kAddressToolbarItemID];
    [self loadURL:[(NSTextField *)[item view] stringValue]];
}

-(void)forceReload
{
    [self loadURL: [webView mainFrameURL]];
}

-(IBAction)chooseHistoryItem:(id)sender
{
    assert([sender isKindOfClass:[NSMenuItem class]] && [sender toolTip]);
    [self loadURL:[sender toolTip]];
}

#pragma mark - Address Editor Delegate
- (NSArray *)control:(NSControl *)control textView:(NSTextView *)textView completions:(NSArray *)words
 forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index
{
    return nil;
}

-(void)controlTextDidEndEditing:(NSNotification *)notification
{
    // See if it was due to a return
    if ( [[[notification userInfo] objectForKey:@"NSTextMovement"] intValue] == NSReturnTextMovement )
    {
        NSTextView * fieldEditor = [[notification userInfo] objectForKey:@"NSFieldEditor"];
        NSString * theString = [[fieldEditor textStorage] string];
        NSTextField * controller = [notification object];
        [controller.window.delegate performSelector:@selector(loadURL:) withObject:theString];
    }
}

#pragma mark - Toolbar Delegates
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem *toolbarItem = nil;
    NSRect buttonRect = NSRectFromCGRect(CGRectMake(0,0,kToolBarICONWidth,kToolBarICONWidth));
    
    if ([itemIdentifier isEqualToString:kBackToolbarItemID])
    {        
        MiniBrowserNavigatorButton * button =  [[[MiniBrowserNavigatorButton alloc] initWithFrame:buttonRect]autorelease];
        [button setAction:@selector(goBack:)];
        [button setTarget:webView];
        [button setImage:[NSImage imageNamed:@"back.png"]];
        
        toolbarItem = [self toolbarItemWithIdentifier:kBackToolbarItemID
                                                label:@"Back"
                                          paleteLabel:@"Back"
                                              toolTip:@"Backward."
                                               target:webView
                                          itemContent:button
                                               action:@selector(goBack:)
                                                 menu:nil];
    }
    else if ([itemIdentifier isEqualToString:kForwardToolbarItemID])
    {
        toolbarItem = [self toolbarItemWithIdentifier:kForwardToolbarItemID
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
        toolbarItem = [self toolbarItemWithIdentifier:kStopToolbarItemID
                                                label:@"Stop"
                                          paleteLabel:@"Stop"
                                              toolTip:@"Stop the loading"
                                               target:webView
                                          itemContent:[NSImage imageNamed:@"stop.png"]
                                               action:@selector(stopLoading:)
                                                 menu:nil];
    }
    else if ([itemIdentifier isEqualToString:kAddressToolbarItemID])
    {
        NSRect editorRect = NSRectFromCGRect(CGRectMake(4*kToolBarICONWidth,5,200,kToolBarICONWidth));
        NSTextField * addressEditor = [[NSTextField alloc] initWithFrame:editorRect];
        [addressEditor setBezelStyle:NSTextFieldRoundedBezel];
        [addressEditor setDelegate:self];
        [addressEditor setTarget:self];
        
        toolbarItem = [self toolbarItemWithIdentifier:kAddressToolbarItemID
                                                label:@""
                                          paleteLabel:@""
                                              toolTip:@"Enter the URL."
                                               target:self
                                          itemContent: addressEditor
                                               action:nil
                                                 menu:nil];
    }
    else if ([itemIdentifier isEqualToString:kGoToolbaritemID])
    {
        toolbarItem = [self toolbarItemWithIdentifier:kGoToolbaritemID
                                                label:@"Go"
                                          paleteLabel:@"Go"
                                              toolTip:@"Go"
                                               target:webView
                                          itemContent:[NSImage imageNamed:@"go.png"]
                                               action:@selector(openNewURL:)
                                                 menu:nil];
    }
    else if ([itemIdentifier isEqualToString:kProgressToolbaritemID])
    {
        NSRect rect = NSRectFromCGRect(CGRectMake(0,0,24,24));
        NSProgressIndicator * progressBar = [[NSProgressIndicator alloc] initWithFrame:rect];
        [progressBar setStyle:NSProgressIndicatorSpinningStyle];
        [progressBar startAnimation:nil];
        
        toolbarItem = [self toolbarItemWithIdentifier:kProgressToolbaritemID
                                                label:@"Progress"
                                          paleteLabel:@"Progress"
                                              toolTip:@"Progress"
                                               target:webView
                                          itemContent:progressBar
                                               action:nil
                                                 menu:nil];
        [progressBar release];
    }
    
    return toolbarItem;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:  kBackToolbarItemID,
            kForwardToolbarItemID,
            kRefreshToolbarItemID,
            kStopToolbarItemID,
            kAddressToolbarItemID,
            kGoToolbaritemID,
            kProgressToolbaritemID,
            nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:  kBackToolbarItemID,
            kForwardToolbarItemID,
            kRefreshToolbarItemID,
            kStopToolbarItemID,
            kAddressToolbarItemID,
            kGoToolbaritemID,
            kProgressToolbaritemID,
            nil];
}

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
    
    if(menu)
    {
        [self assignMenuToToolbarItem:item withMenu:menu];
    }
    
    if ([identifier isEqual: kAddressToolbarItemID])
    {
        [item setMinSize: NSSizeFromString(@"{width=100; height=32}")];
        [item setMaxSize: NSSizeFromString(@"{width=800; height=32}")];
        [item setTarget:self];
    }
    return item;
}

#pragma mark - Toolbar menu management
-(void)addBackPageItem:(NSString *)url withTitle:(NSString *)title
{
    if(nil==backMenu)
    {
        backMenu = [[[NSMenu alloc] init] autorelease];
        [self assignMenuToToolbarItemWithIdentifier:kBackToolbarItemID withMenu:backMenu];
    }
    
    NSMenuItem * item = [[[NSMenuItem alloc] initWithTitle:title action:@selector(chooseHistoryItem:) keyEquivalent:@""] autorelease];
    [item setToolTip:url];
    [backMenu insertItem:item atIndex:0];
}

-(void)assignMenuToToolbarItemWithIdentifier:(NSString *)identifier withMenu:(NSMenu *)menu
{
    NSToolbarItem * item = [self getToolbarItemWithIdentifier:identifier];
    if(item)
    {
        [self assignMenuToToolbarItem:item withMenu:menu];
    }
}

-(void)assignMenuToToolbarItem:(NSToolbarItem *)item withMenu:(NSMenu *)menu
{
    if ( nil==menu || nil==item)
        return;
    
    [[item view] setMenu:menu];
}

-(NSToolbarItem *) getToolbarItemWithIdentifier:(NSString *)identifier
{
    NSToolbarItem * result = nil;
    for(NSToolbarItem * item in [[[self window] toolbar] items])
    {
        if([[item itemIdentifier] isEqualToString:identifier])
        {
            result = item;
            break;
        }
    }
    return result;
}

@end
