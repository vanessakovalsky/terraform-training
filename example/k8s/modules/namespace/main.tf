resource "kubernetes_namespace" "vanessakovalsky" {
  # boucle for : boucler sur une liste ou un objet map
  # boucle for_each : boucer sur des ressources et des lignes de blocs
  # count : boucler sur les ressources 
  for_each = toset(var.ns)
  metadata {
          name = each.value
  }
}