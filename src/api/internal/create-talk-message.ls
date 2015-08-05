require! {
	fs
	gm
	'../../models/talk-message': TalkMessage
	'../../models/talk-history': TalkHistory
	'../../models/user-following': UserFollowing
	'../../models/utils/user-following-check'
	'../../utils/publish-redis-streaming'
	'../../utils/register-image'
}

module.exports = (app, user, otherparty-id, text, image = null) ->
	resolve, reject <- new Promise!
	text .= trim!
	switch
	| !image? && null-or-empty text => reject 'Empty text.'
	| null-or-empty otherparty-id => reject 'Empty otherparty-id'
	| _ => user-following-check otherparty-id, user.id .then (is-following) ->
		| !is-following => reject 'You are not followed from this user. To send a message, you need to have been followed from the other party.'
		| image? =>
			image-quality = if user.is-plus then 70 else 50
			gm image
				..compress \jpeg
				..quality image-quality
				..to-buffer \jpeg (, buffer) ->
					create buffer
		| _ => create null

	function create(image)
		talk-message = new TalkMessage {
			app-id: if app? then app.id else null
			user-id: user.id
			otherparty-id
			text
			is-image-attached: image?
		}
		err, created-talk-message <- talk-message.save
		if err?
			reject err
		else
			switch
			| image? =>
				image-name = "#{created-talk-message.id}-1.jpg"
				register-image user, \talk-message-image image-name, \jpg, image .then ->
					created-talk-message.images = [image-name]
					created-talk-message.save ->
						done created-talk-message
			| _ =>
				done created-talk-message

	function done(message)
		resolve message
		
		user-id = user.id
		message-id = message.id
		
		function update-me-history
			(, history) <- TalkHistory.find-one {user-id, otherparty-id}
			if history?
				history.updated-at = Date.now!
				history.message-id = message.id
				history.save!
			else
				new-history = new TalkHistory {user-id, otherparty-id, message-id}
				new-history.save!
		
		function update-otherparty-history
			(, history) <- TalkHistory.find-one {user-id: otherparty-id, otherparty-id: user-id}
			if history?
				history.updated-at = Date.now!
				history.message-id = message.id
				history.save!
			else
				new-history = new TalkHistory {user-id: otherparty-id, otherparty-id: user-id, message-id}
				new-history.save!
		
		update-me-history!
		update-otherparty-history!

		[
			["userStream:#{otherparty-id}" \talk-message]
			["talkStream:#{otherparty-id}-#{user.id}" \otherparty-message]
			["talkStream:#{user.id}-#{otherparty-id}" \me-message]
		] |> each ([channel, type]) ->
			publish-redis-streaming channel, to-json {type, value: {id: message.id}}
