require! {
	mongoose
	'mongoose-auto-increment'
	'../config'
}

Schema = mongoose.Schema

db = mongoose.create-connection config.mongo.uri, config.mongo.options

mongoose-auto-increment.initialize db

schema = new Schema do
	app-id:            {type: Schema.Types.ObjectId,   required: no}
	created-at:        {type: Date,                    required: yes, default: Date.now}
	cursor:            {type: Number}
	is-image-attached: {type: Boolean,                 default: false}
	images:            {type: [String],                default: []}
	replies:           {type: [Schema.Types.ObjectId], default: []}
	text:              {type: String,                  required: no,  default: null}
	thread-cursor:     {type: Number,                  required: yes}
	thread-id:         {type: Schema.Types.ObjectId,   required: yes}
	user-id:           {type: Schema.Types.ObjectId,   required: yes}

if !schema.options.to-object then schema.options.to-object = {}
schema.options.to-object.transform = (doc, ret, options) ->
	ret.id = doc.id
	delete ret._id
	delete ret.__v
	ret

# Auto increment
schema.plugin mongoose-auto-increment.plugin, {model: \BBSPost, field: \cursor}

module.exports = db.model \BBSPost schema
