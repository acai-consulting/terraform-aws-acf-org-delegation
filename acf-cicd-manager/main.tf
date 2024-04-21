data "template_file" "org_delegation" {
  template = file("${path.module}/org_delegation.yaml.tftpl")
  vars = {
  }
}
