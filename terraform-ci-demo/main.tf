terraform {

  required_providers {

    local = {

      source = "hashicorp/local"

      version = "~> 2.5"
    }
  }
}

resource "local_file" "example" {

  filename = "hello.txt"

  content = "Hello Github Actions!"

}
