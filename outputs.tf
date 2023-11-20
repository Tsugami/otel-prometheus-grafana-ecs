output "app_url" {
  value = module.app-service.alb_dns_name
}
