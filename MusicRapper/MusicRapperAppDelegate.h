//
//  MusicRapperAppDelegate.h
//  MusicRapper
//
//  Created by Taylor Hughes on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface MusicRapperAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate> {
@private
  NSWindow *window;
  WebView *webView;

  BOOL mini;
  BOOL hasLoadedMini;
  
  NSTimer *timer;
  NSTimeInterval lastAdvanced;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet WebView *webView;
@property (retain) NSTimer *timer;

- (void) maybeAdvance:(id)sender;
- (void) playPause:(id)sender;
- (void) nextSong:(id)sender;
- (void) previousSong:(id)sender;

- (IBAction) toggleMiniPlayer:(id)sender;

@end
