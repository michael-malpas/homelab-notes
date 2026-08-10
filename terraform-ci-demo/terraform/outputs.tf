output "public_server_ips" {
  value = module.public_server.public_ips
}

output "private_server_ips" {
  value = module.private_server.public_ips
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}
