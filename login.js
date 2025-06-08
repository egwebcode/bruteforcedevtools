const crypto = require('crypto');

const PASSWORD_HASH = 'fb39dab15b4fec9808485f1df1e231fd9535fe6e88d7e19f29f18ac69d570152';

exports.handler = async (event) => {
  const { password } = JSON.parse(event.body || '{}');
  const hash = crypto.createHash('sha256').update(password).digest('hex');

  if (hash === PASSWORD_HASH) {
    return {
      statusCode: 200,
      body: JSON.stringify({ success: true })
    };
  } else {
    return {
      statusCode: 401,
      body: JSON.stringify({ success: false })
    };
  }
};
