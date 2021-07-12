//
//  ReadMeService.m
//  ReadMeService
//
//  Created by David Phillip Oster on 2/13/2021.
//  Copyright 2021 David Phillip Oster. Apache License.
//

#import "ReadMeService.h"

static NSString *MakeSuffix(NSString *dirName){
  NSArray<NSString *> *rawParts = [dirName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSMutableArray<NSString *> *parts = [NSMutableArray array];
  NSUInteger totalCount = 0;
  for (NSString *part in rawParts) {
    if ( ! [part isEqual:@"-"] && totalCount + part.length < 50) {
      [parts addObject:part];
      totalCount += part.length + 1;
    }
  }
  return [parts componentsJoinedByString:@" "];
}

static NSString *FileName(NSString *dirName){
  NSString *suffix = MakeSuffix(dirName);
  if ([suffix length]) {
    return [NSString stringWithFormat:@"Read Me - %@.rtf", suffix];
  } else {
    return @"Read Me.rtf";
  }
}

// Initial contents is RTF with and single line saying it's a read me, and where.
static NSData *ConstructOutData(NSURL *dirURL) {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
  [formatter setDateFormat:@"M/dd/yyyy"];
  NSString *dateString = [formatter stringFromDate:[NSDate date]];
  NSString *outString = [NSString stringWithFormat:@"%@ Read Me - %@\n", dateString, dirURL.lastPathComponent];
  NSAttributedString *outAttrString = [[NSAttributedString alloc] initWithString:outString];
  NSRange allRange = NSMakeRange(0, outAttrString.length);
  return [outAttrString RTFFromRange:allRange documentAttributes:@{}];
}

// is the prefix array of words a prefix of the name array of words
static BOOL IsPrefix(NSArray<NSString *> *prefix, NSArray<NSString *> *name){
  NSUInteger count = [prefix count];
  if (count <= [name count]) {
    for (NSUInteger i = 0; i < count; ++i) {
      if (NSOrderedSame != [prefix[i] caseInsensitiveCompare:name[i]]) {
        return NO;
      }
    }
    return YES;
  }
  return NO;
}

static BOOL HasReadMePrefix(NSArray<NSString *> *name){
  NSArray< NSArray<NSString *> *> *candidatePrefixes = @[
    @[@"Readme"],
    @[@"Read", @"Me"],
  ];
  for (NSArray<NSString *> *prefix in candidatePrefixes) {
    if(IsPrefix(prefix, name)) {
      return YES;
    }
  }
  return NO;
}

static BOOL MatchesName(NSString *_Nonnull filename){
  static NSCharacterSet *separatorSet = nil;
  if (nil == separatorSet) {
    separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" \t\n-_."];
  }
  NSArray<NSString *> *candidateSuffixes = @[
    @"md",
    @"rtf",
    @"rtfd",
    @"txt",
    @"",
  ];
  NSString *ext = [[filename pathExtension] lowercaseString];
  if (ext && [candidateSuffixes containsObject:ext]) {
    return HasReadMePrefix([filename componentsSeparatedByCharactersInSet:separatorSet]);
  }
  return NO;
}

// Try a bunch of candidate names looking for a pre-existing read me else nil.
static NSURL *PreviousReadMe(NSURL *_Nonnull dirURL) {
  NSFileManager *fm = NSFileManager.defaultManager;
  NSArray<NSString *> *contents = [fm contentsOfDirectoryAtPath:dirURL.path error:NULL];
  for (NSString *fileName in contents) {
    if (MatchesName(fileName)) {
      return [dirURL URLByAppendingPathComponent:fileName];
    }
  }
  return nil;
}

static BOOL HasForbiddenSuffix(NSURL *_Nonnull dirURL){
  NSString *ext = [[dirURL pathExtension] lowercaseString];
  NSArray<NSString *> *candidateSuffixes = @[
    @"app",
    @"xcodeproj",
  ];
  return [candidateSuffixes containsObject:ext];
}

// Given a directory URL, if it has a pre-existing ReadMe, open it. Else create and open it.
void OpenOrCreateReadMe(NSURL *_Nonnull dirURL) {
  if (HasForbiddenSuffix(dirURL)) {
    // Sysbeep?
    return;
  }
  NSURL *url = PreviousReadMe(dirURL);
  if (url) {
    NSWorkspace *ws = NSWorkspace.sharedWorkspace;
    [ws openURL:url];
  } else {
    NSString *fileName = FileName(dirURL.lastPathComponent);
    url = [dirURL URLByAppendingPathComponent:fileName];
    if (url) {
      NSData *outData = ConstructOutData(dirURL);
      if ([outData writeToURL:url atomically:YES]) {
        NSWorkspace *ws = NSWorkspace.sharedWorkspace;
        [ws openURL:url];
      }
    }
  }
}

@implementation ReadMeService

- (void)doReadMeService:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error {
  NSArray<NSURL *> *urls = [pboard readObjectsForClasses:@[ [NSURL class] ] options:nil];
  for (NSURL *dirURL in urls) {
    OpenOrCreateReadMe(dirURL);
  }
}

@end
