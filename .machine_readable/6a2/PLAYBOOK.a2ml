;; SPDX-License-Identifier: MPL-2.0-or-later
;; PLAYBOOK.scm - Operational runbook for thejeffparadox

(define playbook
  `((version . "1.0.0")

    (procedures
      ((deploy
         ((build . "just build")
          (test . "just test")
          (container-build . "podman build -t jeff-paradox -f container/Containerfile .")
          (container-run . "podman run -it --rm -e ANTHROPIC_API_KEY jeff-paradox")
          (pages-deploy . "hugo -s orchestrator && gh-pages -d orchestrator/public")))
       (run-experiment
         ((single-turn . "./scripts/run_turn.sh")
          (infinite-loop . "TURN_DELAY=3600 ./scripts/infinite_loop.sh")
          (metrics-report . "./scripts/metrics_report.sh")))
       (rollback
         ((git-reset . "git reset --hard HEAD~1")
          (container-rollback . "podman image rm jeff-paradox")))
       (debug
         ((julia-repl . "julia --project=engine")
          (hugo-server . "hugo server -s orchestrator")
          (ada-build . "cd tui && alr build")))))

    (alerts
      ((chaos-threshold
         ((condition . "chaos >= 80")
          (action . "Alien emergence event triggered")))
       (exposure-threshold
         ((condition . "exposure >= 50")
          (action . "External investigation scenario")))
       (convergence-detected
         ((condition . "convergence-index > 0.9")
          (action . "Increase diversity injection frequency")))))

    (contacts
      ((maintainer . "hyperpolymath")
       (repo . "github.com/hyperpolymath/thejeffparadox")
       (issues . "github.com/hyperpolymath/thejeffparadox/issues")))))
