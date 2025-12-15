;; SPDX-License-Identifier: AGPL-3.0-or-later
;; SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
;; ECOSYSTEM.scm — thejeffparadox

(ecosystem
  (version "1.0.0")
  (name "thejeffparadox")
  (type "project")
  (purpose "An experiment in LLM diachronic identity.")

  (position-in-ecosystem
    "Part of hyperpolymath ecosystem. Follows RSR guidelines.")

  (related-projects
    (project (name "rhodium-standard-repositories")
             (url "https://github.com/hyperpolymath/rhodium-standard-repositories")
             (relationship "standard")))

  (what-this-is "An experiment in LLM diachronic identity.")
  (what-this-is-not "- NOT exempt from RSR compliance"))
