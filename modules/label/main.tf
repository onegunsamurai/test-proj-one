locals {

  defaults = {
    label_order = ["namespace", "environment", "stage", "name", "attributes"]
    delimiter   = "-"
    replacement = ""
    sentinel   = "~"
    attributes = [""]
  }

  # The values provided by variables
  enabled             = var.enabled
  regex_replace_chars = var.regex_replace_chars

  name               = lower(replace(coalesce(var.name, local.defaults.sentinel), local.regex_replace_chars, local.defaults.replacement))
  namespace          = lower(replace(coalesce(var.namespace, local.defaults.sentinel), local.regex_replace_chars, local.defaults.replacement))
  environment        = lower(replace(coalesce(var.environment, local.defaults.sentinel), local.regex_replace_chars, local.defaults.replacement))
  stage              = lower(replace(coalesce(var.stage, local.defaults.sentinel), local.regex_replace_chars, local.defaults.replacement))
  delimiter          = coalesce(var.delimiter, local.defaults.delimiter)
  label_order        = length(var.label_order) > 0 ? var.label_order : local.defaults.label_order
  additional_tag_map = var.additional_tag_map

  # Merge attributes
  attributes = compact(distinct(concat(var.attributes, local.defaults.attributes)))

  id_context = {
    name        = local.name
    namespace   = local.namespace
    environment = local.environment
    stage       = local.stage
    attributes  = lower(replace(join(local.delimiter, local.attributes), local.regex_replace_chars, local.defaults.replacement))
  }

  tags_context = {
    name        = local.id
    namespace   = local.namespace
    environment = local.environment
    stage       = local.stage
    attributes  = local.id_context.attributes
  }

  generated_tags = { for l in keys(local.tags_context) : title(l) => local.tags_context[l] if length(local.tags_context[l]) > 0 }

  tags = merge(local.generated_tags, var.tags)

  tags_as_list_of_maps = flatten([
    for key in keys(local.tags) : merge(
      {
        key   = key
        value = local.tags[key]
    }, var.additional_tag_map)
  ])

  labels = [for l in local.label_order : local.id_context[l] if length(local.id_context[l]) > 0]

  id = lower(join(local.delimiter, local.labels))

}