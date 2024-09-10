

output "cf_template_map" {
  value = {
    "org_delegation.yaml.tftpl" = replace(data.template_file.org_delegation.rendered, "$$$", "$$")
  }
}
