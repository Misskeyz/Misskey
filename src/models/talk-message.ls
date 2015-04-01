require! {
	mongoose
	'mongoose-auto-increment'
	'../config'
}

db = mongoose.create-connection config.mongo.uri, config.mongo.options

mongoose-auto-increment.initialize db

talk-message-schema = new mongoose.Schema do
	app-id:            { type: Number,  required: yes }
	created-at:        { type: Date,    required: yes, default: Date.now }
	is-deleted:        { type: Boolean, default: no }
	is-image-attached: { type: Boolean, required: yes, default: no }
	is-readed:         { type: Boolean, default: no }
	is-modified:       { type: Boolean, default: no }
	otherparty-id:     { type: Number,  required: yes }
	text:              { type: String,  required: yes }
	user-id:           { type: Number,  required: yes }

# Virtual duplicate _id property 
talk-message-schema.virtual 'id' .get -> @_id

# Auto increment
talk-message-schema.plugin mongoose-auto-increment.plugin, { model: \TalkMessage, field: '_id' }

module.exports = db.model \TalkMessage talk-message-schema
