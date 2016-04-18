include:
  - gerrit.install
  - gerrit.service

extend:
  gerrit_service:
    service:
      - watch:
        - file: gerrit_config
        - file: secure_config
