//
//  MusicRapperApplication.m
//  MusicRapper
//
//  Created by Taylor Hughes on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MusicRapperApplication.h"
#import "MusicRapperAppDelegate.h"
#import <IOKit/hidsystem/ev_keymap.h>


@implementation MusicRapperApplication


//
// Many thanks to: http://rogueamoeba.com/utm/2007/09/29/
//

- (void)mediaKeyEvent:(int)key state:(BOOL)state
{
  switch (key)
  {
    case NX_KEYTYPE_PLAY:
      if (state == NO) {
        [(MusicRapperAppDelegate *)[self delegate] playPause:self];
      }
      break;
      
    case NX_KEYTYPE_FAST:
      if (state == YES) {
        [(MusicRapperAppDelegate *)[self delegate] nextSong:self];
      }
      break;
      
    case NX_KEYTYPE_REWIND:
      if (state == YES) {
        [(MusicRapperAppDelegate *)[self delegate] previousSong:self];
      }
      break;
  }
}

- (void)sendEvent:(NSEvent *)event
{
  // Catch media key events
  if ([event type] == NSSystemDefined && [event subtype] == 8)
  {
    int keyCode = (([event data1] & 0xFFFF0000) >> 16);
    int keyFlags = ([event data1] & 0x0000FFFF);
    int keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA;
    
    // Process the media key event and return
    [self mediaKeyEvent:keyCode state:keyState];
    return;
  }
  
  // Continue on to super
  [super sendEvent:event];
}


@end
