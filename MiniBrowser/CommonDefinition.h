//
//  CommonDefinition.h
//  MiniBrowser
//
//  Created by Horky Chen on 4/8/13.
//  Copyright (c) 2013 Horky Chen. All rights reserved.
//

#ifndef MiniBrowser_CommonDefinition_h
#define MiniBrowser_CommonDefinition_h

#import "ASLogger.h"

typedef enum{
    PAGE_ERROR,
} INTERNAL_PAGE_INDEX;

typedef enum{
    USER_AGENT_UCBROWSER_IPAD,
    USER_AGENT_SAFARI_IPAD,
    USER_AGENT_SAFARI_MACOS
} USER_AGENT_LIST;

#define kBackToolbarItemID  @"Back"
#define kForwardToolbarItemID  @"Forward"
#define kRefreshToolbarItemID   @"Refresh"
#define kStopToolbarItemID   @"Stop"
#define kAddressToolbarItemID   @"Address"
#define kGoToolbaritemID   @"Go"
#define kProgressToolbaritemID   @"Progress"

#define kDefaultWebPage   @"http://www.baidu.com"

#define UserAgent_UCBrowserIpad @"Mozilla/5.0(iPad; U;CPU OS 6 like Mac OS X; zh-CN; x86_64) AppleWebKit/534.46 (KHTML, like Gecko) UCBrowser/2.0.0.164 U3/0.8.0 Safari/7543.48.3"
#define UserAgent_SafariIpad @"Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A403 Safari/8536.25"
#define UserAgent_SafariMacOS @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/536.28.10 (KHTML, like Gecko) Version/6.0.3 Safari/536.28.10"
#endif
