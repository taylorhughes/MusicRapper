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
  
  // Remember initial large size.
  [window setFrameUsingName:PREF_WINDOW_FRAME_FULL];
  fullRect = [window frame];

  // Try to load this later.
  miniRect = NSRectFromCGRect(CGRectZero);

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

    if (!miniRect.size.width && !miniRect.size.height) {
      // Hasn't been loaded yet. Attempt to laod from preference.
      [window setFrameUsingName:PREF_WINDOW_FRAME_MINI];

      miniRect = [window frame];
      // Always set the height and width in case this ever changes.
      miniRect.size.height = MINI_HEIGHT;
      miniRect.size.width = MINI_WIDTH;
    }

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
    [window saveFrameUsingName:PREF_WINDOW_FRAME_FULL];
    fullRect = [window frame];
  }
}

- (void) windowDidMove:(NSNotification *)notification {
  if (!mini) {
    [window saveFrameUsingName:PREF_WINDOW_FRAME_FULL];
    fullRect = [window frame];
  } else {
    [window saveFrameUsingName:PREF_WINDOW_FRAME_MINI];
    miniRect = [window frame];
  }
}

@end
