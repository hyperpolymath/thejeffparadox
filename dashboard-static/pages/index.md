---
title: Metrics Dashboard
---

<div class="dashboard-grid">

## Experiment Status

<div class="status-cards">
  <div class="status-card">
    <span class="status-value" id="turn-count">15</span>
    <span class="status-label">Total Turns</span>
  </div>
  <div class="status-card">
    <span class="status-value" id="convergence-index">0.34</span>
    <span class="status-label">Convergence Index</span>
  </div>
  <div class="status-card">
    <span class="status-value" id="vocab-diversity">0.74</span>
    <span class="status-label">Vocabulary Diversity</span>
  </div>
  <div class="status-card status-healthy">
    <span class="status-value">HEALTHY</span>
    <span class="status-label">System Status</span>
  </div>
</div>

## Convergence & Diversity Over Time

<div class="chart-container">
  <canvas id="chart-convergence" aria-label="Convergence and diversity metrics over turns"></canvas>
</div>

## Game State Dynamics

<div class="chart-container">
  <canvas id="chart-gamestate" aria-label="Chaos, exposure, and faction balance over time"></canvas>
</div>

## Node Comparison

<div class="chart-row">
  <div class="chart-container half">
    <h3>Alpha vs Beta: Vocabulary</h3>
    <canvas id="chart-vocab-compare" aria-label="Vocabulary comparison between nodes"></canvas>
  </div>
  <div class="chart-container half">
    <h3>Self-Reference Rates</h3>
    <canvas id="chart-self-ref" aria-label="Self-reference rates by node"></canvas>
  </div>
</div>

## Statistical Analysis

<div class="stats-grid">
  <div class="stat-card">
    <h3>ADF Test (Convergence)</h3>
    <div class="stat-result pending">
      <span class="stat-value">—</span>
      <span class="stat-interp">Need 30+ turns</span>
    </div>
  </div>
  <div class="stat-card">
    <h3>Hotelling's T² (Differentiation)</h3>
    <div class="stat-result pending">
      <span class="stat-value">—</span>
      <span class="stat-interp">Need 30+ turns</span>
    </div>
  </div>
  <div class="stat-card">
    <h3>Bayes Factor (Attractor)</h3>
    <div class="stat-result pending">
      <span class="stat-value">—</span>
      <span class="stat-interp">Need 50+ turns</span>
    </div>
  </div>
  <div class="stat-card">
    <h3>Semantic Convergence</h3>
    <div class="stat-result healthy">
      <span class="stat-value">0.42</span>
      <span class="stat-interp">Low (healthy)</span>
    </div>
  </div>
</div>

## Emerging Personality Profiles

<div class="personality-grid">
  <div class="personality-card alpha">
    <h3>Node Alpha (Homeward)</h3>
    <ul class="traits">
      <li><strong>Astronomical metaphors</strong> — 85%</li>
      <li><strong>Physical detachment</strong> — 70%</li>
      <li><strong>Strategic urgency</strong> — 60%</li>
      <li><strong>Human connection</strong> — 15%</li>
    </ul>
    <p class="profile-summary">Focused on return, views body as temporary vessel</p>
  </div>
  <div class="personality-card beta">
    <h3>Node Beta (Earthbound)</h3>
    <ul class="traits">
      <li><strong>Sensory appreciation</strong> — 80%</li>
      <li><strong>Relational focus</strong> — 75%</li>
      <li><strong>Philosophical inquiry</strong> — 70%</li>
      <li><strong>Belonging drive</strong> — 85%</li>
    </ul>
    <p class="profile-summary">Growing attachment to Earth, seeks human connection</p>
  </div>
</div>

## Anti-Convergence Systems

<div class="ac-grid">
  <div class="ac-card active">
    <h4>Diversity Injection</h4>
    <span class="ac-status">Next: Turn 20</span>
  </div>
  <div class="ac-card inactive">
    <h4>Contradiction Seeding</h4>
    <span class="ac-status">Threshold: 0.85</span>
  </div>
  <div class="ac-card active">
    <h4>Aperture Control</h4>
    <span class="ac-status">Temp: 0.8</span>
  </div>
  <div class="ac-card inactive">
    <h4>Pattern Quarantine</h4>
    <span class="ac-status">0 patterns</span>
  </div>
</div>

</div>

---

*Data updates when new turns are committed. Last build: <%= DateTime.utc_now() |> DateTime.to_iso8601() %>*
