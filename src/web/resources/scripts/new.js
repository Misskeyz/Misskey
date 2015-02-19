var screenNameOk = false;

$(function() {
	$('#screenName').keyup(function() {
		$("#screenNameAvailable").remove();
		var sn = $('#screenName').val();

		if (sn.length == 0) {
			return false;
		}
		if (!sn.match(/^[a-zA-Z0-9_]+$/)) {
			$("#register [name=screen_name]").before("<p id='screenNameAvailable'>���p�p���݂̂ł��肢���܂���</p>");
			return false;
		}
		if (sn.match(/^[0-9]+$/)) {
			$("#register [name=screen_name]").before("<p id='screenNameAvailable'>���ׂĂ̕����𐔎��ɂ��邱�Ƃ͂ł��܂���</p>");
			return false;
		}
		if (sn.length < 4) {
			$("#register [name=screen_name]").before("<p id='screenNameAvailable'>4�����ȏ�ł��肢���܂�</p>");
			return false;
		}
		if (sn.length > 20) {
			$("#register [name=screen_name]").before("<p id='screenNameAvailable'>20�����ȓ��ł��肢���܂�</p>");
			return false;
		}

		$('#screenName').before("<p id='screenNameAvailable'>�m�F��...</p>");
		$.ajax('https://api.misskey.xyz/screenname_available', {
			type: 'get',
			data: { 'screen_name': sn },
			dataType: 'json',
			xhrFields: {
				withCredentials: true
			}
		}).done(function(result) {
			if (result) {
				$('#screenName').before("<p id='screenNameAvailable'>����ID�͊��Ɏg�p����Ă��܂���</p>");
				screenNameOk = false;
			} else {
				$('#screenName').before("<p id='screenNameAvailable'>����ID�͎g�p�ł��܂����I</p>");
				screenNameOk = true;
			}
		}).fail(function() {
		});
	});

	$('#password').keyup(function() {
		$("#passwordAvailable").remove();
		var password = $('#password').val();
		if (password.length == 0) {
			return false;
		}
		if (password.length < 8) {
			$('#password').before("<p id='passwordAvailable'>8�����ȏ�ł��肢���܂�</p>");
			return false;
		}
		$('#password').before("<p id='passwordAvailable'>OK</p>");
	});
	
	$('#form').submit(function(event) {
		event.preventDefault();
		var $form = $(this);
		var $submitButton = $form.find('[type=submit]');

		$submitButton.attr('disabled', true);
		$submitButton.text('���X���҂���������...');

		$.ajax('https://api.misskey.xyz/account/create', {
			type: 'post',
			data: new FormData($form[0]),
			dataType: 'json',
			xhrFields: {
				withCredentials: true
			}
		}).done(function(data) {
			
		}).fail(function(data) {
			$submitButton.attr('disabled', false);
			$submitButton.text('���s���܂��� :(');
		});
	});
});
