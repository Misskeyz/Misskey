/// <reference path="../../../typings/bundle.d.ts" />

import jade = require('jade');
import async = require('async');
import Application = require('../../models/application');
import User = require('../../models/user');
import Post = require('../../models/post');
import PostFavorite = require('../../models/post-favorite');
import conf = require('../../config');

export = Timeline;

class Timeline {
	public static generateHtml(posts: Post[], isLogin: boolean, callback: (timelineHtml: string) => void) {
		if (posts != null) {
			Timeline.selialyzeTimelineOnject(posts,(timeline: any[]) => {
				var compiler = jade.compileFile(__dirname + '/../views/templates/timeline.jade', {});
				var html = compiler({
					posts: timeline,
					login: isLogin,
					url: conf.publicConfig.url,
					parseText: Timeline.parseText
				})
				callback(html);
			});
		} else {
			var compiler = jade.compileFile(__dirname + '/../views/templates/timeline.jade', {});
			var html = compiler({
				posts: null,
				url: conf.publicConfig.url,
				login: isLogin,
				parseText: Timeline.parseText
			})
			callback(html);
		}
	}

	public static selialyzeTimelineOnject(posts: Post[], callback: (posts: any[]) => void): void {
		async.map(posts,(post: any, mapNext: any) => {
			post.isReply = post.inReplyToPostId != 0 && post.inReplyToPostId != null;

			async.series([
				(seriesNext: any) => {
					Application.find(post.appId,(app: Application) => {
						seriesNext(null, app);
					});
				},
				(seriesNext: any) => {
					User.find(post.userId,(user: User) => {
						seriesNext(null, user);
					});
				},
				(seriesNext: any) => {
					PostFavorite.getPostFavoritesCount(post.id,(favoritesCount: number) => {
						seriesNext(null, favoritesCount);
					});
				},
				(seriesNext: any) => {
					Post.getRepostCount(post.id,(repostsCount: number) => {
						seriesNext(null, repostsCount);
					});
				},
				(seriesNext: any) => {
					if (!post.isReply) {
						seriesNext(null, null);
						return;
					}
					Post.find(post.inReplyToPostId,(replyPost: any) => {
						replyPost.isReply = replyPost.inReplyToPostId != 0 && replyPost.inReplyToPostId != null;
						post.reply = replyPost;
						User.find(post.reply.userId,(replyUser: User) => {
							post.reply.user = replyUser;
							seriesNext(null, null);
						});
					});
				}],
				(err: any, results: any) => {
					post.app = results[0];
					post.user = results[1];
					post.favoritesCount = results[2];
					post.repostsCount = results[3];
					mapNext(null, post);
				});
		},(err: any, results: Post[]) => {
				callback(results);
			});
	}

	public static parseText(text: string): string {
		text = escapeHtml(text);
		text = parseURL(text);
		text = parseReply(text);
		text = parseBold(text);
		text = parseSmall(text);
		text = parseNewLine(text);
		return text;

		function escapeHtml(text: string): string {
			return String(text)
				.replace(/&(?!\w+;)/g, '&amp;')
				.replace(/</g, '&lt;')
				.replace(/>/g, '&gt;')
				.replace(/"/g, '&quot;');
		}

		function parseURL(text: string): string {
			return text.replace(/https?:\/\/[-_.!~*a-zA-Z0-9;\/?:\@&=+\$,%#]+/g,(url: string) => {
				return `<a href="${url}" target="_blank" class="url">${url}</a>`;
			});
		}

		function parseReply(text: string): string {
			return text.replace(/@([a-zA-Z0-9_]+)/g,(_: string, screenName: string) => {
				return `<a href="${conf.publicConfig.url}/${screenName}" target="_blank" class="screenName">@${screenName}</a>`;
			});
		}

		function parseBold(text: string): string {
			return text.replace(/\*\*(.+?)\*\*/g,(_: string, word: string) => {
				return `<b>${word}</b>`;
			});
		}

		function parseSmall(text: string): string {
			return text.replace(/\(\((.+?)\)\)/g,(_: string, word: string) => {
				return `<small>(${word})</small>`;
			});
		}

		function parseNewLine(text: string): string {
			return text.replace(/(\r\n|\r|\n)/g, '<br>');
		}
	}
}
