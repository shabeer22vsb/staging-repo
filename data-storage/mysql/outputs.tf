output "address" {
    description = "connect to DB using this endpoint"
    value = module.data-storage-ireland.address
}
output "port" {
    description = "connect  port using this endpoint"
    value = module.data-storage-ireland.port
}
output "arn" {
    description = "arn of the DB"
    value = module.data-storage-ireland.arn
  
}