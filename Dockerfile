FROM ubuntu

RUN apt-get update && \
    apt-get -y install curl build-essential automake autoconf git

# add user
RUN useradd -d /home/app/ -m -G sudo app
RUN mkdir -m 0755 /app
RUN chown app /app
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

# env variables that can be used by the user
ENV ETH_RPC_URL http://127.0.0.1:8545
ENV ETH_GAS_PRICE 7000000
ENV ETH_KEYSTORE /home/app/keystore
ENV ETH_PASSWORD /home/app/passphrase

WORKDIR /app

CMD dapp testnet
