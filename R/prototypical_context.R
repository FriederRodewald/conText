#' Find prototypical contexts (most similar on average to the full set of contexts)
#'
#' @param context vector of texts - `context`` variable in get_context output
#' @param pre_trained a V x D matrix of numeric values - pretrained embeddings with V = size of vocabulary and D = embedding dimensions
#' @param transform_matrix a D x D transformation matrix
#' @param N number of contexts to return
#' @param norm character = c("l2", "none") - set to 'l2' for cosine similarity and to 'none' for inner product (see ?sim2 in text2vec)
#'
#' @return character vector of contexts ordered by average similarity to all contexts
#' @export
#'
prototypical_context <- function(context, pre_trained, transform_matrix, N = 3, norm = 'l2'){

  # embed responses
  embeds_out <- embed_target(context, pre_trained, transform_matrix, aggregate = FALSE)

  # compute similarity matrix
  embeds_sim_matrix <- text2vec::sim2(embeds_out$target_embedding, embeds_out$target_embedding, method = 'cosine', norm = norm)

  # average across contexts
  avg_typicality <- text2vec::sim2(embeds_out$target_embedding, embeds_out$target_embedding, method = 'cosine', norm = norm)
  avg_typicality <- Matrix::colMeans(avg_typicality)
  avg_typicality <- dplyr::tibble(doc_id = embeds_out$obs_included, typicality_score = avg_typicality)
  avg_typicality$typicality_score <- scale(avg_typicality$typicality_score)[,1] # standardize score

  # match to text
  avg_typicality <- avg_typicality %>% dplyr::mutate(context = context[embeds_out$obs_included]) %>% dplyr::arrange(-typicality_score)

  # output
  return(avg_typicality[1:N,])
}