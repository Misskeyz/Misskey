#
# Misskey API server
#

require! {
	express
	cookie
	multer
	redis
	'body-parser'
	'cookie-parser'
	'express-session': session
	'connect-redis'
	'js-yaml': yaml
	'./router': router
	'../utils/publish-redis-streaming'
	'../config'
}

# Init session store
RedisStore = connect-redis session

# Create server
api-server = express!
	..disable 'x-powered-by'

session-store = new RedisStore do
	db: 1
	prefix: 'misskey-session:'

api-server
	..use body-parser.urlencoded {+extended}
	..use multer!
	..use cookie-parser config.cookie-pass
	..use session do
		key: config.session-key
		secret: config.session-secret
		resave: no
		save-uninitialized: yes
		cookie:
			path: '/'
			domain: ".#{config.public-config.domain}"
			http-only: no
			secure: no
			max-age: null
		store: session-store

api-server.use (req, res, next) ->
	function log(status-code, done)
		publish-redis-streaming \log to-json {
			type: \api-outgoing
			value: {
				done
				date: Date.now!
				remote-addr: req.ip
				protocol: req.protocol
				method: req.method
				status-code
				path: "#{req.headers.host}#{req.path}"
			}
		}
	
	res.api-render = (data) ->
		switch req.format
		| \json => res.json data
		| \yaml =>
			res
				..header 'Content-Type' 'text/x-yaml'
				..send yaml.safe-dump data
		| \plain =>
			res
				..header 'Content-Type' 'text/plain'
				..send data
		| _ => res.json data
		log 200 yes

	res.api-error = (http-status-code, error) ->
		res.status http-status-code
		res.api-render {error}
		log http-status-code, no
	
	next!

# Log
api-server.all '*' (req, res, next) ->
	next!
	publish-redis-streaming \log to-json {
		type: \api-incoming
		value: {
			date: Date.now!
			remote-addr: req.ip
			protocol: req.protocol
			method: req.method
			path: "#{req.headers.host}#{req.path}"
		}
	}

api-server.all '*' (req, res, next) ->
	res.set do
		'Access-Control-Allow-Origin': config.public-config.url
		'Access-Control-Allow-Headers': 'Origin, X-Requested-With, Content-Type, Accept'
		'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS'
		'Access-Control-Allow-Credentials': yes
		'X-Frame-Options': \SAMEORIGIN
	next!

api-server.options '*' (req, res, next) ->
	res
		..set do
			'Access-Control-Allow-Headers': 'Origin, X-HTTP-Method-Override, X-Requested-With, Content-Type, Accept'
		..status 200
		..send!

router api-server

api-server.use (req, res, next) ->
	res.api-error 404 'API not found.'

require './web-streaming-server'

exports.app = api-server