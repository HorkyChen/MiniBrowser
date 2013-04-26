
#ifndef Logging_h
#define Logging_h

typedef enum { WTFLogChannelOff, WTFLogChannelOn } WTFLogChannelState;

typedef struct {
    unsigned mask;
    const char *defaultName;
    WTFLogChannelState state;
} WTFLogChannel;


extern WTFLogChannel LogNotYetImplemented;
extern WTFLogChannel LogFrames;
extern WTFLogChannel LogLoading;
extern WTFLogChannel LogPopupBlocking;
extern WTFLogChannel LogEvents;
extern WTFLogChannel LogEditing;
extern WTFLogChannel LogLiveConnect;
extern WTFLogChannel LogIconDatabase;
extern WTFLogChannel LogSQLDatabase;
extern WTFLogChannel LogSpellingAndGrammar;
extern WTFLogChannel LogBackForward;
extern WTFLogChannel LogHistory;
extern WTFLogChannel LogPageCache;
extern WTFLogChannel LogPlatformLeaks;
extern WTFLogChannel LogResourceLoading;
extern WTFLogChannel LogNetwork;
extern WTFLogChannel LogFTP;
extern WTFLogChannel LogThreading;
extern WTFLogChannel LogStorageAPI;
extern WTFLogChannel LogMedia;
extern WTFLogChannel LogPlugins;
extern WTFLogChannel LogArchives;
extern WTFLogChannel LogProgress;
extern WTFLogChannel LogFileAPI;
extern WTFLogChannel LogWebAudio;

#ifdef __cplusplus
extern "C" {
#endif
    void initializeWithUserDefault(WTFLogChannel channel);
    void setLogLevelToDefaults(WTFLogChannel channel, WTFLogChannelState level);
#ifdef __cplusplus
}
#endif
#endif // Logging_h
