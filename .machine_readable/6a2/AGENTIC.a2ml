;; SPDX-License-Identifier: MPL-2.0-or-later
;; AGENTIC.scm - AI agent interaction patterns for thejeffparadox

(define agentic-config
  `((version . "1.0.0")

    (claude-code
      ((model . "claude-opus-4-5-20251101")
       (tools . ("read" "edit" "bash" "grep" "glob" "write"))
       (permissions . "read-all")
       (context-files . ("claude.adoc" "README.adoc" ".machine_readable/STATE.scm"))))

    (experiment-agents
      ((node-alpha
        ((provider . "anthropic")
         (model . "claude-sonnet-4-20250514")
         (role . "personality-fragment")
         (faction . "homeward")
         (temperature-range . (0.6 . 1.2))
         (max-tokens . 1024)))
       (node-beta
        ((provider . "anthropic")
         (model . "claude-sonnet-4-20250514")
         (role . "personality-fragment")
         (faction . "earthbound")
         (temperature-range . (0.6 . 1.2))
         (max-tokens . 1024)))
       (game-master
        ((provider . "anthropic")
         (model . "claude-sonnet-4-20250514")
         (role . "narrator")
         (temperature . 0.7)
         (max-tokens . 512)))))

    (patterns
      ((code-review . "thorough")
       (refactoring . "conservative")
       (testing . "comprehensive")
       (documentation . "asciidoc-primary")))

    (constraints
      ((languages . ("julia" "hugo" "ada" "bash" "yaml" "toml"))
       (banned . ("typescript" "go" "python" "makefile" "npm" "node"))))

    (anti-convergence-patterns
      ((diversity-injection (frequency . "every-10-turns"))
       (contradiction-seeding (trigger . "coherence > 0.85"))
       (aperture-control (low-diversity . "increase-temperature"))
       (pattern-quarantine (threshold . "5-in-20-turns"))))))
