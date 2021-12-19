resource "aws_acm_certificate" "Acm_Certificate" {
  domain_name       = "*.ibatcl.net"
  validation_method = "DNS"

  tags = {
    Name = "IB07441-Acm_Certificate"
    Environment = "test"
  }
}

resource "aws_route53_record" "Route53_Record_Acm" {
  for_each = {
    for dvo in aws_acm_certificate.Acm_Certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.Route53_Zone_ibatcl.zone_id
}

resource "aws_acm_certificate_validation" "Acm_Certificate_Validation" {
  certificate_arn         = aws_acm_certificate.Acm_Certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.Route53_Record_Acm : record.fqdn]
}