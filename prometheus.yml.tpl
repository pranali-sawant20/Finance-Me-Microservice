# prometheus.yml.tpl

global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node_exporter'
    consul_sd_configs:
      - server: 'localhost:8500'
        services: ['node_exporter']
