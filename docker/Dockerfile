FROM rocker/tidyverse:latest
RUN apt-get update && \
	apt-get install -y --no-install-recommends pandoc r-cran-rmarkdown
RUN apt-get update && \
	apt-get install -y --no-install-recommends libssl-dev
RUN Rscript -e 'utils::install.packages("badger")'
RUN apt-get update && apt-get install -y --no-install-recommends \
    	apt-transport-https \
	ca-certificates \
	curl \
	gnupg \
	lsb-release && \
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
	echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
	$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
	apt-get update && apt-get install -y --no-install-recommends docker-ce docker-ce-cli containerd.io
RUN apt-get update && apt-get install -y --no-install-recommends systemctl
RUN systemctl enable docker.service && systemctl enable containerd.service
CMD ["bash"]

