// EyeBreak.mm - Stable Version
#include <Cocoa/Cocoa.h>
#include <thread>
#include <atomic>

std::atomic<bool> running{true};
std::atomic<bool> breakActive{false};
std::atomic<int> activeSeconds{0};

constexpr int ACTIVE_TIMEOUT_SEC = 20 * 60;
constexpr int IDLE_RESET_SEC     = 3 * 60;
constexpr int BREAK_DURATION_SEC = 20;

@interface BreakOverlay : NSWindow
@property (nonatomic, strong) NSTextField *titleLabel;
@property (nonatomic, strong) NSTextField *timerLabel;
@property (nonatomic, strong) NSButton *skipButton;
@property (nonatomic, assign) int countdown;
@end

@implementation BreakOverlay
- (instancetype)initWithScreen:(NSScreen*)screen {
    self = [super initWithContentRect:screen.frame styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO];
    if (self) {
        self.backgroundColor = [NSColor blackColor];
        self.level = NSScreenSaverWindowLevel + 1;
        self.collectionBehavior = NSWindowCollectionBehaviorCanJoinAllSpaces | NSWindowCollectionBehaviorFullScreenAuxiliary;
        
        self.titleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(0, screen.frame.size.height/2 + 60, screen.frame.size.width, 80)];
        self.titleLabel.stringValue = @"🧘 Time to rest your eyes";
        self.titleLabel.font = [NSFont systemFontOfSize:48 weight:NSFontWeightMedium];
        self.titleLabel.textColor = [NSColor whiteColor];
        self.titleLabel.alignment = NSTextAlignmentCenter;
        self.titleLabel.backgroundColor = nil;
        [[self contentView] addSubview:self.titleLabel];
        
        self.timerLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(0, screen.frame.size.height/2 - 80, screen.frame.size.width, 140)];
        self.timerLabel.font = [NSFont systemFontOfSize:110 weight:NSFontWeightBold];
        self.timerLabel.textColor = [NSColor whiteColor];
        self.timerLabel.alignment = NSTextAlignmentCenter;
        self.timerLabel.backgroundColor = nil;
        [[self contentView] addSubview:self.timerLabel];
        
        self.skipButton = [[NSButton alloc] initWithFrame:NSMakeRect(screen.frame.size.width/2 - 90, 80, 180, 50)];
        self.skipButton.title = @"Skip Break (ESC)";
        self.skipButton.bezelStyle = NSBezelStyleRounded;
        [self.skipButton setTarget:self];
        [self.skipButton setAction:@selector(skipTapped:)];
        [[self contentView] addSubview:self.skipButton];
        
        self.countdown = BREAK_DURATION_SEC;
        self.timerLabel.stringValue = @"20";
        
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
        [self becomeFirstResponder];
    }
    return self;
}

- (BOOL)acceptsFirstResponder { return YES; }
- (void)keyDown:(NSEvent *)event {
    if (event.keyCode == 53) { [self close]; breakActive = false; }
}
- (void)updateTimer:(NSTimer*)t {
    self.countdown--;
    self.timerLabel.stringValue = [NSString stringWithFormat:@"%d", self.countdown];
    if (self.countdown <= 0) [self close];
}
- (void)skipTapped:(id)sender {
    [self close];
    breakActive = false;
}
@end

double GetIdleSeconds() {
    return CGEventSourceSecondsSinceLastEventType(kCGEventSourceStateCombinedSessionState, kCGAnyInputEventType);
}

void ShowBreak() {
    if (breakActive) return;
    breakActive = true;
    for (NSScreen *s in [NSScreen screens]) {
        BreakOverlay *w = [[BreakOverlay alloc] initWithScreen:s];
        [w makeKeyAndOrderFront:nil];
    }
}

void TimerLoop() {
    while (running) {
        if (GetIdleSeconds() > IDLE_RESET_SEC) activeSeconds = 0;
        else if (!breakActive) {
            activeSeconds++;
            if (activeSeconds >= ACTIVE_TIMEOUT_SEC) {
                activeSeconds = 0;
                dispatch_async(dispatch_get_main_queue(), ^{ ShowBreak(); });
            }
        }
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }
}

int main() {
    @autoreleasepool {
        [NSApplication sharedApplication];
        NSStatusItem *item = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        item.button.title = @"👁️";
        
        NSMenu *menu = [[NSMenu alloc] init];
        [menu addItemWithTitle:@"Test Break Now" action:@selector(testBreak) keyEquivalent:@"t"];
        [menu addItemWithTitle:@"Exit" action:@selector(terminate:) keyEquivalent:@"q"];
        item.menu = menu;
        
        std::thread t(TimerLoop);
        t.detach();
        
        [NSApp run];
    }
    return 0;
}
