FROM ubuntu

RUN apt-get update && \
    apt-get -y install curl build-essential automake autoconf git

# add user for nix installation
RUN useradd -d /home/app/ -m -G sudo app
RUN mkdir -m 0755 /nix
RUN chown app /nix
USER app
ENV USER app

# install nix
RUN curl -L https://nixos.org/nix/install | sh
ENV PATH="/home/app/.nix-profile/bin:${PATH}"
ENV NIX_PATH="/home/app//.nix-defexpr/channels/"
ENV NIX_PROFILES="/nix/var/nix/profiles/default /home/app//.nix-profile"
ENV NIX_SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt"
RUN nix-env -iA dapp hevm seth solc -if https://github.com/dapphub/dapptools/tarball/master --substituters https://dapp.cachix.org --trusted-public-keys dapp.cachix.org-1:9GJt9Ja8IQwR7YW/aF0QvCa6OmjGmsKoZIist0dG+Rs=

# install dapp tools
RUN curl https://dapp.tools/install | sh

CMD dapp testnet

