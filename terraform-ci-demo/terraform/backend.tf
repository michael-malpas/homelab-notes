terraform {
	backend "s3" {
		bucket = "michael-malpas-terraform-state-2026"
		key = "terraform/day19/terraform.tfstate"
		region = "us-east-1"
		use_lockfile = true
	}
}
