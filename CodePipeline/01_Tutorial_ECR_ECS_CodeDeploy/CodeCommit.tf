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
    command = "cp ./Dockerfile ./${self.repository_name}"
  }
  provisioner "local-exec" {
    command = "cp ./index.html ./${self.repository_name}"
  }
  provisioner "local-exec" {
    command = "cp ./nginx.conf ./${self.repository_name}"
  }
  provisioner "local-exec" {
    command = "cp ./taskdef.json ./${self.repository_name}"
  }
  provisioner "local-exec" {
    command = "cp ./*.yaml ./${self.repository_name}"
  }
  provisioner "local-exec" {
    command = "cd ./${self.repository_name} && git add * && git commit -m 'Added task definition files' && git push origin master"
  }
}

output "codecommit_repository" {
  value = aws_codecommit_repository.Codecommit_Repository.clone_url_http
}
output "repository_name" {
  value = aws_codecommit_repository.Codecommit_Repository.repository_name
}