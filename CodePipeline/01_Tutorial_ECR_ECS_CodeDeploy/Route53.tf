data "aws_route53_zone" "Route53_Zone_ibatcl" {
  name         = "ibatcl.net"
  private_zone = false
}

resource "aws_route53_record" "Route53_Record_ib07441" {
  zone_id = data.aws_route53_zone.Route53_Zone_ibatcl.zone_id
  name    = "ib07441.ibatcl.net"
  type    = "A"
  
  alias {
    name                   = aws_lb.Lb_Staging.dns_name
    zone_id                = aws_lb.Lb_Staging.zone_id
    evaluate_target_health = true
  }
}