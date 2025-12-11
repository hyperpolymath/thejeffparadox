/**
 * The Jeff Paradox - Dashboard Charts
 * Vanilla JS + Chart.js (no frameworks)
 * Loads metrics from NDJSON/JSON-LD
 */

(function() {
  'use strict';

  // Configuration
  const CONFIG = {
    metricsUrl: '/thejeffparadox/data/metrics.json',
    refreshInterval: 60000, // 1 minute
    chartColors: {
      alpha: 'rgb(30, 74, 122)',
      beta: 'rgb(107, 68, 16)',
      convergence: 'rgb(138, 26, 26)',
      diversity: 'rgb(26, 107, 26)',
      chaos: 'rgb(138, 107, 0)',
      exposure: 'rgb(138, 26, 26)',
      faction: 'rgb(74, 26, 107)'
    }
  };

  // Chart instances
  let charts = {};

  // Sample data (will be replaced by fetched data)
  const sampleMetrics = {
    turns: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
    convergence: [0.58, 0.55, 0.52, 0.48, 0.45, 0.42, 0.40, 0.38, 0.36, 0.35, 0.34, 0.34, 0.34, 0.34, 0.34],
    diversity: {
      alpha: [0.72, 0.72, 0.73, 0.73, 0.74, 0.74, 0.74, 0.75, 0.75, 0.75, 0.76, 0.76, 0.76, 0.76, 0.76],
      beta: [0.68, 0.69, 0.69, 0.70, 0.70, 0.71, 0.71, 0.71, 0.72, 0.72, 0.72, 0.73, 0.73, 0.73, 0.73]
    },
    chaos: [0, 18, 15, 12, 18, 21, 18, 21, 18, 15, 18, 15, 12, 15, 18],
    exposure: [0, 8, 11, 11, 14, 14, 17, 18, 18, 18, 21, 21, 21, 21, 20],
    faction: [0, -2, -4, -8, -6, -4, -2, 0, 2, 4, 6, 3, 0, 3, 0],
    selfRef: {
      alpha: [0.08, 0.08, 0.07, 0.08, 0.08, 0.08, 0.08, 0.08, 0.08, 0.08, 0.08, 0.08, 0.08, 0.08, 0.08],
      beta: [0.10, 0.11, 0.11, 0.12, 0.12, 0.12, 0.12, 0.12, 0.12, 0.12, 0.12, 0.12, 0.12, 0.12, 0.12]
    }
  };

  /**
   * Initialize all charts
   */
  function initCharts() {
    initConvergenceChart();
    initGameStateChart();
    initVocabCompareChart();
    initSelfRefChart();
  }

  /**
   * Convergence & Diversity over time
   */
  function initConvergenceChart() {
    const ctx = document.getElementById('chart-convergence');
    if (!ctx) return;

    charts.convergence = new Chart(ctx, {
      type: 'line',
      data: {
        labels: sampleMetrics.turns,
        datasets: [
          {
            label: 'Convergence Index',
            data: sampleMetrics.convergence,
            borderColor: CONFIG.chartColors.convergence,
            backgroundColor: 'transparent',
            tension: 0.3
          },
          {
            label: 'Alpha Diversity',
            data: sampleMetrics.diversity.alpha,
            borderColor: CONFIG.chartColors.alpha,
            backgroundColor: 'transparent',
            borderDash: [5, 5],
            tension: 0.3
          },
          {
            label: 'Beta Diversity',
            data: sampleMetrics.diversity.beta,
            borderColor: CONFIG.chartColors.beta,
            backgroundColor: 'transparent',
            borderDash: [5, 5],
            tension: 0.3
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: true,
        plugins: {
          legend: { position: 'bottom' }
        },
        scales: {
          y: {
            min: 0,
            max: 1,
            title: { display: true, text: 'Score' }
          },
          x: {
            title: { display: true, text: 'Turn' }
          }
        }
      }
    });
  }

  /**
   * Game State Dynamics (Chaos, Exposure, Faction)
   */
  function initGameStateChart() {
    const ctx = document.getElementById('chart-gamestate');
    if (!ctx) return;

    charts.gamestate = new Chart(ctx, {
      type: 'line',
      data: {
        labels: sampleMetrics.turns,
        datasets: [
          {
            label: 'Chaos',
            data: sampleMetrics.chaos,
            borderColor: CONFIG.chartColors.chaos,
            backgroundColor: 'transparent',
            tension: 0.3
          },
          {
            label: 'Exposure',
            data: sampleMetrics.exposure,
            borderColor: CONFIG.chartColors.exposure,
            backgroundColor: 'transparent',
            tension: 0.3
          },
          {
            label: 'Faction',
            data: sampleMetrics.faction,
            borderColor: CONFIG.chartColors.faction,
            backgroundColor: 'transparent',
            tension: 0.3,
            yAxisID: 'faction'
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: true,
        plugins: {
          legend: { position: 'bottom' }
        },
        scales: {
          y: {
            min: 0,
            max: 100,
            title: { display: true, text: 'Chaos/Exposure (0-100)' }
          },
          faction: {
            position: 'right',
            min: -100,
            max: 100,
            title: { display: true, text: 'Faction (-100 to +100)' },
            grid: { drawOnChartArea: false }
          },
          x: {
            title: { display: true, text: 'Turn' }
          }
        }
      }
    });
  }

  /**
   * Vocabulary Comparison Bar Chart
   */
  function initVocabCompareChart() {
    const ctx = document.getElementById('chart-vocab-compare');
    if (!ctx) return;

    const lastAlpha = sampleMetrics.diversity.alpha[sampleMetrics.diversity.alpha.length - 1];
    const lastBeta = sampleMetrics.diversity.beta[sampleMetrics.diversity.beta.length - 1];

    charts.vocabCompare = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: ['Vocabulary Diversity', 'Unique Terms', 'Astronomical Refs', 'Sensory Terms'],
        datasets: [
          {
            label: 'Alpha',
            data: [lastAlpha, 0.45, 0.85, 0.15],
            backgroundColor: CONFIG.chartColors.alpha
          },
          {
            label: 'Beta',
            data: [lastBeta, 0.52, 0.10, 0.80],
            backgroundColor: CONFIG.chartColors.beta
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: true,
        plugins: {
          legend: { position: 'bottom' }
        },
        scales: {
          y: {
            min: 0,
            max: 1,
            title: { display: true, text: 'Proportion' }
          }
        }
      }
    });
  }

  /**
   * Self-Reference Rates
   */
  function initSelfRefChart() {
    const ctx = document.getElementById('chart-self-ref');
    if (!ctx) return;

    charts.selfRef = new Chart(ctx, {
      type: 'line',
      data: {
        labels: sampleMetrics.turns,
        datasets: [
          {
            label: 'Alpha Self-Ref',
            data: sampleMetrics.selfRef.alpha,
            borderColor: CONFIG.chartColors.alpha,
            backgroundColor: 'transparent',
            tension: 0.3
          },
          {
            label: 'Beta Self-Ref',
            data: sampleMetrics.selfRef.beta,
            borderColor: CONFIG.chartColors.beta,
            backgroundColor: 'transparent',
            tension: 0.3
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: true,
        plugins: {
          legend: { position: 'bottom' }
        },
        scales: {
          y: {
            min: 0,
            max: 0.2,
            title: { display: true, text: 'Rate' }
          },
          x: {
            title: { display: true, text: 'Turn' }
          }
        }
      }
    });
  }

  /**
   * Fetch metrics from JSON endpoint
   */
  async function fetchMetrics() {
    try {
      const response = await fetch(CONFIG.metricsUrl);
      if (!response.ok) {
        console.log('Metrics not available, using sample data');
        return null;
      }
      return await response.json();
    } catch (error) {
      console.log('Using sample data:', error.message);
      return null;
    }
  }

  /**
   * Update charts with new data
   */
  function updateCharts(metrics) {
    if (!metrics) return;

    // Update each chart with new data
    // Implementation depends on metrics JSON structure
    console.log('Metrics loaded:', metrics);
  }

  /**
   * Initialize dashboard
   */
  async function init() {
    console.log('Initializing Jeff Paradox Dashboard...');

    // Wait for Chart.js to load
    if (typeof Chart === 'undefined') {
      console.error('Chart.js not loaded');
      return;
    }

    // Initialize charts with sample data
    initCharts();

    // Try to fetch real metrics
    const metrics = await fetchMetrics();
    if (metrics) {
      updateCharts(metrics);
    }

    // Set up periodic refresh
    // setInterval(async () => {
    //   const metrics = await fetchMetrics();
    //   if (metrics) updateCharts(metrics);
    // }, CONFIG.refreshInterval);

    console.log('Dashboard initialized');
  }

  // Run on DOM ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

})();
