//
//  MusicRapperAppDelegate.m
//  MusicRapper
//
//  Created by Taylor Hughes on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MusicRapperAppDelegate.h"

@implementation MusicRapperAppDelegate

@synthesize window;
@synthesize webView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  NSString *urlText = @"http://music.google.com/";
  [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlText]]];

  mini = NO;
  
  // Remember initial large size.
  fullRect = [window frame];
  miniRect = [window frame];

  CGFloat NEW_HEIGHT = 55.0 + 22.0;
  CGFloat NEW_WIDTH = 440.0;
  miniRect.origin.y = miniRect.origin.y + miniRect.size.height - NEW_HEIGHT;
  miniRect.size.height = NEW_HEIGHT;
  miniRect.size.width = NEW_WIDTH;
}

- (void) playPause:(id)sender {
  [[webView windowScriptObject] evaluateWebScript:@"SJBpost('playPause');"];
}

- (void) nextSong:(id)sender {
  [[webView windowScriptObject] evaluateWebScript:@"SJBpost('nextSong');"];
}

- (void) previousSong:(id)sender {
  [[webView windowScriptObject] evaluateWebScript:@"SJBpost('prevSong');"];  
}

- (void) setMini:(BOOL)shouldBeMini {
  mini = shouldBeMini;
  
  if (mini) {
    [[window contentView] setAutoresizesSubviews:NO];
    [window setShowsResizeIndicator:NO];

    [window setFrame:miniRect display:YES];
  } else {
    [window setFrame:fullRect display:YES];

    [[window contentView] setAutoresizesSubviews:YES];
    [window setShowsResizeIndicator:YES];
  }
}

- (IBAction) toggleMiniPlayer:(id)sender {
  [self setMini:!mini];
}

- (BOOL) windowShouldZoom:(NSWindow*)window toFrame:(NSRect)frame {
  [self toggleMiniPlayer:self];
  return NO;
}

- (void) windowDidResize:(NSNotification *)notification {
  if (!mini) {
    fullRect = [window frame];
  }
}

- (void) windowDidMove:(NSNotification *)notification {
  if (!mini) {
    fullRect = [window frame];
  } else {
    miniRect = [window frame];
  }
}

@end
