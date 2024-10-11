locals {
  default_tags = var.default_tags_enabled ? {
    env   = var.environment
    stack = var.stack
  } : {}

  uai_tags               = merge(local.default_tags, var.extra_tags, var.user_assigned_identity_tags)
  default_node_pool_tags = merge(local.default_tags, var.extra_tags, local.default_node_pool.tags)
}
