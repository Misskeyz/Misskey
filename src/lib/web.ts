/// <reference path="../../typings/bundle.d.ts" />

import express = require('express');
import mysql = require('mysql');
import bodyParser = require('body-parser');
import cookieParser = require('cookie-parser');
import session = require('express-session');
var RedisStore: any = require('connect-redis')(session);

/* Import router */
import router = require('./web/router');

module.exports = (config: any, db: mysql.IPool) => {
	var webServer = express();
	webServer.set('config', config);
	webServer.set('db', db);
	webServer.set('view engine', 'jade');
	webServer.set('views', __dirname + 'web/views');
	webServer.use(express.static(__dirname + 'web/public'));
	webServer.use(bodyParser.urlencoded({ extended: true }));
	webServer.use(cookieParser(config.cookie_pass));

	/* Session settings */
	webServer.use(session({
		key: 'sid',
		secret: "akari",
		cookie: {
			path: "/",
			domain: ".misskey.xyz", // �T�u�h���C���Ԃŋ��L�ł���悤�ɂ���
			httpOnly: false, // HTTP�I�����[�ɂ���ƃX�N���v�g����Cookie�ɃA�N�Z�X�ł��Ȃ��Ȃ� api.misskey.xyz �ɃZ�b�V�����N�b�L�[�𑗂�Ȃ��Ȃ����肷��
			secure: true, // HTTPS�̂�
			expires: new Date(Date.now() + ((60 * 60 * 24 * 365) * 1000)),
			maxAge: ((60 * 60 * 24 * 365) * 1000)
		},
		/* Session store settings */
		store: new RedisStore({
			db: 1,
			prefix: 'misskey-session:'
		})
	}));

	/* Routing */
	router(webServer);

	webServer.listen(config.port.web);
};