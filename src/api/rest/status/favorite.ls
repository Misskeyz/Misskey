require! {
	'../../auth': authorize
	'../../limitter'
	'../../../config'
	'../../../utils/get-express-params'
	'../../../models/utils/serialize-status'
	'../../../models/status': Status
	'../../../models/status-favorite': StatusFavorite
	'../../../models/utils/status-check-favorited'
	'../../internal/create-notice'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	limitter user.id, \status/favorite, 86400sec, 300fav .then do
		->
			process!
		->
			res.api-error 403 'limit'
	
	function process
		[status-id] = get-express-params req, <[ status-id ]>
		switch
		| empty status-id => res.api-error 400 'status-id parameter is required :('
		| _ => Status.find-by-id status-id, (, target-status) ->
				| !target-status? => res.api-error 404 'Post not found...'
				| target-status.repost-from-status-id? => # Repostなら対象をRepost元に差し替え
					Status.find-by-id target-status.repost-from-status-id, (, true-target-status) ->
						favorite-step req, res, app, user, true-target-status
				| _ => favorite-step req, res, app, user, target-status

function favorite-step req, res, app, user, target-status
	status-check-favorited target-status.id, user.id .then (is-favorited) ->
		| is-favorited => res.api-error 400 'This post is already favorited :('
		| _ =>
			favorite = new StatusFavorite do
				status-id: target-status.id
				user-id: user.id
			favorite.save ->
				serialize-status target-status, res.api-render
				
				user
					..status-favorites-count++
					..save ->
				
				target-status
					..favorites-count++
					..save (err) ->
						# Create notice
						create-notice null, target-status.user-id, \status-favorite {
							status-id: target-status.id
							user-id: user.id
						} .then ->
						
						
