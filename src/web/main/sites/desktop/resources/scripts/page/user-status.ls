function init-read-before-statuses-button
	$button = $ \#read-before
	$button.click ->
		$button
			..attr \disabled on
			..attr \title '読み込み中...'
			..find \i .attr \class 'fa fa-spinner fa-pulse'

		$.ajax config.api-url + '/web/status/user-timeline-detailhtml' {
			type: \get
			data: {
				'user-id': $ '#status .main > .status.article' .attr \data-user-id
				'max-cursor': $ '#status .main > .status.article' .attr \data-timeline-cursor
			}
			data-type: \json
			xhr-fields: {+with-credentials}}
		.done (data) ->
			$button.remove!
			$statuses = $ data
			$statuses.each ->
				$status = $ '<li class="status">' .append $ @
				window.STATUS_CORE.set-event $status.children '.status.article'
				$status.append-to $ '#before-timeline > .statuses'
		.fail (data) ->
			$button = $ @
				..attr \disabled off
				..attr \title 'これより前の投稿を読む'
				..find \i .attr \class 'fa fa-angle-down'

			window.display-message '読み込みに失敗しました。再度お試しください。'

function init-read-after-statuses-button
	$button = $ \#read-after
	$button.click ->
		$button
			..attr \disabled on
			..attr \title '読み込み中...'
			..find \i .attr \class 'fa fa-spinner fa-pulse'

		$.ajax config.api-url + '/web/status/user-timeline-detailhtml' {
			type: \get
			data: {
				'user-id': $ '#status .main > .status.article' .attr \data-user-id
				'since-cursor': $ '#status .main > .status.article' .attr \data-timeline-cursor
			}
			data-type: \json
			xhr-fields: {+with-credentials}}
		.done (data) ->
			$button.remove!
			$statuses = $ data
			$statuses.each ->
				$status = $ '<li class="status">' .append $ @
				window.STATUS_CORE.set-event $status.children '.status.article'
				$status.append-to $ '#after-timeline > .statuses'
		.fail (data) ->
			$button = $ @
				..attr \disabled off
				..attr \title 'これより後の投稿を読む'
				..find \i .attr \class 'fa fa-angle-up'

			window.display-message '読み込みに失敗しました。再度お試しください。'

$ ->
	window.STATUS_CORE.set-event $ '#status .main .status.article'

	init-read-before-statuses-button!
	init-read-after-statuses-button!