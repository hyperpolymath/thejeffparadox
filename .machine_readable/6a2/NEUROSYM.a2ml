;; SPDX-License-Identifier: MPL-2.0-or-later
;; NEUROSYM.scm - Neurosymbolic integration config for thejeffparadox

(define neurosym-config
  `((version . "1.0.0")

    (symbolic-layer
      ((type . "scheme")
       (formats . ("STATE.scm" "META.scm" "ECOSYSTEM.scm"))
       (reasoning . "deductive")
       (game-mechanics
         ((chaos-counter . "0-100 range, threshold 80")
          (exposure-tracker . "0-100 range, thresholds 50/90")
          (faction-slider . "-100 to +100, threshold +-75")))))

    (neural-layer
      ((llm-providers . ("anthropic" "mistral" "local"))
       (embeddings ((model . "text-embedding-3-small")))
       (fine-tuning . false)
       (tool-calling . true)))

    (integration
      ((conceptor-mechanisms
         ((diversity-injection . "prompt-level disruption")
          (aperture-control . "temperature modulation")
          (pattern-quarantine . "discourage overused n-grams")))
       (metrics
         ((vocabulary-diversity . "type-token-ratio")
          (topic-drift . "cosine distance")
          (coherence-score . "adjacent turn similarity")))
       (statistics
         ((convergence-detection . "ADF tests")
          (attractor-existence . "Bayes factors")))))))
