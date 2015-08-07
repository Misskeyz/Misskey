function swing($elem, force)
	t = 1
	timer = set-interval update, 10ms
	function update
		t++
		pos = ((Math.sin(t / 20) * force) / ((t / 512) / 3))
		$elem.css \transform "perspective(1024px) rotateX(#{pos}deg)"

$ ->
	function set-features1-design-layer
		$ '#features-1 > .design-layer' .css \height "#{$ \#features-1 .outer-height! + 128}px"
	
	function set-footer-design-layer
		$ '#footer > .design-layer' .css \height "#{$ \#footer .outer-height! + 128}px"
	
	set-features1-design-layer!
	set-footer-design-layer!
	
	$ window .resize ->
		set-features1-design-layer!
		set-footer-design-layer!

	$ '#login-form' .submit (event) ->
		event.prevent-default!
		$form = $ @
			..css {
				'transform': 'perspective(512px) rotateX(-90deg)'
				'opacity': '0'
				'transition': 'all ease-in 0.5s'
			}
		
		$submit-button = $form.find '[type=submit]'
			..attr \disabled on

		$.ajax \/login {
			type: \post
			data: $form.serialize!}
		.done ->
			location.reload!
		.fail ->
			$submit-button.attr \disabled off
			set-timeout ->
				$form.css {
					'transform': 'perspective(512px) scale(1)'
					'opacity': '1'
					'transition': 'all ease 0.7s'
				}
			, 500ms

	$ '#new' .click show-register-form
	init-register-form!

