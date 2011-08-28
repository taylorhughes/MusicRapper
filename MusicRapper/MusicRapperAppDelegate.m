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
@synthesize timer;

static NSString *PREF_WINDOW_FRAME_FULL = @"windowFrameFull";
static NSString *PREF_WINDOW_FRAME_MINI = @"windowFrameMini";

static CGFloat MINI_HEIGHT = 55.0 + 22.0;
static CGFloat MINI_WIDTH = 440.0;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  NSString *urlText = @"http://music.google.com/";
  [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlText]]];

  mini = NO;
  hasLoadedMini = NO;
  
  // Remember initial large size.
  if (![window setFrameUsingName:PREF_WINDOW_FRAME_FULL]) {
    // If this preference hasn't been saved yet, save it now.
    [window saveFrameUsingName:PREF_WINDOW_FRAME_FULL];
  }

  lastAdvanced = 0;
  self.timer = [NSTimer scheduledTimerWithTimeInterval:0.4
                                                target:self
                                              selector:@selector(maybeAdvance:)
                                              userInfo:nil
                                               repeats:YES];
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

- (void) maybeAdvance:(id)sender {
  NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
  if (now - lastAdvanced < 4.0) {
    // Don't attempt to hit "Next" a bunch of times in a row.
    return;
  }

  //
  // WARNING: This is pretty crazy. This fixes a bug where the
  // player keeps playing past the end of the song instead of
  // advancing to the next track.
  //
  NSString *javascript = @"(function(){"
    "var convertToSeconds = function(el) {"
      "var time = (el && el.innerHTML) || '';"
      ""
      "var pieces = [];"
      "var rawPieces = time.split(':');"
      "for (var i = 0; i < rawPieces.length; i++) {"
        "var str = rawPieces[i].replace(/\\D+/, '');"
        "if (str != '') {"
          "pieces.push(parseInt(str, 10));"
        "}"
      "}"
      "if (!pieces.length) { return 0; }"
      ""
      "var total = 0;"
      "for (var i = 0; i < pieces.length; i++) {"
        "if (i > 0) { total *= 60; }"
        "total += pieces[i];"
      "}"
      "return total;"
    "};"
    "var currentTime = convertToSeconds(document.getElementById('currentTime'));"
    "var duration = convertToSeconds(document.getElementById('duration'));"
    "return (currentTime && duration && currentTime > duration);"
  "})()";
  NSObject *result = [[webView windowScriptObject] evaluateWebScript:javascript];

  if ([result isEqualTo:[NSNumber numberWithInt:1]]) {
    NSLog(@"Advanced to the next track using magic.");
    [self nextSong:sender];
    lastAdvanced = now;
  }
}

- (void) setMini:(BOOL)shouldBeMini {
  mini = shouldBeMini;
  
  if (mini) {
    [[window contentView] setAutoresizesSubviews:NO];
    [window setShowsResizeIndicator:NO];

    // Hasn't been loaded yet. Attempt to laod from preference.
    BOOL loadedFromPref = [window setFrameUsingName:PREF_WINDOW_FRAME_MINI];

    if (!hasLoadedMini) {
      hasLoadedMini = YES;

      NSRect miniRect = [window frame];
      // Always set the height and width in case this ever changes.
      miniRect.size.height = MINI_HEIGHT;
      miniRect.size.width = MINI_WIDTH;
      [window setFrame:miniRect display:YES];

      if (!loadedFromPref) {
        [window saveFrameUsingName:PREF_WINDOW_FRAME_MINI];
      }
    }
  } else {
    [window setFrameUsingName:PREF_WINDOW_FRAME_FULL];

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
    [window saveFrameUsingName:PREF_WINDOW_FRAME_FULL];
  }
}

- (void) windowDidMove:(NSNotification *)notification {
  if (!mini) {
    [window saveFrameUsingName:PREF_WINDOW_FRAME_FULL];
  } else {
    [window saveFrameUsingName:PREF_WINDOW_FRAME_MINI];
  }
}

@end
