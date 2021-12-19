data "aws_route53_zone" "Route53_Zone_ibatcl" {
  name         = "ibatcl.net"
  private_zone = false
}

# resource "aws_route53_zone_association" "Route53_Zone_Association" {
#   zone_id = data.aws_route53_zone.Route53_Zone_ibatcl.zone_id
#   vpc_id  = aws_vpc.VPC.id
#   vpc_region = "ap-northeast-2"
# }

# resource "aws_route53_zone" "Route53_Zone_ib07441" {
#   name = "ib07441.ibatcl.net"

#   tags = {
#     Environment = "dev"
#   }
# }

# resource "aws_route53_record" "Route53_Record_ib07441-ns" {
#   zone_id = aws_route53_zone.Route53_Zone_ibatcl.zone_id
#   name    = "ib07441.ibatcl.net"
#   type    = "NS"
#   ttl     = "30"
#   records = aws_route53_zone.Route53_Zone_ib07441.name_servers
#}

resource "aws_route53_record" "Route53_Record_lb" {
  zone_id = data.aws_route53_zone.Route53_Zone_ibatcl.zone_id
  name    = "lb.ibatcl.net"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.Instance_LbEc2Instance.public_ip]
}

resource "aws_route53_record" "Route53_Record_web1" {
  zone_id = data.aws_route53_zone.Route53_Zone_ibatcl.zone_id
  name    = "web1.ibatcl.net"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.Instance_Web1Ec2Instance.public_ip]
}

resource "aws_route53_record" "Route53_Record_web2" {
  zone_id = data.aws_route53_zone.Route53_Zone_ibatcl.zone_id
  name    = "web2.ibatcl.net"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.Instance_Web2Ec2Instance.public_ip]
}

# resource "aws_route53_record" "Route53_Record_Kibana" {
#   zone_id = data.aws_route53_zone.Route53_Zone_ibatcl.zone_id
#   name    = "kibana.ibatcl.net"
#   type    = "A"
#   ttl     = "300"
#   records = [aws_instance.Instance_KibanaEc2Instance.public_ip]
# }

# resource "aws_route53_record" "Route53_Record_CI" {
#   zone_id = data.aws_route53_zone.Route53_Zone_ibatcl.zone_id
#   name    = "ci.ibatcl.net"
#   type    = "A"
#   ttl     = "300"
#   records = [aws_instance.Instance_CIEc2Instance.private_ip]
# }