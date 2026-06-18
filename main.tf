terraform {
  required_version = ">= 1.0"
}

resource "local_file" "welcome" {
  filename = "welcome.txt"
  content  = "Welcome ${var.username}"
}
