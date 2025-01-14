# Update the VARIANT arg in docker-compose.yml to pick an Elixir version: 1.9, 1.10, 1.10.4
ARG VARIANT=latest
FROM elixir:${VARIANT}

RUN mkdir  /app
COPY . /app
WORKDIR /app
# This Dockerfile adds a non-root user with sudo access. Update the “remoteUser” property in
# devcontainer.json to use it. More info: https://aka.ms/vscode-remote/containers/non-root-user.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Options for common package install script
ARG INSTALL_ZSH="true"
ARG UPGRADE_PACKAGES="true"
ARG COMMON_SCRIPT_SOURCE="https://raw.githubusercontent.com/microsoft/vscode-dev-containers/v0.183.0/script-library/common-debian.sh"
ARG COMMON_SCRIPT_SHA="f64060b984e657da3c81a4ff59744cadac784eec1865ee58f4d0a1892ff0441f"

# Optional Settings for Phoenix
ARG PHOENIX_VERSION="1.5.4"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
RUN echo "Install needed packages and setup non-root user"
RUN apt-get update \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get -y install --no-install-recommends curl ca-certificates 2>&1 \
  && curl -sSL ${COMMON_SCRIPT_SOURCE} -o /tmp/common-setup.sh \
  && ([ "${COMMON_SCRIPT_SHA}" = "dev-mode" ] || (echo "${COMMON_SCRIPT_SHA} */tmp/common-setup.sh" | sha256sum -c -)) \
  && /bin/bash /tmp/common-setup.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" \
  && echo "Install dependencies" \
  && apt-get install -y build-essential \
  && echo "Clean up" \
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/* /tmp/common-setup.sh /tmp/node-setup.sh

RUN echo "Install Phoenix"
RUN su ${USERNAME} -c "mix local.hex --force \
  && mix local.rebar --force \
  && mix archive.install --force hex phx_new ${PHOENIX_VERSION}"

# [Optional] Uncomment this section to install additional OS packages.
RUN echo "Install OS packages"
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install curl python3 git nodejs yarn inotify-tools bash openssl postgresql-client 

RUN mix local.hex --force \
    && mix deps.get 
  
CMD ["iex", "-S", "mix", "phx.server"]