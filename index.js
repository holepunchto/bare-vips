const binding = require('./binding')

exports.version = function version() {
  return binding.version()
}
