module.exports = (x) -> {$regex: new RegExp "^#{x.to-lower-case!}" \i}