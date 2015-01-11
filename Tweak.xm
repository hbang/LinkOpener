#import <AlienBlue/NavigationManager.h>

@interface NSData (JSONKit)

- (NSDictionary *)objectFromJSONData;

@end

#pragma mark - Facebook

%group Facebook
%hook AppDelegate

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApp annotation:(id)annotation {
	if ([url.host isEqualToString:@"profileForLinkOpener"] && url.pathComponents.count == 2) {
		// This is a terrible way to do this. Don't ever do this.
		// TODO: un-stupid this

		NSData *output = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[@"https://graph.facebook.com/" stringByAppendingString:[url.pathComponents objectAtIndex:1]]] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:60] returningResponse:nil error:nil];

		if (output == nil) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops, something went wrong." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];

			return NO;
		}

		NSDictionary *json = output.objectFromJSONData;

		if (json && [json objectForKey:@"id"]) {
			return %orig(application, [NSURL URLWithString:[@"fb://profile/" stringByAppendingString:[json objectForKey:@"id"]]], sourceApp, annotation);
		}

		return NO;
	} else {
		return %orig;
	}
}

%end
%end

#pragma mark - Alien Blue

BOOL isOpeningURL = NO;
NSString *urlToOpen;

%group AlienBlueOld
%hook AlienBlueAppDelegate

- (void)checkClipboardForRedditLink { // < 2.9
	isOpeningURL = YES;
	%orig;
	isOpeningURL = NO;
}

%end
%end

%group AlienBlueNew
%hook AppSchemeCoordinator

+ (void)checkClipboardForRedditLink { // >= 2.9
	isOpeningURL = YES;
	%orig;
	isOpeningURL = NO;
}

%end
%end

%group AlienBlue
%hook AlienBlueAppDelegate

- (void)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	if ([url.host isEqualToString:@"_linkopener_url"]) {
		urlToOpen = [url.query copy];
	} else {
		%orig;
	}
}

%end

%hook UIPasteboard

- (NSString *)string {
	return isOpeningURL && self == [UIPasteboard generalPasteboard] ? urlToOpen : %orig;
}

%end

%hook NSUserDefaults

- (id)objectForKey:(NSString *)key {
	return [key isEqualToString:@"clipboard_posts"] && isOpeningURL ? @[] : %orig;
}

%end

%hook Post

- (BOOL)isInVisitedList {
	return isOpeningURL ? NO : %orig;
}

%end
%end

#pragma mark - Constructor

%ctor {
	%init;

	if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.facebook.Facebook"]) {
		%init(Facebook);
	} else if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.designshed.alienblue"] || [[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.reddit.alienblue"]) {
		%init(AlienBlue);

		if (%c(AppSchemeCoordinator)) {
			%init(AlienBlueNew);
		} else {
			%init(AlienBlueOld);
		}
	}
}
