resource "aws_codecommit_repository" "Codecommit_Repository" {
  repository_name = "ib07441-ECS-WorkShop"
  description     = "IB07441 ECS WorkShop Repository"
  default_branch  = "master"

  tags = {
    Name        = "IB07441 ECS WorkShop Repository"
    Creator = "IB07441"
  }

  provisioner "local-exec" {
    command = "git clone ${self.clone_url_http}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ./${self.repository_name}"
  }

  provisioner "local-exec" {
    command = "cp -r ./nginx-example/* ./${self.repository_name}"
  }
  provisioner "local-exec" {
    command = "cd ./${self.repository_name} && git add * && git commit -m 'Initial Commit' && git push origin master"
  }
}

output "codecommit_repository" {
  value = aws_codecommit_repository.Codecommit_Repository.clone_url_http
}
output "repository_name" {
  value = aws_codecommit_repository.Codecommit_Repository.repository_name
}