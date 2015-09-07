require! {
	'../user': User
	'../status': Status
}

# Status -> Promise Statuses
module.exports = (status) ->
	| !status.replies? or empty status.replies or !status.replies.0? => new Promise((resolve) -> resolve null)
	| _ => Promise.all (status.replies.reverse! |> map (reply-status-id) ->
		new Promise (resolve, reject) ->
			Status.find-by-id reply-status-id, (, reply-status) ->
				| reply-status? => resolve reply-status
				| _ => resolve null)
