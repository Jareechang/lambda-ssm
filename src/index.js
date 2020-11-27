const AWS = require('aws-sdk');
const ssm = new AWS.SSM({
    apiVersion: '2014-11-06'
});

exports.handler = async function(event, context) {
  let ApplicationParams = null;
  try {
    ApplicationParams = await ssm.getParametersByPath(
      {

        Path: process.env.envPath,
        Recursive: true,
        WithDecryption: true
      }
    ).promise();
  } catch (ex) {
    throw new Error(
      `Failed to fetch Parameters from System Manager Parameter Store, ex: ${ex}`
    )
  }
  console.log(ApplicationParams);
}

