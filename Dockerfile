# Use Jupyter Notebook with R pre-installed
FROM jupyter/r-notebook:x86_64-ubuntu-22.04

# Install required R packages
RUN Rscript -e "install.packages('remotes', repos='https://cloud.r-project.org')"

# Install additional R packages
RUN Rscript -e "remotes::install_version('IRkernel', version='1.3.0', repos='https://cloud.r-project.org')"
RUN Rscript -e "remotes::install_version('tidyverse', version='2.0.0', repos='https://cloud.r-project.org')"
RUN Rscript -e "remotes::install_version('caret', version='6.0-94', repos='https://cloud.r-project.org')"
RUN Rscript -e "remotes::install_version('randomForest', version='4.7-1.1', repos='https://cloud.r-project.org')"
RUN Rscript -e "remotes::install_version('e1071', version='1.7-14', repos='https://cloud.r-project.org')"
RUN Rscript -e "remotes::install_version('pROC', version='1.18.5', repos='https://cloud.r-project.org')"


# Register IRKernel in Jupyter
RUN Rscript -e "IRkernel::installspec(user = FALSE)"

# Set working directory inside the container
WORKDIR /home/jovyan/work

# Expose Jupyter Notebook port
EXPOSE 8888

# Start Jupyter Notebook
CMD ["start-notebook.sh", "--NotebookApp.token=''", "--NotebookApp.password=''", "--port=8888", "--ip=0.0.0.0", "--allow-root"]
