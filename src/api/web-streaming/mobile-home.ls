require! {
	cookie
	redis
	jade
	'../../models/user': User
	'../../models/status': Status
	'../../models/notice': Notice
	'../../web/main/sites/mobile/utils/serialize-timeline-status'
	'../../web/main/sites/mobile/utils/parse-text'
	'../../config'
}

module.exports = (io, session-store) -> io.of '/streaming/web/mobile/home' .on \connection (socket) ->
	# Connect redis
	subscriber = redis.create-client!

	# Get cookies
	cookies = cookie.parse socket.handshake.headers.cookie

	# Get sesson key
	sid = cookies[config.session-key]
	sidkey = sid.match /s:(.+?)\./ .1

	# Resolve session
	err, session <- session-store.get sidkey
	switch
	| err => console.log err.message
	| !session? => console.log "undefined: #{sidkey}"
	| _ =>
		# Set user id
		socket.user-id = session.user-id

		# Get and set session user
		err, user <- User.find-by-id socket.user-id
		socket.user = user

		# Subscribe Home stream channel
		subscriber.subscribe "misskey:userStream:#{socket.user-id}"
		subscriber.on \message (, content) ->
			try
				content = parse-json content
				if content.type? && content.value?
					switch content.type
						| \status, \repost =>
							# Find status
							err, status <- Status.find-by-id content.value.id
							# Send timeline status HTML
							status-compiler = jade.compile-file "#__dirname/../../web/main/sites/mobile/views/dynamic-parts/status/normal/status.jade"
							serialize-timeline-status status, socket.user, (serialized-status) ->
								socket.emit content.type, status-compiler do
									status: serialized-status
									login: yes
									me: socket.user
									text-parser: parse-text
									config: config.public-config
						| \notice =>
							# Find notice
							err, notice <- Notice.find-by-id content.value.id
							# socket.emit \notice html
						| _ => socket.emit content.type, content.value
				else
					socket.emit content
			catch e
				socket.emit content

		# Disconnect event
		socket.on \disconnect ->
			# Disconnect redis
			subscriber.quit!
