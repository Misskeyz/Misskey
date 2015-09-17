require! {
	jade
	'../../../internal/get-talk-timeline'
	'../../../auth': authorize
	'../../../../utils/get-express-params'
	'../../../../models/user': User
	'../../../../web/main/sites/desktop/utils/serialize-talk-messages'
	'../../../../web/main/sites/desktop/utils/generate-talk-messages-html'
	'../../../../config'
}

module.exports = (req, res) -> authorize req, res, (user, app) ->
	[otherparty-id, since-cursor, max-cursor] = get-express-params req, <[ otherparty-id since-cursor max-cursor ]>
	get-talk-timeline do
		app
		user
		otherparty-id
		30messages
		if !empty since-cursor then Number since-cursor else null
		if !empty max-cursor then Number max-cursor else null
	.then (messages) ->
		if not null-or-empty messages
			User.find-by-id otherparty-id, (, otherparty) ->
				serialize-talk-messages messages, user, otherparty .then (messages) ->
					generate-talk-messages-html messages, user .then (message-htmls) ->
						res.api-render message-htmls.join ''
		else
			res.api-render null
