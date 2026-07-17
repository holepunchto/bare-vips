const test = require('brittle')
const vips = require('.')

test('version', (t) => {
  const version = vips.version()

  t.comment(version)
  t.ok(/^\d+\.\d+\.\d+/.test(version))
})
