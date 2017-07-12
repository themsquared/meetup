output "address" {
  value = "${aws_elb.tf_demo.dns_name}"
}
