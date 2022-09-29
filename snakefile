rule targets:
  input:
    "data/ghcnd_all.tar.gz",
    "data/ghcnd_all_filenames.txt",
    "data/ghcnd-inventory.txt",
    "data/ghcnd-stations.txt",
    "data/ghcnd_concat.gz"

rule get_all_archive:
    input:
      script = "code/get_ghcnd_data.sh"
    output:
      "data/ghcnd_all.tar.gz"
    params:
      "ghcnd_all.tar.gz"
    shell:
      "{input.script} {params}"

rule concatenate_dly_files:
    input:
      script = "code/concatenate_dly.sh",
      tarball = "data/ghcnd_all.tar.gz"
    output:
      "data/ghcnd_concat.gz"
    shell:
      "{input.script}"
      

rule list_filenames:
  input:
    script = "code/list_ghcnd_filenames.sh",
    archive = "data/ghcnd_all.tar.gz"
  output:
    "data/ghcnd_all_filenames.txt"
  shell:
    "{input.script}"

rule get_inventory:
  input:
    script = "code/get_ghcnd_data.sh"
  output:
    "data/ghcnd-inventory.txt"
  params:
    file = "ghcnd-inventory.txt"
  shell:
    "{input.script} {params.file}"

rule get_station_metadata:
  input:
    script = "code/get_ghcnd_data.sh"
  output:
    "data/ghcnd-stations.txt"
  params:
    file = "ghcnd-stations.txt"
  shell:
    "{input.script} {params.file}"
