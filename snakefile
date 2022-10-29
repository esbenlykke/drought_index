rule targets:
  input:
    "data/ghcnd_all.tar.gz",
    "data/ghcnd_all_filenames.txt",
    "data/ghcnd-inventory.txt",
    "data/ghcnd-stations.txt",
    "data/ghcnd_tidy.tsv.gz",
    "data/ghcnd_regions_years.tsv",
    "visuals/heatmap_world_drought.png",
    "index.html"

rule get_all_archive:
  input:
    script = "code/get_ghcnd_data.sh"
  conda:
    "environment.yml"
  params:
      "ghcnd_all.tar.gz" # Read up on how the params keyword works!
  output:
    "data/ghcnd_all.tar.gz"
  shell:
    "{input.script} {params}"

rule list_filenames:
  input:
    script = "code/list_ghcnd_filenames.sh",
    archive = "data/ghcnd_all.tar.gz"
  conda:
    "environment.yml"
  output:
    "data/ghcnd_all_filenames.txt"
  shell:
    "{input.script}"

rule get_inventory:
  input:
    script = "code/get_ghcnd_data.sh"
  conda:
    "environment.yml"
  params:
      file = "ghcnd-inventory.txt"
  output:
    "data/ghcnd-inventory.txt"
  shell:
    "{input.script} {params.file}"

rule get_station_metadata:
  input:
    script = "code/get_ghcnd_data.sh"
  conda:
    "environment.yml"
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
    conda:
      "environment.yml"
    output:
      "data/ghcnd_tidy.tsv.gz"
    shell:
      "{input.bash_script}"

rule get_regions_years:
    input:
      r_script = "code/get_regions_years.R",
      data = "data/ghcnd-inventory.txt"
    conda:
      "environment.yml"
    output:
      "data/ghcnd_regions_years.tsv"
    shell:
      "{input.r_script}"
      
rule plot_drought_by_region:
    input: 
      r_script = "code/plot_drough_by_region.R",
      prcp_data = "data/ghcnd_tidy.tsv.gz",
      station_data = "data/ghcnd_regions_years.tsv"
    conda:
      "environment.yml"
    output:
      "visuals/heatmap_world_drought.png"
    shell:
      """
      {input.r_script}
      """

rule render_index:
  input:
    qmd = "index.qmd",
    vis = "visuals/heatmap_world_drought.png"
  conda:
    "environment.yml"
  output:
    "index.html"
  shell:
    """
    quarto render {input.qmd}
    """
