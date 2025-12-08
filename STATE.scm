;;; ==================================================
;;; STATE.scm — The Jeff Paradox Project State
;;; ==================================================
;;;
;;; SPDX-License-Identifier: MIT
;;; Copyright (c) 2025 The Jeff Paradox Contributors
;;;
;;; Project state checkpoint for diachronic identity
;;; experiment in Large Language Models.
;;;
;;; ==================================================

(define state
  '((metadata
     (format-version . "2.0")
     (schema-version . "2025-12-08")
     (created-at . "2025-12-08T00:00:00Z")
     (last-updated . "2025-12-08T00:00:00Z")
     (generator . "Claude/STATE-system"))

    (user
     (name . "The Jeff Paradox Team")
     (roles . ("researchers" "experimenters" "philosophers"))
     (preferences
      (languages-preferred . ("Julia" "Ada" "Bash" "Go"))
      (languages-avoid . ("Python" "Node.js" "TypeScript"))
      (tools-preferred . ("Hugo" "GitHub Actions" "Podman" "Git"))
      (values . ("reproducibility" "philosophical-rigor" "open-science" "minimal-dependencies"))))

    (session
     (conversation-id . "2025-12-08-STATE-REVIEW")
     (started-at . "2025-12-08T00:00:00Z")
     (experiment-turn . 15)
     (experiment-status . "running"))

    ;;; ==================================================
    ;;; CURRENT POSITION
    ;;; ==================================================

    (focus
     (current-project . "The Jeff Paradox")
     (current-phase . "MVP-complete-observation")
     (deadline . #f)
     (blocking-dependencies . ()))

    (current-position
     (summary . "MVP v1 ACHIEVED - Experiment running autonomously")
     (turn-count . 15)
     (game-state
      (chaos . 15)
      (exposure . 15)
      (faction-slider . 8)
      (current-node . "Beta"))
     (infrastructure-status
      (julia-engine . "operational")
      (hugo-sites . "deployed")
      (ci-cd-pipeline . "active")
      (metrics-collection . "running")
      (anti-convergence . "functional"))
     (observation-status
      (vocabulary-diversity . "differentiated")
      (node-personalities . "emerging")
      (convergence-risk . "low")))

    ;;; ==================================================
    ;;; PROJECTS / COMPONENTS
    ;;; ==================================================

    (projects
     ;; Core experiment - COMPLETE
     ((name . "MVP v1 Core")
      (status . "complete")
      (completion . 100)
      (category . "core")
      (phase . "operational")
      (dependencies . ())
      (blockers . ())
      (next . ())
      (notes . "Two-node dialogue with game mechanics fully operational"))

     ;; Julia Engine - COMPLETE
     ((name . "Julia Game Engine")
      (status . "complete")
      (completion . 100)
      (category . "engine")
      (phase . "production")
      (dependencies . ())
      (blockers . ())
      (next . ("Add embedding-based convergence metrics" "Extend novelty detection"))
      (notes . "Core mechanics, LLM client, metrics, conceptors all working"))

     ;; Hugo Sites - COMPLETE
     ((name . "Hugo Static Sites")
      (status . "complete")
      (completion . 100)
      (category . "presentation")
      (phase . "deployed")
      (dependencies . ())
      (blockers . ())
      (next . ("Add interactive metrics dashboard"))
      (notes . "Orchestrator + Alpha + Beta sites on GitHub Pages"))

     ;; CI/CD Pipeline - COMPLETE
     ((name . "GitHub Actions Pipeline")
      (status . "complete")
      (completion . 100)
      (category . "infrastructure")
      (phase . "automated")
      (dependencies . ())
      (blockers . ())
      (next . ())
      (notes . "6-hour turn cycle, daily metrics, RSR-compliant SHA pinning"))

     ;; Anti-Convergence System - OPERATIONAL
     ((name . "Conceptor Anti-Convergence")
      (status . "in-progress")
      (completion . 75)
      (category . "core")
      (phase . "tuning")
      (dependencies . ("Julia Game Engine"))
      (blockers . ())
      (next . ("Tune aperture parameters" "Implement dynamic diversity injection" "Add pattern quarantine alerts"))
      (notes . "4 mechanisms working: diversity injection, contradiction seeding, pattern quarantine, aperture control"))

     ;; Metrics Framework - OPERATIONAL
     ((name . "Statistical Metrics Framework")
      (status . "in-progress")
      (completion . 70)
      (category . "analysis")
      (phase . "collection")
      (dependencies . ("Julia Game Engine"))
      (blockers . ())
      (next . ("Implement embedding-based convergence" "Add Hotelling T-squared tests" "Build Bayes factor computation"))
      (notes . "Vocabulary diversity, self-reference, coherence working; advanced stats pending"))

     ;; Ada TUI - IN PROGRESS
     ((name . "Ada Terminal UI")
      (status . "in-progress")
      (completion . 30)
      (category . "tooling")
      (phase . "development")
      (dependencies . ())
      (blockers . ("Low priority compared to core experiment"))
      (next . ("Complete game state display" "Add real-time metrics" "Implement turn controls"))
      (notes . "Nice-to-have for local experiment monitoring"))

     ;; Container Deployment - READY
     ((name . "Container Infrastructure")
      (status . "in-progress")
      (completion . 60)
      (category . "infrastructure")
      (phase . "testing")
      (dependencies . ())
      (blockers . ())
      (next . ("Test Wolfi container build" "Validate podman-compose" "Document deployment"))
      (notes . "Containerfile exists, needs validation"))

     ;; Documentation - COMPLETE
     ((name . "Documentation Suite")
      (status . "complete")
      (completion . 95)
      (category . "documentation")
      (phase . "published")
      (dependencies . ())
      (blockers . ())
      (next . ("Update wiki with latest findings"))
      (notes . "claude.adoc spec, whitepaper, validity framework, wiki all complete"))

     ;; Multi-Node Extension - FUTURE
     ((name . "Multi-Node Support")
      (status . "paused")
      (completion . 10)
      (category . "extension")
      (phase . "design")
      (dependencies . ("MVP v1 Core"))
      (blockers . ("Need more data from 2-node experiment first"))
      (next . ("Design 3+ node communication protocol" "Extend game mechanics for N nodes"))
      (notes . "Code structure supports extension; waiting for empirical justification")))

    ;;; ==================================================
    ;;; ROUTE TO MVP v1
    ;;; ==================================================

    (route-to-mvp
     (status . "COMPLETE")
     (milestones
      ((milestone . "Basic Architecture")
       (status . "complete")
       (description . "Two LLM nodes + orchestrator engine"))
      ((milestone . "Game Mechanics")
       (status . "complete")
       (description . "Chaos/exposure/faction systems with dice mechanics"))
      ((milestone . "Conversation Loop")
       (status . "complete")
       (description . "Automated turn execution - currently 15+ turns"))
      ((milestone . "Metrics Collection")
       (status . "complete")
       (description . "Vocabulary diversity, self-reference, convergence indices"))
      ((milestone . "Anti-Convergence")
       (status . "complete")
       (description . "Conceptor-inspired mechanisms operational"))
      ((milestone . "Public Presentation")
       (status . "complete")
       (description . "Hugo sites with conversation viewer and metrics"))
      ((milestone . "Documentation")
       (status . "complete")
       (description . "Specification, whitepaper, validity framework"))
      ((milestone . "CI/CD Automation")
       (status . "complete")
       (description . "Scheduled execution every 6 hours"))
      ((milestone . "Statistical Framework")
       (status . "complete")
       (description . "Formalized hypothesis testing structure"))))

    ;;; ==================================================
    ;;; KNOWN ISSUES
    ;;; ==================================================

    (issues
     ;; Technical Issues
     ((id . "ISSUE-001")
      (severity . "low")
      (category . "metrics")
      (title . "Embedding-based convergence not yet implemented")
      (description . "Currently using vocabulary-based metrics; need semantic embeddings for deeper convergence detection")
      (status . "acknowledged")
      (workaround . "Vocabulary diversity provides adequate early warning"))

     ((id . "ISSUE-002")
      (severity . "low")
      (category . "infrastructure")
      (title . "Container deployment untested in production")
      (description . "Containerfile exists but hasn't been validated end-to-end")
      (status . "acknowledged")
      (workaround . "GitHub Actions provides stable execution environment"))

     ((id . "ISSUE-003")
      (severity . "medium")
      (category . "analysis")
      (title . "No automated convergence alerts")
      (description . "Metrics are collected but no automated alerting when convergence thresholds crossed")
      (status . "acknowledged")
      (workaround . "Manual review of daily metrics reports"))

     ((id . "ISSUE-004")
      (severity . "low")
      (category . "tooling")
      (title . "Ada TUI incomplete")
      (description . "Terminal interface only partially implemented")
      (status . "acknowledged")
      (workaround . "Use Hugo sites and CLI scripts for monitoring"))

     ;; Experimental Concerns
     ((id . "ISSUE-005")
      (severity . "medium")
      (category . "methodology")
      (title . "Sample size still small")
      (description . "15 turns may not be sufficient for statistical significance on convergence tests")
      (status . "in-progress")
      (workaround . "Continue automated execution; reassess at 50+ turns"))

     ((id . "ISSUE-006")
      (severity . "low")
      (category . "methodology")
      (title . "Single model family tested")
      (description . "Currently only using Claude models; cross-model comparison not yet attempted")
      (status . "acknowledged")
      (workaround . "Multi-provider support exists; can add Mistral/local models later")))

    ;;; ==================================================
    ;;; QUESTIONS FOR USER
    ;;; ==================================================

    (questions
     ;; Strategic Questions
     ((id . "Q-001")
      (priority . "high")
      (category . "direction")
      (question . "What is the target turn count for initial analysis?")
      (context . "Need to know when to run formal statistical tests - 50 turns? 100 turns?"))

     ((id . "Q-002")
      (priority . "medium")
      (category . "methodology")
      (question . "Should we test with multiple LLM providers simultaneously?")
      (context . "Could run parallel experiments with Claude, Mistral, and local models to compare convergence patterns"))

     ((id . "Q-003")
      (priority . "medium")
      (category . "publication")
      (question . "What is the publication/sharing strategy?")
      (context . "Whitepaper exists but unclear if targeting academic venue, blog post, or informal sharing"))

     ((id . "Q-004")
      (priority . "low")
      (category . "extension")
      (question . "Interest in 3+ node experiments?")
      (context . "Architecture supports it; would be interesting for emergent coalition behavior"))

     ;; Technical Questions
     ((id . "Q-005")
      (priority . "medium")
      (category . "metrics")
      (question . "Which embedding model to use for semantic convergence?")
      (context . "Need to choose: local model (slower but private) vs API (faster but costs)"))

     ((id . "Q-006")
      (priority . "low")
      (category . "infrastructure")
      (question . "Priority on container deployment vs other features?")
      (context . "GitHub Actions works well; container mainly useful for local/self-hosted runs")))

    ;;; ==================================================
    ;;; LONG-TERM ROADMAP
    ;;; ==================================================

    (roadmap
     (vision . "Rigorous empirical investigation of diachronic identity in LLMs through structured adversarial dialogue")

     (phases
      ;; Phase 1 - COMPLETE
      ((phase . 1)
       (name . "MVP Foundation")
       (status . "complete")
       (objectives . ("Two-node dialogue" "Game mechanics" "Basic metrics" "Automation")))

      ;; Phase 2 - CURRENT
      ((phase . 2)
       (name . "Data Collection & Refinement")
       (status . "in-progress")
       (objectives . ("Reach 50+ turns" "Tune anti-convergence" "Refine metrics" "Document observations")))

      ;; Phase 3 - FUTURE
      ((phase . 3)
       (name . "Statistical Analysis")
       (status . "planned")
       (objectives . ("Run ADF stationarity tests" "Compute Bayes factors" "Hotelling T-squared for differentiation" "Formal hypothesis evaluation")))

      ;; Phase 4 - FUTURE
      ((phase . 4)
       (name . "Extended Experiments")
       (status . "planned")
       (objectives . ("Multi-provider comparison" "3+ node configurations" "Parameter sensitivity analysis" "Replication studies")))

      ;; Phase 5 - FUTURE
      ((phase . 5)
       (name . "Publication & Dissemination")
       (status . "planned")
       (objectives . ("Formal writeup" "Open dataset release" "Community engagement" "Follow-up studies"))))

     (future-features
      ("Embedding-based convergence tracking with configurable models")
      ("Real-time convergence alerting system")
      ("Interactive metrics dashboard with historical plots")
      ("Multi-model parallel experiments")
      ("N-node generalization with coalition dynamics")
      ("Automated hypothesis testing pipeline")
      ("Integration with broader AI alignment research")))

    ;;; ==================================================
    ;;; CRITICAL NEXT ACTIONS
    ;;; ==================================================

    (critical-next
     ("Continue automated turn execution toward 50+ turn milestone")
     ("Monitor daily metrics reports for early convergence signals")
     ("Implement embedding-based convergence metric when sample size sufficient")
     ("Document emerging personality differentiation patterns")
     ("Decide on publication venue and timeline"))

    ;;; ==================================================
    ;;; HISTORY
    ;;; ==================================================

    (history
     (snapshots
      ((timestamp . "2025-12-01T00:00:00Z")
       (turn . 0)
       (notes . "Project initialized, Genesis turn created")
       (game-state
        (chaos . 0)
        (exposure . 0)
        (faction-slider . 0)))

      ((timestamp . "2025-12-05T00:00:00Z")
       (turn . 10)
       (notes . "First diversity injection triggered")
       (game-state
        (chaos . 10)
        (exposure . 10)
        (faction-slider . 5)))

      ((timestamp . "2025-12-08T00:00:00Z")
       (turn . 15)
       (notes . "MVP complete, experiment running stably")
       (game-state
        (chaos . 15)
        (exposure . 15)
        (faction-slider . 8)))))

    (context-notes . "The Jeff Paradox is a functioning experiment investigating LLM diachronic identity. MVP achieved. Primary focus now: accumulate turns for statistical analysis while monitoring for convergence.")))

;;; ==================================================
;;; END STATE.scm
;;; ==================================================
