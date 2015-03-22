require! {
	aync
	'../models/application': Application
}
exports = (src-talk-msg) -> 
	talk-msg = {
		created-at: src-talk-msg.created-at
		is-image-attached: src-talk-msg.is-image-attached
		is-readed: src-talk-msg.is-readed
		is-modified: src-talk-msg.is-modified
		otherparty-id: src-talk-msg.otherparty-id
		text: src-talk-msg.text
		user-id: src-talk-msg.user-id
	}
	async.series do
		[
			(next) -> Application.find-by-id src-talk-msg.app-id, (, application) ->
				| app? => next null app
				| _ => next null null
		]
		(, [talk-msg.application])　-> callback talk-msg
