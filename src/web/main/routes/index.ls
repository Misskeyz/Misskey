#
# Web index router
#

require! {
	fs
	express
	'../../../models/access-token': AccessToken
	'../../../models/user': User
	'../../../models/status': Status
	'../../../models/bbs-thread': BBSThread
	'../../../utils/login': do-login
	'../../../config'
	'./image': image-router
}

module.exports = (app) ->
	# Unstatic images
	image-router app

	# Preset
	app.param \userSn (req, res, next, screen-name) ->
		User.find-one {screen-name-lower: screen-name.to-lower-case!} (, user) ->
			if user?
				req.root-user = req.data.root-user = user
				next!
			else
				res
					..status 404
					..display req, res, 'user-not-found' {}
	app.param \statusId (req, res, next, status-id) ->
		Status.find-by-id status-id, (, status) ->
			if status?
				req.root-status = req.data.root-status = status
				next!
			else
				res
					..status 404
					..display req, res, 'status-not-found' {}
	app.param \bbsThreadId (req, res, next, thread-id) ->
		BBSThread.find-by-id thread-id, (, thread) ->
			if thread?
				req.root-thread = req.data.root-thread = thread
				next!
			else
				res
					..status 404
					..display req, res, 'thread-not-found' {}

	app.get '/' (req, res) ->
		if req.login
			then (require '../controllers/home') req, res
			else res.display req, res, 'entrance', {}
	app.get '/config' (req, res) ->
		res.set 'Content-Type' 'application/javascript'
		res.send "var config = conf = #{to-json config.public-config};"
	app.get '/log' (req, res) -> res.display req, res, 'log'
	app.get '/widget/talk/:userSn' (req, res) -> (require '../controllers/user-talk') req, res, \widget
	app.get '/bbs' (req, res) -> (require '../controllers/bbs-home') req, res
	app.get '/bbs/thread/:bbsThreadId' (req, res) -> (require '../controllers/bbs-thread') req, res
	app.get '/bbs/thread/:bbsThreadId/settings' (req, res) -> (require '../controllers/bbs-thread-settings') req, res
	app.get '/bbs/new' (req, res) -> res.display req, res, 'bbs-new-thread'
	app.get '/i/mention' (req, res) -> (require '../controllers/i-mention') req, res
	app.get '/i/mentions' (req, res) -> (require '../controllers/i-mention') req, res
	app.get '/i/talk' (req, res) -> (require '../controllers/i-talks') req, res
	app.get '/i/talks' (req, res) -> (require '../controllers/i-talks') req, res
	app.get '/i/setting' (req, res) -> (require '../controllers/i-setting') req, res
	app.get '/i/settings' (req, res) -> (require '../controllers/i-setting') req, res
	app.get '/login' (req, res) -> res.display req, res, 'login', {}
	app.post '/login' (req, res) ->
		do-login req, req.body.\screen-name, req.body.password, (user) ->
			res.send-status 200
		, -> res.send-status 400
	app.get '/logout' (req, res) ->
		req.session.destroy (err) -> res.redirect '/'
	app.get '/:userSn' (req, res) -> (require '../controllers/user') req, res, \home
	app.get '/:userSn/profile' (req, res) -> (require '../controllers/user') req, res, \profile
	app.get '/:userSn/followings' (req, res) -> (require '../controllers/user') req, res, \followings
	app.get '/:userSn/followers' (req, res) -> (require '../controllers/user') req, res, \followers
	app.get '/:userSn/talk' (req, res) -> (require '../controllers/user-talk') req, res, \normal
	app.get '/:userSn/status/:statusId' (req, res) -> (require '../controllers/status') req, res

