;; SPDX-FileCopyrightText: 2025 The Jeff Paradox Collaboration
;; SPDX-License-Identifier: MPL-2.0-or-later
;;
;; TESTING-REPORT.scm - Structured Testing Report for The Jeff Paradox
;; Format: Guile Scheme (application/testing-report+scm)
;; Generated: 2025-12-29

(testing-report
 (metadata
  (version "1.0.0")
  (report-date "2025-12-29")
  (project "thejeffparadox")
  (repository "https://github.com/hyperpolymath/thejeffparadox")
  (branch "main"))

 (environment
  (platform "linux")
  (os-version "Linux 6.17.12-300.fc43.x86_64")
  (distribution "Fedora 43")
  (julia-version "1.12.2")
  (hugo-installed #f)
  (alire-installed #f))

 (summary
  (overall-status passed-with-fixes)
  (total-tests 469)
  (passed-tests 469)
  (failed-tests 0)
  (skipped-components 2)
  (issues-found 4)
  (issues-fixed 4))

 (components
  (component
   (name "JeffEngine")
   (technology "Julia")
   (type "game-engine")
   (status passed)
   (test-count 469)
   (duration-seconds 27.1)
   (test-suites
    (test-suite (name "Dice Mechanics") (passed 200) (total 200))
    (test-suite (name "Chaos Management") (passed 6) (total 6))
    (test-suite (name "Exposure Management") (passed 6) (total 6))
    (test-suite (name "Faction Mechanics") (passed 4) (total 4))
    (test-suite (name "Skill Resolution") (passed 5) (total 5))
    (test-suite (name "Threshold Events") (passed 6) (total 6))
    (test-suite (name "Conceptors") (passed 26) (total 26))
    (test-suite (name "Metrics") (passed 4) (total 4))))

  (component
   (name "Hugo Sites")
   (technology "Hugo")
   (type "static-site-generator")
   (status skipped)
   (reason "Hugo not installed on test system")
   (sites
    (site (path "orchestrator") (role "game-master"))
    (site (path "node-alpha") (role "homeward-faction"))
    (site (path "node-beta") (role "earthbound-faction"))))

  (component
   (name "Ada TUI")
   (technology "Ada 2022")
   (type "terminal-ui")
   (status skipped)
   (reason "Alire not installed on test system")
   (source-files
    (file "tui/src/jeff_tui.adb")
    (file "tui/src/tui.ads")
    (file "tui/src/tui.adb")
    (file "tui/src/game_state.ads")
    (file "tui/src/game_state.adb")))

  (component
   (name "Shell Scripts")
   (technology "Bash")
   (type "automation")
   (status passed-with-fix)
   (scripts
    (script (path "scripts/run_turn.sh") (fixed #t))
    (script (path "scripts/infinite_loop.sh") (fixed #f))
    (script (path "scripts/metrics_report.sh") (fixed #f)))))

 (issues
  (issue
   (id "ISSUE-001")
   (severity high)
   (type configuration)
   (title "Project.toml Format Error")
   (description "Non-standard [project] section header instead of top-level name/uuid")
   (file "engine/Project.toml")
   (status fixed)
   (fix-description "Moved name, uuid, version, authors to top level"))

  (issue
   (id "ISSUE-002")
   (severity high)
   (type configuration)
   (title "Missing Test Dependency Declaration")
   (description "Project.toml missing [extras] and [targets] sections for Test package")
   (file "engine/Project.toml")
   (status fixed)
   (fix-description "Added [extras] and [targets] sections with Test package"))

  (issue
   (id "ISSUE-003")
   (severity high)
   (type code)
   (title "Missing Function Exports")
   (description "Functions roll_with_modifier, contested_roll, chaos_event_description, faction_dominance not exported")
   (file "engine/src/JeffEngine.jl")
   (status fixed)
   (fix-description "Added missing exports to module definition"))

  (issue
   (id "ISSUE-004")
   (severity medium)
   (type code)
   (title "Missing Printf Import in Script")
   (description "run_turn.sh uses @sprintf without importing Printf module")
   (file "scripts/run_turn.sh")
   (status fixed)
   (fix-description "Added 'using Printf' to Julia code block")))

 (files-modified
  (file
   (path "engine/Project.toml")
   (changes
    (change "Removed [project] section header")
    (change "Added [extras] section with Test")
    (change "Added [targets] section for test")))

  (file
   (path "engine/src/JeffEngine.jl")
   (changes
    (change "Added export for roll_with_modifier")
    (change "Added export for contested_roll")
    (change "Added export for chaos_event_description")
    (change "Added export for exposure_event_description")
    (change "Added export for faction_dominance")
    (change "Added export for faction_state_description")))

  (file
   (path "scripts/run_turn.sh")
   (changes
    (change "Added 'using Printf' to Julia code block"))))

 (files-created
  (file (path "TESTING-REPORT.adoc") (format "AsciiDoc"))
  (file (path "TESTING-REPORT.scm") (format "Guile Scheme")))

 (recommendations
  (recommendation
   (priority high)
   (category ci)
   (title "Add CI tests for Project.toml validity")
   (description "Format errors should be caught by CI before reaching main branch"))

  (recommendation
   (priority high)
   (category documentation)
   (title "Document Printf requirement for scripts")
   (description "Since @sprintf is used in scripts, document or re-export Printf"))

  (recommendation
   (priority high)
   (category testing)
   (title "Add integration tests")
   (description "Current tests cover units but not component integration"))

  (recommendation
   (priority medium)
   (category ci)
   (title "Install Hugo in CI")
   (description "Ensure Hugo sites are built and validated in CI"))

  (recommendation
   (priority medium)
   (category ci)
   (title "Add Ada compilation to CI")
   (description "Use Alire in CI to compile and test the TUI"))

  (recommendation
   (priority medium)
   (category quality)
   (title "Add script linting")
   (description "Use ShellCheck to catch issues before runtime"))

  (recommendation
   (priority low)
   (category documentation)
   (title "Update Julia compat version")
   (description "README shows 1.9, tests run on 1.12")))

 (test-metrics
  (test-execution-time-seconds 27.1)
  (precompilation-time-seconds 330)
  (total-session-time-minutes 15)
  (fix-count 4)
  (lines-modified 12)
  (files-modified 3)
  (files-created 2))

 (conclusion
  (status success)
  (summary "All 469 JeffEngine tests pass after applying 4 fixes to configuration and exports. Hugo sites and Ada TUI could not be tested due to missing build tools but source code review shows no obvious issues.")))

;; Helper function to query this report
(define (get-issue-by-id report id)
  "Retrieve an issue from the report by its ID"
  (let ((issues (assq-ref report 'issues)))
    (find (lambda (issue) (equal? (assq-ref issue 'id) id)) issues)))

;; Helper function to get all high-priority recommendations
(define (get-high-priority-recommendations report)
  "Get all recommendations with priority 'high'"
  (let ((recommendations (assq-ref report 'recommendations)))
    (filter (lambda (rec) (eq? (assq-ref rec 'priority) 'high)) recommendations)))

;; Helper function to get test summary
(define (get-test-summary report)
  "Get a formatted test summary string"
  (let ((summary (assq-ref report 'summary)))
    (format #f "Tests: ~a/~a passed, ~a issues found and fixed"
            (assq-ref summary 'passed-tests)
            (assq-ref summary 'total-tests)
            (assq-ref summary 'issues-fixed))))
