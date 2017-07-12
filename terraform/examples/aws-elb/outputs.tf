output "address" {
  value = "${aws_elb.tf-demo.dns_name}"
}
