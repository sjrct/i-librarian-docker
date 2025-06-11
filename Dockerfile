FROM ubuntu

EXPOSE 80

# Install i-librarian and dependencies using modified install script
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /work
COPY install.patch .
RUN apt-get update && apt-get install -y curl xz-utils patch
RUN curl -LO 'https://github.com/mkucej/i-librarian-free/releases/download/5.11.2/I-Librarian-5.11.2-Ubuntu-console.tar.xz' && \
    tar xf I-Librarian-5.11.2-Ubuntu-console.tar.xz
RUN patch install.sh <install.patch && ./install.sh
RUN apt-get install php8.3-ldap

# Copy and enable site configuration
COPY i-librarian.conf /etc/apache2/sites-available/i-librarian.conf
RUN a2dissite 000-default && a2ensite i-librarian

VOLUME /var/lib/i-librarian
VOLUME /etc/i-librarian/config

ENTRYPOINT ["bash", "-c"]
CMD ["source /etc/apache2/envvars && apache2 -D FOREGROUND"]
