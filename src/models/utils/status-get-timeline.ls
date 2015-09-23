require! {
	'../status': Status
	'../user-following': UserFollowing
}

# ID -> Number -> Number -> Number -> Promise [Status]
module.exports = (user-id, limit, since-cursor, max-cursor) -> new Promise (resolve, reject) ->
	UserFollowing.find {follower-id: user-id} (, followings) ->
		if followings? and not empty followings
			following-ids = [user-id] ++ (followings |> map (following) -> following.followee-id.to-string!)
		else
			following-ids = [user-id]
		query = | !since-cursor? and !max-cursor? => {user-id: {$in: following-ids}}
			| since-cursor? => (user-id: {$in: following-ids}) `$and` (cursor: {$gt: since-cursor})
			| max-cursor?   => (user-id: {$in: following-ids}) `$and` (cursor: {$lt: max-cursor})
		Status
			.find query
			.sort \-createdAt # Desc
			.limit limit
			.exec (, statuses) -> resolve statuses
			
