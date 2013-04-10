//
//  MiniBrowserNavigatorButton.m
//  MiniBrowser
//
//  Created by Horky Chen on 4/10/13.
//  Copyright (c) 2013 Horky Chen. All rights reserved.
//  Reference:http://cocoadev.com/wiki/SafariInterface
//

#import "MiniBrowserNavigatorButton.h"
@interface MiniBrowserNavigatorButton ()
{
    NSTimer * timer;
}
@end

@implementation MiniBrowserNavigatorButton

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setButtonType:NSMomentaryChangeButton];
        [self setBezelStyle:NSRegularSquareBezelStyle];
        [self setBordered:NO];
        [self setShowsBorderOnlyWhileMouseInside:YES];
        [self setImagePosition:NSImageOnly];
    }
    
    return self;
}

- (void)displayMenu:(NSTimer *)theTimer
{
    NSEvent * theEvent=[timer userInfo];
    CGPoint location = [self frame].origin;
    location.y+=[self frame].size.height;
    location = [self convertPoint:location toView:[[self window] contentView]];
    NSEvent * click = [NSEvent mouseEventWithType:[theEvent type] location:location
                                        modifierFlags:[theEvent modifierFlags]
                                        timestamp:[theEvent timestamp]
                                        windowNumber:[theEvent windowNumber]
                                          context:[theEvent context]
                                      eventNumber:[theEvent eventNumber]
                                       clickCount:[theEvent clickCount]
                                         pressure:[theEvent pressure]];
    
    [NSMenu popUpContextMenu:[self menu] withEvent:click forView:self];
    [timer invalidate];
    [self highlight:NO];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [self highlight:YES];
    
    if(nil!=self.menu)
    {
        timer=[NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(displayMenu:) userInfo:theEvent repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:@"NSDefaultRunLoopMode"];
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [self highlight:NO];
    if(nil==timer)
    {
        [self performClick:self];
    }
    else
    {
        [timer invalidate];
    }
}

@end
