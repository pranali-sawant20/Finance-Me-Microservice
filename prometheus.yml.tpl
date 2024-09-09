scrape_configs:
  - job_name: 'node_exporter'
    ec2_sd_configs:
      - region: "{{ aws_region }}"
        access_key: "{{ aws_access_key }}"
        secret_key: "{{ aws_secret_key }}"
        port: 9100
    relabel_configs:
      - source_labels: [__meta_ec2_public_ip]
        target_label: instance
