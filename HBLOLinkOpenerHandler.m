/**
 * Edited by bensge for IMDb support.
 * Netbot support by Aehmlo - Riposte requires to query ADN's API for user ID.
 * If you want to implement this, go ahead, but I don't use it enough to.
 * Twitter status support, Twitterrific support, and Cydia support by Aehmlo.
 */

#import "HBLOLinkOpenerHandler.h"
#import <UIKit/NSString+UIKitAdditions.h>
#import <Cephei/HBPreferences.h>

@implementation HBLOLinkOpenerHandler {
	HBPreferences *_preferences;
}

- (instancetype)init {
	self = [super init];

	if (self) {
		self.name = @"LinkOpener";
		self.identifier = @"LinkOpener";
		self.preferencesBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/LinkOpenerPrefs.bundle"];
		self.preferencesClass = @"HBLOLinkOpenerListController";

		_preferences = [HBPreferences preferencesForIdentifier:@"org.thebigboss.linkopener"];
	}

	return self;
}

- (id)openURL:(NSURL *)url sender:(NSString *)sender {
	// do nothing if we aren’t enabled
	if (![_preferences boolForKey:@"Enabled" default:YES]) {
		return nil;
	}

	// special case for file:// urls: launch ifile or filza
	if ([url.scheme isEqualToString:@"file"]) {
		if (![_preferences boolForKey:@"File" default:YES]) {
			return nil;
		}

		return @[
			[NSURL URLWithString:[@"ifile://%@" stringByAppendingString:url.path]],
			[NSURL URLWithString:[@"filza:/%@" stringByAppendingString:url.path]]
		];
	}

	// from here on, we assume http or https
	if (![url.scheme isEqualToString:@"http"] && ![url.scheme isEqualToString:@"https"]) {
		return nil;
	}

	if ([url.host isEqualToString:@"twitter.com"] || [url.host isEqualToString:@"mobile.twitter.com"] || [url.host isEqualToString:@"m.twitter.com"]) {
		static NSArray *NonUsernamePaths;
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			// this interesting huge array of random words is the array of non-username paths provided by
			// the twitter API. we *should* be getting the latest from the API but that seems like a lot
			// of complexity for something that probably shouldn’t be changing that much
			// fun fact: there used to be accounts with usernames in this list! @search was one that seems
			// to have only recently been removed (as of 2017-04-14)
			// last updated: 2017-04-14
			NonUsernamePaths = @[
				@"about", @"account", @"accounts", @"activity", @"all", @"announcements", @"anywhere",
				@"api_rules", @"api_terms", @"apirules", @"apps", @"auth", @"badges", @"blog", @"business",
				@"buttons", @"contacts", @"devices", @"direct_messages", @"download", @"downloads",
				@"edit_announcements", @"faq", @"favorites", @"find_sources", @"find_users", @"followers",
				@"following", @"friend_request", @"friendrequest", @"friends", @"goodies", @"help", @"home",
				@"i", @"im_account", @"inbox", @"invitations", @"invite", @"jobs", @"list", @"login", @"logo",
				@"logout", @"me", @"mentions", @"messages", @"mockview", @"newtwitter", @"notifications",
				@"nudge", @"oauth", @"phoenix_search", @"positions", @"privacy", @"public_timeline",
				@"related_tweets", @"replies", @"retweeted_of_mine", @"retweets", @"retweets_by_others",
				@"rules", @"saved_searches", @"search", @"sent", @"sessions", @"settings", @"share",
				@"signup", @"signin", @"similar_to", @"statistics", @"terms", @"tos", @"translate", @"trends",
				@"tweetbutton", @"twttr", @"update_discoverability", @"users", @"welcome", @"who_to_follow",
				@"widgets", @"zendesk_auth", @"media_signup"
			];
		});

		if (url.pathComponents.count == 2 && ![NonUsernamePaths containsObject:url.pathComponents[1]]) {
			// https://twitter.com/:username
			if (![_preferences boolForKey:@"TwitterUser" default:YES]) {
				return nil;
			}

			return @[
				[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:url.pathComponents[1]]],
				[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:url.pathComponents[1]]],
				[NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:url.pathComponents[1]]]
			];
		} else if (url.pathComponents.count == 4 && ([url.pathComponents[2] isEqualToString:@"status"] || [url.pathComponents[2] isEqualToString:@"statuses"])) {
			// https://twitter.com/:username/status/:id
			if (![_preferences boolForKey:@"TwitterStatus" default:YES]) {
				return nil;
			}

			return @[
				[NSURL URLWithString:[NSString stringWithFormat:@"tweetbot://%@/status/%@", url.pathComponents[1], url.pathComponents[3]]],
				[NSURL URLWithString:[@"twitterrific:///tweet?id=" stringByAppendingString:url.pathComponents[3]]],
				[NSURL URLWithString:[@"twitter:///status?id=" stringByAppendingString:url.pathComponents[3]]]
			];
		}
	} else if ([url.host isEqualToString:@"www.facebook.com"] || [url.host isEqualToString:@"facebook.com"] || [url.host isEqualToString:@"fb.com"]) {
		// https://www.facebook.com/:username
		// TODO: we don’t check for non-username paths
		if (url.pathComponents.count == 2) {
			if (![_preferences boolForKey:@"FacebookUser" default:YES]) {
				return nil;
			}

			return [NSURL URLWithString:[@"fb://profileForLinkOpener/" stringByAppendingString:url.pathComponents[1]]];
		}
	} else if ([url.host isEqualToString:@"imdb.com"] || [url.host isEqualToString:@"www.imdb.com"]) {
		// http://www.imdb.com/title/:id
		if (url.pathComponents.count == 3) {
			if (![_preferences boolForKey:@"IMDBTitle" default:YES]) {
				return nil;
			}

			return [NSURL URLWithString:[@"imdb:///title/" stringByAppendingString:url.pathComponents[2]]];
		}
	} else if ([url.host hasPrefix:@"ebay.co"] || [url.host hasPrefix:@"www.ebay.co"]) {
		if (url.pathComponents.count == 4) {
			// http://www.ebay.com/itm/:name/:id/
			if (![_preferences boolForKey:@"EBayListing" default:YES]) {
				return nil;
			}

			return [NSURL URLWithString:[@"ebay://launch?itm=" stringByAppendingString:url.pathComponents[3]]];
		} else if (url.pathComponents.count > 3 && [url.pathComponents[1] isEqualToString:@"sch"]) {
			// http://www.ebay.com.au/sch/i.html?_nkw=:query (ew, what decade is this?)
			if (![_preferences boolForKey:@"EBaySearch" default:YES]) {
				return nil;
			}

			return [NSURL URLWithString:[NSString stringWithFormat:@"ebay://%@%@", url.host, url.path]];
		}
	} else if ([url.host isEqualToString:@"cydia.saurik.com"]) {
		if (url.pathComponents.count == 3 && [url.pathComponents[1] isEqualToString:@"package"]) {
			// https://cydia.saurik.com/package/:id/
			if (![_preferences boolForKey:@"CydiaPackage" default:YES]) {
				return nil;
			}

			return [NSURL URLWithString:[@"cydia://package/" stringByAppendingString:url.pathComponents[2]]];
		}
	} else if ([url.host isEqualToString:@"github.com"] || [url.host isEqualToString:@"gist.github.com"]) {
		// all github.com and gist.github.com
		if ([url.host isEqualToString:@"github.com"] && ![_preferences boolForKey:@"GitHubDotCom" default:YES]) {
			return nil;
		} else if ([url.host isEqualToString:@"gist.github.com"] && ![_preferences boolForKey:@"GitHubGist" default:YES]) {
			return nil;
		}

		return [NSURL URLWithString:[NSString stringWithFormat:@"ioc://%@%@", url.host, url.path]];
	} else if ((([url.host isEqualToString:@"reddit.com"] || [url.host hasSuffix:@".reddit.com"]) && ([url.pathComponents containsObject:@"comments"] || url.pathComponents.count == 3)) || [url.host isEqualToString:@"redd.it"]) {
		// *groan*
		NSString *threadID = nil;

		if ([url.host isEqualToString:@"redd.it"] && url.pathComponents.count == 2) {
			// http://redd.it/:thread
			if (![_preferences boolForKey:@"RedditShortener" default:YES]) {
				return nil;
			}

			threadID = url.pathComponents[1];
		} else if ((url.pathComponents.count == 5 || url.pathComponents.count == 6) && [url.pathComponents[2] isEqualToString:@"r"] && [url.pathComponents containsObject:@"comments"]) {
			// https://www.reddit.com/r/:subreddit/comments/:thread/:name?/
			threadID = url.pathComponents[4];
		}

		if (threadID) {
			if (![_preferences boolForKey:@"RedditThread" default:YES]) {
				return nil;
			}

			return @[
				[NSURL URLWithString:[NSString stringWithFormat:@"submarine://%@", url.absoluteString]],
				[NSURL URLWithString:[NSString stringWithFormat:@"alienblue://thread/%@", threadID]]
			];
		} else if (url.pathComponents.count == 3 && [url.pathComponents[1] isEqualToString:@"r"]) {
			// https://www.reddit.com/r/:subreddit
			if (![_preferences boolForKey:@"RedditSubreddit" default:YES]) {
				return nil;
			}

			return @[
				[NSURL URLWithString:[NSString stringWithFormat:@"submarine://subreddit/%@", url.pathComponents[2]]],
				[NSURL URLWithString:[NSString stringWithFormat:@"alienblue://r/%@", url.pathComponents[2]]]
			];
		} else if (url.pathComponents.count > 2 && ([url.pathComponents[1] isEqualToString:@"u"] || [url.pathComponents[1] isEqualToString:@"user"])) {
			// https://www.reddit.com/user/:username (or /u/)
			if (![_preferences boolForKey:@"RedditUser" default:YES]) {
				return nil;
			}

			return [NSURL URLWithString:[NSString stringWithFormat:@"submarine://user/%@", url.pathComponents[2]]];
		}

		return [NSURL URLWithString:[@"alienblue://_linkopener_url?" stringByAppendingString:url.absoluteString]];
	} else if ([url.host hasSuffix:@".tumblr.com"]) {
		NSString *blog = [url.host componentsSeparatedByString:@"."][0];

		if (url.pathComponents.count < 2) {
			// https://:blog.tumblr.com/
			if (![_preferences boolForKey:@"TumblrBlog" default:YES]) {
				return nil;
			}

			return [NSURL URLWithString:[NSString stringWithFormat:@"tumblr://x-callback-url/blog?blogName=%@", blog]];
		} else if (url.pathComponents.count > 3 && [url.pathComponents[1] isEqualToString:@"post"]) {
			// https://:blog.tumblr.com/post/:id/
			if (![_preferences boolForKey:@"TumblrPost" default:YES]) {
				return nil;
			}

			return [NSURL URLWithString:[NSString stringWithFormat:@"tumblr://x-callback-url/blog?blogName=%@&postID=%@", blog, url.pathComponents[2]]];
		}
	} else if ([url.host isEqualToString:@"vine.co"]) {
		if (url.pathComponents.count > 2) {
			if ([url.pathComponents[1] isEqualToString:@"v"]) {
				// https://vine.co/v/:id
				if (![_preferences boolForKey:@"VineVideo" default:YES]) {
					return nil;
				}

				return [NSURL URLWithString:[NSString stringWithFormat:@"vine://post/%@", url.pathComponents[2]]];
			} else if ([url.pathComponents[1] isEqualToString:@"u"]) {
				// https://vine.co/u/:id
				if (![_preferences boolForKey:@"VineUser" default:YES]) {
					return nil;
				}

				return [NSURL URLWithString:[NSString stringWithFormat:@"vine://user/%@", url.pathComponents[2]]];
			}
		}
	} else if ([url.host isEqualToString:@"instagram.com"] || [url.host isEqualToString:@"www.instagram.com"]) {
		if (url.pathComponents.count == 2) {
			if (![_preferences boolForKey:@"InstagramUser" default:YES]) {
				return nil;
			}

			return [NSURL URLWithString:[NSString stringWithFormat:@"instagram://user?username=%@", url.pathComponents[1]]];
		} else if (url.pathComponents.count == 4 && [url.pathComponents[1] isEqualToString:@"explore"] && [url.pathComponents[2] isEqualToString:@"tags"]) {
			if (![_preferences boolForKey:@"InstagramTag" default:YES]) {
				return nil;
			}

			return [NSURL URLWithString:[NSString stringWithFormat:@"instagram://tag?name=%@", url.pathComponents[3]]];
		} else if (url.pathComponents.count == 4 && [url.pathComponents[1] isEqualToString:@"explore"] && [url.pathComponents[2] isEqualToString:@"locations"]) {
			if (![_preferences boolForKey:@"InstagramLocation" default:YES]) {
				return nil;
			}

			return [NSURL URLWithString:[NSString stringWithFormat:@"instagram://location?id=%@", url.pathComponents[3]]];
		}
	} else if ([url.host isEqualToString:@"dict.cc"] || [url.host hasSuffix:@".dict.cc"]) {
		if (url.pathComponents.count < 2) {
			NSDictionary *query = url.query.queryKeysAndValues;

			if (query[@"s"]) {
				// http://dict.cc/?s=:query
				if (![_preferences boolForKey:@"DictccTranslation" default:YES]) {
					return nil;
				}

				return @[
					[NSURL URLWithString:[NSString stringWithFormat:@"dictcc-x-callback://x-callback-url/translate?word=%@", query[@"s"]]],
					[NSURL URLWithString:[NSString stringWithFormat:@"dictccplus-x-callback://x-callback-url/translate?word=%@", query[@"s"]]]
				];
			}
		}
	} else if ([url.host isEqualToString:@"yelp.com"] || [url.host isEqualToString:@"www.yelp.com"]) {
		static NSArray *SupportedPaths;
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			// if pathComponent[1] matches one of these, the app supports it
			SupportedPaths = @[ @"search", @"biz", @"check_in", @"check_ins" ];
		});

		if (url.pathComponents.count > 2 && [SupportedPaths containsObject:url.pathComponents[1]]) {
			// https://yelp.com/search/?find_desc=:query, etc
			if (![_preferences boolForKey:@"YelpAll" default:YES]) {
				return nil;
			}

			return [NSURL URLWithString:[NSString stringWithFormat:@"yelp5.3://%@", url.path]];
		}
	} else if ([url.host isEqualToString:@"overcast.fm"]) {
		if (url.pathComponents.count == 2 && [url.pathComponents[1] hasPrefix:@"+"]) {
			// https://overcast.fm/+:episode
			if (![_preferences boolForKey:@"OvercastEpisode" default:YES]) {
				return nil;
			}

			return [NSURL URLWithString:[NSString stringWithFormat:@"overcast://open%@", url.path]];
		} else if (url.pathComponents.count == 2 || url.pathComponents.count == 3) {
			// https://overcast.fm/:podcast/:name?
			// this regex is based on the assumption that all podcast IDs will look like these two really
			// specific cases, which i’m hoping holds true forever :p
			NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^itunes\\d+$|^p\\d+-[\\w\\d]+$" options:NSRegularExpressionCaseInsensitive error:nil];

			if ([regex numberOfMatchesInString:url.pathComponents[1] options:kNilOptions range:NSMakeRange(0, url.pathComponents[1].length)] == 1) {
				if (![_preferences boolForKey:@"OvercastPodcast" default:YES]) {
					return nil;
				}

				return [NSURL URLWithString:[NSString stringWithFormat:@"overcast://open%@", url.path]];
			}
		}
	}

	return nil;
}

@end
