//
//  LINCallingViewController.m
//  linner
//
//  Created by Lincan Li on 9/14/14.
//  Copyright (c) 2014 ___Lincan Li___. All rights reserved.
//

#import "LINCallingViewController.h"

@interface LINCallingViewController ()

@end

@implementation LINCallingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.call.delegate = self;
    
    if ([self.call direction] == SINCallDirectionIncoming) {
        [self setCallStatusText:@""];
        [[self audioController] startPlayingSoundFile:[self pathForSound:@"incoming.wav"] loop:YES];
    } else {
        [self setCallStatusText:@"Calling"];
    }
    
}

-(void)viewDidLayoutSubviews
{
    self.profilePictureView.layer.cornerRadius = self.profilePictureView.frame.size.width/2;
    self.profilePictureView.layer.masksToBounds = YES;
    
    self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width/2;
    self.profilePicture.layer.masksToBounds = YES;
    
    self.speaker.layer.cornerRadius = self.speaker.frame.size.width/2;
    self.speaker.layer.masksToBounds = YES/2;
    
    self.record.layer.cornerRadius = self.record.frame.size.width/2;
    self.profilePicture.layer.masksToBounds = YES;
    
    self.mute.layer.cornerRadius = self.mute.frame.size.width/2;
    self.mute.layer.masksToBounds = YES;
    
    self.finish.layer.cornerRadius = self.finish.frame.size.width/2;
    self.finish.layer.masksToBounds = YES;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (id<SINAudioController>)audioController {
    return [[(LINAppDelegate *)[[UIApplication sharedApplication] delegate] client] audioController];
}

- (IBAction)hangupButtonDidTouched:(id)sender {
    [self.call hangup];
    [self dismiss];
}
- (IBAction)answerButtonDidTouched:(id)sender {
    [[self audioController] stopPlayingSoundFile];
    [self.call answer];
}

- (IBAction)declineButtonDidTouched:(id)sender {
    [self.call hangup];
    [self dismiss];
}

- (void)onDurationTimer:(NSTimer *)unused {
    NSLog(@"onDurationTimer: %@", unused);

    NSInteger duration = [[NSDate date] timeIntervalSinceDate:[[self.call details] establishedTime]];
    NSLog(@"timer : %ld", (long)duration);
    self.duration.text = [NSString stringWithFormat:@"%d", duration];
}


- (void)callDidProgress:(id<SINCall>)call {
    NSLog(@"callDidProgress");
    self.duration.text = @"ringing...";
    [[self audioController] startPlayingSoundFile:[self pathForSound:@"ringback.wav"] loop:YES];
}

- (void)callDidEstablish:(id<SINCall>)call {
    NSLog(@"callDidEstablish");
    [self startCallDurationTimerWithSelector:@selector(onDurationTimer:)];
    [[self audioController] stopPlayingSoundFile];
}

- (void)callDidEnd:(id<SINCall>)call {
    NSLog(@"callDidEnd");
    [self dismiss];
    [[self audioController] stopPlayingSoundFile];
    [self stopCallDurationTimer];
}

- (NSString *)pathForSound:(NSString *)soundName {
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:soundName];
}


- (void)setCallStatusText:(NSString *)text {
    NSLog(@"status : %@", text);
    self.duration.text = text;
}

-(void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)setTheDuration:(NSInteger)seconds {
    self.duration.text = [NSString stringWithFormat:@"%02d:%02d", (int)(seconds / 60), (int)(seconds % 60)];
}

- (void)internal_updateDuration:(NSTimer *)timer {
    SEL selector = NSSelectorFromString([timer userInfo]);
    if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:selector withObject:timer];
#pragma clang diagnostic pop
    }
}

- (void)startCallDurationTimerWithSelector:(SEL)sel {
    NSString *selectorAsString = NSStringFromSelector(sel);
    self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                          target:self
                                                        selector:@selector(internal_updateDuration:)
                                                        userInfo:selectorAsString
                                                         repeats:YES];
}

- (void)stopCallDurationTimer {
    [self.durationTimer invalidate];
    self.durationTimer = nil;
}


@end
