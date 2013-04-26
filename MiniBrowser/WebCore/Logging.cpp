
#include <stdio.h>
#include "Logging.h"

WTFLogChannel LogNotYetImplemented = { 0x00000001, "WebCoreLogLevel", WTFLogChannelOff };

WTFLogChannel LogFrames =            { 0x00000010, "WebCoreLogLevel", WTFLogChannelOff };
WTFLogChannel LogLoading =           { 0x00000020, "WebCoreLogLevel", WTFLogChannelOff};
WTFLogChannel LogPopupBlocking =     { 0x00000040, "WebCoreLogLevel", WTFLogChannelOff };
WTFLogChannel LogEvents =            { 0x00000080, "WebCoreLogLevel", WTFLogChannelOff };

WTFLogChannel LogEditing =           { 0x00000100, "WebCoreLogLevel", WTFLogChannelOff };
WTFLogChannel LogLiveConnect =       { 0x00000200, "WebCoreLogLevel", WTFLogChannelOff };
WTFLogChannel LogIconDatabase =      { 0x00000400, "WebCoreLogLevel", WTFLogChannelOff };
WTFLogChannel LogSQLDatabase =       { 0x00000800, "WebCoreLogLevel", WTFLogChannelOff };

WTFLogChannel LogSpellingAndGrammar ={ 0x00001000, "WebCoreLogLevel", WTFLogChannelOff };
WTFLogChannel LogBackForward =       { 0x00002000, "WebCoreLogLevel", WTFLogChannelOff };
WTFLogChannel LogHistory =           { 0x00004000, "WebCoreLogLevel", WTFLogChannelOn };
WTFLogChannel LogPageCache =         { 0x00008000, "WebCoreLogLevel", WTFLogChannelOff };

WTFLogChannel LogPlatformLeaks =     { 0x00010000, "WebCoreLogLevel", WTFLogChannelOff };
WTFLogChannel LogResourceLoading =   { 0x00020000, "WebCoreLogLevel", WTFLogChannelOff };

WTFLogChannel LogNetwork =           { 0x00100000, "WebCoreLogLevel", WTFLogChannelOff };
WTFLogChannel LogFTP =               { 0x00200000, "WebCoreLogLevel", WTFLogChannelOff };
WTFLogChannel LogThreading =         { 0x00400000, "WebCoreLogLevel", WTFLogChannelOff };
WTFLogChannel LogStorageAPI =        { 0x00800000, "WebCoreLogLevel", WTFLogChannelOff };

WTFLogChannel LogMedia =             { 0x01000000, "WebCoreLogLevel", WTFLogChannelOff };
WTFLogChannel LogPlugins =           { 0x02000000, "WebCoreLogLevel", WTFLogChannelOff };
WTFLogChannel LogArchives =          { 0x04000000, "WebCoreLogLevel", WTFLogChannelOff };
WTFLogChannel LogProgress =          { 0x08000000, "WebCoreLogLevel", WTFLogChannelOff };

WTFLogChannel LogFileAPI =           { 0x10000000, "WebCoreLogLevel", WTFLogChannelOff };

WTFLogChannel LogWebAudio =          { 0x20000000, "WebCoreLogLevel", WTFLogChannelOff };

#ifdef __cplusplus
extern "C" {
#endif
    
void initializeWithUserDefault(WTFLogChannel channel)
{
    NSString *logLevelString = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithUTF8String:channel.defaultName]];
    if (logLevelString) {
        unsigned logLevel;
        if (![[NSScanner scannerWithString:logLevelString] scanHexInt:&logLevel])
            NSLog(@"unable to parse hex value for %s (%@), logging is off", channel.defaultName, logLevelString);
        if ((logLevel & channel.mask) == channel.mask)
            channel.state = WTFLogChannelOn;
        else
            channel.state = WTFLogChannelOff;
    }
}

void setLogLevelToDefaults(WTFLogChannel channel, WTFLogChannelState level)
{
    [[NSUserDefaults standardUserDefaults] setInteger:level forKey:[NSString stringWithUTF8String:channel.defaultName]];
}
    
#ifdef __cplusplus
} //end of extern
#endif