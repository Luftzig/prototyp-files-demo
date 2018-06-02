module.exports = (req, res, next) => {
  try {
    if (req.method === 'POST') {
      req.body.createdAt = Date.now()
    }
    console.log('Added createdAt')
  } catch (e) {
    console.error('Failed to add createdAt', e)
  }
// Continue to JSON Server router
  next()
}
