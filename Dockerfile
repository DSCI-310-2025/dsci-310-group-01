# Use Jupyter Notebook with R pre-installed
FROM jupyter/r-notebook:x86_64-ubuntu-22.04

# Set working directory inside the container
WORKDIR /home/jovyan/work

# Install Quarto
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget ca-certificates \
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-plain-generic \
    lmodern \
    texlive-latex-recommended \
    texlive-latex-extra \
    && wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.4.553/quarto-1.4.553-linux-amd64.deb \
    && dpkg -i quarto-1.4.553-linux-amd64.deb \
    && rm quarto-1.4.553-linux-amd64.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create and set permissions for Quarto cache directory
RUN mkdir -p /home/jovyan/.cache/quarto && chmod -R 777 /home/jovyan/.cache

USER jovyan

# Install required R packages (combine into a single RUN command)
RUN Rscript -e "install.packages('remotes', repos='https://cloud.r-project.org'); \
                remotes::install_version('IRkernel', version='1.3.0', repos='https://cloud.r-project.org'); \
                remotes::install_version('tidyverse', version='2.0.0', repos='https://cloud.r-project.org'); \
                remotes::install_version('caret', version='6.0-94', repos='https://cloud.r-project.org'); \
                remotes::install_version('randomForest', version='4.7-1.1', repos='https://cloud.r-project.org'); \
                remotes::install_version('e1071', version='1.7-14', repos='https://cloud.r-project.org'); \
                remotes::install_version('pROC', version='1.18.5', repos='https://cloud.r-project.org'); \
                remotes::install_version('docopt', version='0.7.1', repos='https://cloud.r-project.org'); \
                remotes::install_version('rmarkdown', version='2.22', repos='https://cloud.r-project.org'); \
                remotes::install_version('testthat', version='3.1.10', repos='https://cloud.r-project.org')"


# Register IRKernel in Jupyter
RUN Rscript -e "IRkernel::installspec(user = FALSE)"

# Expose Jupyter Notebook port
EXPOSE 8888

# Start Jupyter Notebook
CMD ["start-notebook.sh", "--NotebookApp.token=''", "--NotebookApp.password=''", "--port=8888", "--ip=0.0.0.0", "--allow-root"]
