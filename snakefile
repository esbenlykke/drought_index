rule targets:
  input:
    "data/ghcnd_all.tar.gz",
    "data/ghcnd_all_filenames.txt",
    "data/ghcnd-inventory.txt",
    "data/ghcnd-stations.txt",
    "data/ghcnd_tidy.tsv.gz"

rule get_all_archive:
    input:
      script = "code/get_ghcnd_data.sh"
    output:
      "data/ghcnd_all.tar.gz"
    params:
      "ghcnd_all.tar.gz"
    shell:
      "{input.script} {params}"
      

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

rule summarise_dly_files:
    input:
      bash_script = "code/concatenate_dly.sh",
      Rscript = "code/read_split_dly_files.R",
      tarball = "data/ghcnd_all.tar.gz"
    output:
      "data/ghcnd_tidy.tsv.gz"
    shell:
      "{input.bash_script}"