function init-register-form
	$progress = $ '#register-form progress'
	user-name-input-query = '#register-form .user-name .user-name-input'
	nickname-input-query = '#register-form .nickname .nickname-input'
	password-input-query = '#register-form .password .password-input'
	password-retype-input-query = '#register-form .password-retype .password-retype-input'
	user-color-input-query = '#register-form .user-color .user-color-input'

	init-user-name-section!
	init-nickname-section!
	init-password-section!
	init-password-retype-section!
	init-user-color-section!
	init-confirm-section!

	$ '#register-form form' .submit (event) ->
		event.prevent-default!
		$form = $ @

		$.ajax "#{config.api-url}/account/create" {
			type: \post
			data: $form.serialize!
			data-type: \json
			xhr-fields: {+withCredentials}}
		.done ->
			location.href = config.url
		.fail ->

	function init-user-name-section
		right = no

		$ user-name-input-query .on \keypress (event) ->
			if event.which == 13
				if right then next!
				false
			else
				true

		$ user-name-input-query .keyup ->
			right = no
			$next-button.attr \disabled on
			hide-message!
			sn = $ user-name-input-query .val!

			if sn != ''
				err = switch
					| sn.length < 4chars             => '4文字以上でお願いしますっ'
					| sn.match /^[0-9]+$/            => 'すべてを数字にすることはできませんっ'
					| not sn.match /^[a-zA-Z0-9_]+$/ => '半角英数記号(_)のみでお願いしますっ'
					| sn.length > 20chars            => '20文字以内でお願いします'
					| _                              => null

				if err
					show-message err, no
				else
					show-message '確認中...' null
					$.ajax "#{config.api-url}/screenname-available" {
						type: \get
						data: {'screen-name': sn}
						data-type: \json
						xhr-fields: {+withCredentials}}
					.done (result) ->
						if result
							right = no
							show-message 'このIDは既に使用されていますっ' no
						else
							right = yes
							show-message 'このIDは使用できますっ！' yes
							$next-button.attr \disabled off
					.fail ->
						show-message '確認に失敗しました;;' null

		

		function show-message(message, success)
			hide-message!
			klass = if success == null
				then ''
				else
					if success then \done else \fail
			$message = $ "<p id=\"userNameAvailable\" class=\"message #{klass}\">#{message}</p>"
			$message.css \top ($ user-name-input-query .position!.top - 32px + ($ user-name-input-query .outer-height! / 2))
			$message.append-to '#register-form .user-name' .animate {
				'margin-right': 0
				opacity: 1
			} 500ms \easeOutCubic

		function hide-message
			$ '#userNameAvailable' .remove!

	function init-nickname-section
		right = no
			
		$(nickname-input-query).on \keypress (event) ->
			if event.which == 13
				if right then next!
				false
			else
				true

		$ nickname-input-query .keyup ->
			right = no
			hide-message!
			$next-button.attr \disabled on
			name = $ nickname-input-query .val!
			if name.length > 0chars
				right = yes
				show-message 'Great!' yes
				$next-button.attr \disabled off

		function show-message(message, success)
			hide-message!
			klass = if success == null
				then ''
				else
					if success then \done else \fail
			$message = $ "<p id=\"nicknameAvailable\" class=\"message #{klass}\">#{message}</p>"
			$message.css \top ($ nickname-input-query .position!.top - 32px + ($ nickname-input-query .outer-height! / 2))
			$message.append-to '#register-form .nickname' .animate {
				'margin-right': 0
				opacity: 1
			} 500ms \easeOutCubic

		function hide-message
			$ '#nicknameAvailable' .remove!

	function init-password-section
		right = no
		
		$ password-input-query .on \keypress (event) ->
			if event.which == 13
				if right then next!
				false
			else
				true

		$ password-input-query .keyup ->
			right = no
			hide-message!
			$next-button.attr \disabled on
			password = $ password-input-query .val!
			if password.length > 0
				err = switch
					| password.length < 8chars => '8文字以上でお願いします'
					| _ => null
				if err
					show-message err, no
				else
					show-message 'Nice!' yes
					$next-button.attr \disabled off
					right = yes
			else
				false

		function show-message(message, success)
			hide-message!
			klass = if success == null
				then ''
				else
					if success then \done else \fail
			$message = $ "<p id=\"passwordAvailable\" class=\"message #{klass}\">#{message}</p>"
			$message.css \top ($ password-input-query .position!.top - 32px + ($ password-input-query .outer-height! / 2))
			$message.append-to '#register-form .password' .animate {
				'margin-right': 0
				opacity: 1
			} 500ms \easeOutCubic

		function hide-message
			$ '#passwordAvailable' .remove!

	function init-password-retype-section
		right = no
		
		$ password-retype-input-query .on \keypress (event) ->
			if event.which == 13
				if right then next!
				false
			else
				true

		$ password-retype-input-query .keyup ->
			right = no
			hide-message!
			$next-button.attr \disabled on
			password = $ password-input-query .val!
			password-retype = $ password-retype-input-query .val!
			if password-retype.length > 0chars
				if password-retype != password
					show-message '一致していませんっ！' no
					false
				else
					right = yes
					show-message 'Okay!' yes
					$next-button.attr \disabled off
			else
				false

		function show-message(message, success)
			hide-message!
			klass = if success == null
				then ''
				else
					if success then \done else \fail
			$message = $ "<p id=\"passwordRetypeAvailable\" class=\"message #{klass}\">#{message}</p>"
			$message.css \top  ($ password-retype-input-query .position!.top - 32px + ($ password-retype-input-query .outer-height! / 2))
			$message.append-to '#register-form .password-retype' .animate {
				'margin-right': 0
				opacity: 1
			} 500ms \easeOutCubic

		function hide-message
			$ '#passwordRetypeAvailable' .remove!

	function init-user-color-section
		right = no

		$ user-color-input-query .change ->
			hide-message!
			color = $ user-color-input-query .val!
			right = yes
			show-message 'Good!' yes
			$next-button.attr \disabled off

		function show-message(message, success)
			hide-message!
			klass = if success == null
				then ''
				else
					if success then \done else \fail
			$message = $ "<p id=\"userColorAvailable\" class=\"message #{klass}\">#{message}</p>"
			$message.css \top ($ user-color-input-query .position!.top - 32px + ($ user-color-input-query .outer-height! / 2))
			$message.append-to '#register-form .user-color' .animate {
				'margin-right': 0
				opacity: 1
			} 500ms \easeOutCubic

		function hide-message
			$ '#userColorAvailable' .remove!

function show-register-form
	$ \#register-form-background .css \display \block
	$ \#register-form-background .animate {
		opacity: 1
	} 500ms \linear
	$ \#register-form .animate {
		top: 0
		opacity: 1
	} 1000ms \easeOutElastic
	$ '#register-form progress' .attr \value 1
	$ '#register-form .user-name .user-name-input' .focus!

function hide-register-form
	$ \#register-form-background .animate {
		opacity: 0
	} 500ms \linear ->
		$ \#register-form-background .css \display \none
	$ \#register-form .animate {
		top: '-200%'
		opacity: 0
	} 1000ms \easeInOutQuart