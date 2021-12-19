resource "aws_elastic_beanstalk_application" "Elastic_Beanstalk_Application" {
  name        = "ib07441-elastic-beanstalk-application"
  description = "ib07441-elastic_beanstalk_application"
}

data "aws_elastic_beanstalk_solution_stack" "Elastic_Beanstalk_Solution_Stack" {
  most_recent = true

  name_regex = "^64bit Amazon Linux (.*) running Node.js$"
}

resource "aws_elastic_beanstalk_environment" "Elastic_Beanstalk_Environment" {
  name                = "ib07441-elastic-beanstalk-environment"
  application         = aws_elastic_beanstalk_application.Elastic_Beanstalk_Application.name
  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.Elastic_Beanstalk_Solution_Stack.name
  tier                = "WebServer"

  setting {
    namespace   = "aws:autoscaling:launchconfiguration" 
    name        = "IamInstanceProfile"
    value       = "aws-elasticbeanstalk-ec2-role"
  }
}

resource "aws_elastic_beanstalk_application_version" "Elastic_Beanstalk_Application_Version" {
  name        = "ib07441-elastic-beanstalk-application-version"
  application = aws_elastic_beanstalk_application.Elastic_Beanstalk_Application.name
  description = "application version created by terraform"
  bucket      = aws_s3_bucket.S3Bucket.id
  key         = aws_s3_bucket_object.S3_Bucket_Object.id

  provisioner "local-exec" {
    command = join(" ", ["aws elasticbeanstalk update-environment", 
                          "--application-name ${aws_elastic_beanstalk_application.Elastic_Beanstalk_Application.name}", 
                          "--environment-id ${aws_elastic_beanstalk_environment.Elastic_Beanstalk_Environment.id}",
                          "--version-label  ${aws_elastic_beanstalk_application_version.Elastic_Beanstalk_Application_Version.name}"])
  }

}

output "Elastic_Beanstalk_Application" {
  value = aws_elastic_beanstalk_application.Elastic_Beanstalk_Application.name
}

output "Elastic_Beanstalk_Environment" {
  value = aws_elastic_beanstalk_environment.Elastic_Beanstalk_Environment.id
}

output "Elastic_Beanstalk_Environment_Cname" {
  value = aws_elastic_beanstalk_environment.Elastic_Beanstalk_Environment.cname
}

output "S3_Bucket_Object_version_id" {
  value = aws_s3_bucket_object.S3_Bucket_Object.version_id
}