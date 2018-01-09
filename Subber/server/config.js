module.exports = {

  db: process.env.MONGODB || process.env.MONGOLAB_URI || process.env.MONGOHQ_URL || 'oncewegetadbsetup, put linkhere',

  sessionSecret: process.env.SESSION_SECRET || 'addthesessionstuffhere',

  googleAnalytics: process.env.GOOGLE_ANALYTICS || 'ifwewantgoogleanalytics'

  mailgun: {
    user: process.env.MAILGUN_USER || 'thisisforpasswordforgot',
    password: process.env.MAILGUN_PASSWORD || 'ditto^'
  },

  stripeOptions: {
    apiKey: process.env.STRIPE_KEY || 'stripekey',
    stripePubKey: process.env.STRIPE_PUB_KEY || '^',
    },

};