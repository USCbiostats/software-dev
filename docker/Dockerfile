FROM rocker/tidyverse:latest
RUN apt-get update && \
	apt-get install -y --no-install-recommends pandoc r-cran-rmarkdown
RUN apt-get update && \
	apt-get install -y --no-install-recommends libssl-dev
RUN Rscript -e 'utils::install.packages("badger","scholar")'
CMD ["bash"]

