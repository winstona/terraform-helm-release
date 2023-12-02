locals {
  namespace       = var.namespace != "" ? var.namespace : var.name
  helm_chart_name = var.helm_chart_name != "" ? var.helm_chart_name : var.name
  release_name    = var.release_name != "" ? var.release_name : var.name
}

resource "kubernetes_namespace" "this" {
  count = var.create_namespace ? 1 : 0
  metadata {
    name = var.namespace
  }
}

resource "kubectl_manifest" "helm_repo" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1beta2
    kind: ${var.helm_repo_kind}
    metadata:
      name: ${var.name}
      namespace: ${local.namespace}
    spec:
      interval: ${var.refresh_interval}
      url: ${var.helm_repo_url}
      %{if var.helm_repo_type != null}
      type: ${var.helm_repo_type}
      %{endif}
      %{if var.helm_repo_additional_spec != null}
      ${indent(2, var.helm_repo_additional_spec)}
      %{endif}
  YAML

  depends_on = [kubernetes_namespace.this]
}





resource "kubectl_manifest" "helm_release" {
  override_namespace = var.namespace
  yaml_body          = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: ${var.release_name}
      namespace: ${local.namespace}
    spec:
      releaseName: ${local.release_name}
      chart:
        spec:
          chart: ${local.helm_chart_name}
          reconcileStrategy: ChartVersion
          %{if var.chart_version != "latest" }
          version: ${var.chart_version}
          %{endif}
          sourceRef:
            kind: ${var.helm_repo_kind}
            name: ${var.name}
            namespace: ${var.namespace}
      interval: ${var.refresh_interval}
      install:
        crds: Create
      upgrade:
        crds: CreateReplace
      %{if var.values != ""}
      values:
        ${indent(4, var.values)}
      %{endif}
  YAML

  depends_on = [kubectl_manifest.helm_repo, kubernetes_namespace.this]
}
