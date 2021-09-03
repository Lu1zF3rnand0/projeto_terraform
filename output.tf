output "IP-Jenkins" {
  value = aws_instance.jenkins.public_ip
}
output "IP-Servidor1" {
  value = aws_instance.servidor1.public_ip
}
output "IP-Servidor2" {
  value = aws_instance.servidor2.public_ip
}
output "ADDRESS-DataBaseMySQL" {
  value = aws_db_instance.mysql.address
}
output "DNS-LB" {
  value = aws_elb.load-balance.dns_name
}