// AWS SDK를 이용한다.
const AWS = require('aws-sdk');
const sns = new AWS.SNS();
const codepipeline = new AWS.CodePipeline();

// Lambda 함수가 실행되면 아래 함수에 파라미터가 채워져서 호출된다.
exports.handler = (event, context, callback) => {
  // event 변수의 값을 확인해보기 위한 로깅
  console.log('EVENT--------');
  console.log(event);

  // 현재 실행되고 있는 CodePipeline의 job id
  const jobId = event['CodePipeline.job'].id;
  // SNS의 주제를 게시할 때 사용할 파라미터
  // Message는 CodePipeline에서 넘어온 UserParameter 값을 사용하여 구성한다.
  // 주제 ARN은 SNS에서 생성한 주제의 ARN 값을 입력한다.
  const snsParams = {
    Message: `${userParams(event)} 배포 완료!`,
    TopicArn: 'arn:aws:sns:ap-northeast-2:222179995953:IB07441-Codepipeline-Notification' // 실제 ARN 값 입력 필요!
  };
  
  // SNS의 주제에 게시한다.
  sns.publish(snsParams, (snsErr, data) => {
    // SNS 주제 게시에 실패한 경우
    if (snsErr) {
      console.log(snsErr);
      const pipelineParams = {
        jobId: jobId,
        failureDetails: {
          message: JSON.stringify(snsErr),
          type: 'JobFailed',
          externalExecutionId: context.invokeid
        }
      };

      return codepipeline.putJobFailureResult(pipelineParams, (pipelineErr, data) => {
        if (pipelineErr) {
          console.log(pipelineErr);
          callback(pipelineErr, 'SNS: fail. CodePipeline: fail');
        } else {
          callback(snsErr);
        }
      });
    } else {
      const pipelineParams = {
        jobId: jobId
      };

      return codepipeline.putJobSuccessResult(pipelineParams, (pipelineErr, data) => {
        if (pipelineErr) {
          console.log(pipelineErr);
          callback(pipelineErr, 'SNS: success, CodePipeline: fail');
        } else {
          callback(null, data);
        }
      });
    }
  });

  // CodePipeline에서 넘어온 user parameter 값을 추출한다.
  function userParams(event) {
    let value;
    try {
      value = event['CodePipeline.job'].data.actionConfiguration.configuration.UserParameters;
    } catch (error) {
      value = '';
    }
    return value;
  }
};