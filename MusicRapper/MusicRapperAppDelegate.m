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
  }
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
