require! {
	fs
	path
	express
	gm
	'../../models/user': User
	'../../models/user-image': UserImage
	'../../models/post': Status
	'../../models/post-image': StatusImage
	'../../models/talk-message': TalkMessage
	'../../models/talk-message-image': TalkMessageImage
	'../../models/webtheme': Webtheme
	'../../config'
}

module.exports = (app) ->
	function display-image(req, res, image-buffer, img-url, file-name, author)
		img = gm image-buffer
		img.size (err, val) ->
			res.display req, res, 'image' {
				image-url
				file-name: author.screen-name + '.jpg'
				author
				width: val.width
				height: val.height
			}
	
	function send-image(req, res, image-buffer)
		if req.query.blur?
			try
				options = JSON.parse req.query.blur.replace /([a-zA-Z]+)\s?:\s?([^,}"]+)/g '"$1":$2'
				gm image-buffer
					..blur options.radius, options.sigma
					..compress ¥jpeg
					..quality 80
					..to-buffer ¥jpeg (err, buffer) ->
						if error then throw error
						res
							..set 'Content-Type' 'image/jpeg'
							..send buffer
			catch e
				res
					..status 400
					..send e
		else
			res
				..set 'Content-Type' 'image/jpeg'
				..send image-buffer

	function display-user-image(req, res, id-or-sn, image-property-name)
		function display(user, user-image)
			if user-image != null
				image-buffer = if user-image[image-property-name] != null
					then user-image[image-property-name]
					else fs.read-file-sync path.resolve __dirname + '/../resources/images/' + image-property-name + '_default.jpg'
				if req.headers['accept'].index-of 'text' == 0
					display-image do
						req
						res
						image-buffer
						'https://misskey.xyz/img/' + image-property-name + '/' + id-or-sn
						user.screen-name
				else
					send-image req, res, image-buffer
		if id-or-sn.match /^[0-9]+$/
			User.find id-or-sn, (user) ->
				if user == null
					res
						..status 404
						..send 'User not found.'
					return
				UserImage.find Number id-or-sn, (user-image) ->
					display user, user-image
		else
			User.findByScreenName id-or-sn, (user) ->
				if user == null
					res
						..status 404
						..send 'User not found.'
					return
				UserImage.find user.id, (user-image) ->
					display user, user-image

	function display-status-image(req, res, id)
		StatusImage.find id, (status-image) ->
			if status-image != null
				image-buffer = status-image.image
				Status.find status-image.post-id, (post) ->
					if req.headers['accept'].indexOf 'text' == 0
						User.find post.userId, (user) ->
							display-image do
								req
								res
								image-buffer
								'https://misskey.xyz/img/post/' + id
								post.created-at + '.jpg'
								user
					else
						send-image req, res, image-buffer
			else
				res
					..status 404
					..send 'Image not found.'
				return

	function display-talkmessage-image(req, res, id)
		TalkMessageImage.find id, (talkmessage-image) ->
			if talkmessage-image == null
				res
					..status 404
					..send 'Image not found.'
				return
			TalkMessage.find talkmessage-image.message-id, (talkmessage) ->
				err = switch
					| !req.login => [403 'Access denied.']
					| req.me.id != talkmessage.user-id && req.me.id != talkmessage.otherparty-id => [403 'Access denied.']
					| _ => null
				if err == null
					image-buffer = talkmessage-image.image;
					if req.headers['accept'].indexOf 'text' == 0
						User.find talkmessage.user-id, (user) ->
							display-image do
								req
								res
								image-buffer
								'https://misskey.xyz/img/talk-message/' + id
								talkmessage.created-at + '.jpg'
								user
					else
						send-image req, res, image-buffer
				else
					res
						..status err.0
						..send err.1

	# User icon
	app.get '/img/icon/:idOrSn' (req, res) ->
		id-or-sn = req.params.idOrSn
		display-user-image req, res, id-or-sn, 'icon'

	# User header
	app.get '/img/header/:idOrSn' (req, res) ->
		id-or-sn = req.params.idOrSn
		display-user-image req, res, id-or-sn, 'header'

	# User wallpaper
	app.get '/img/wallpaper/:idOrSn' (req, res) ->
		id-or-sn = req.params.idOrSn
		display-user-image req, res, id-or-sn, 'wallpaper'

	# Status
	app.get '/img/status/:id' (req, res) ->
		id = req.params.id
		display-status-image req, res, id

	# Talk message
	app.get '/img/talk-message/:id' (req, res) ->
		id = req.params.id
		display-talkmessage-image req, res, id
		
	# Webtheme thumbnail
	app.get '/img/webtheme_thumbnail/:id' (req, res) ->
		id = req.params.id
		WebTheme.find id, (webtheme) ->
			if webtheme != null
				image-buffer = webtheme.thumbnail
				send-image req, res, image-buffer
			else
				res
					..status 404
					..send 'WebTheme not found.'
