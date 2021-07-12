//
//  main.m
//  ReadMeService
//
//  Created by David Phillip Oster on 2/13/2021.
//  Copyright 2021 David Phillip Oster. Apache License.
//

#import <AppKit/AppKit.h>
#import "ReadMeService.h"

int main(int argc, char *argv[]) {
  @autoreleasepool {
    ReadMeService *service = [[ReadMeService alloc] init];
    NSRegisterServicesProvider(service, @"ReadMeService");
    [[NSRunLoop currentRunLoop] run];
  }
  return 0;
}
